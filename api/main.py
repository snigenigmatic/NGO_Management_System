from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from db import fetchall, execute, callproc

app = FastAPI(title="NGO Management API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class DonationIn(BaseModel):
    receipt: str
    date: str
    desc: Optional[str]
    amount: float
    type: str
    donor_id: int
    ngo_id: int
    event_id: Optional[int] = None


@app.get("/donations")
def list_donations():
    rows = fetchall(
        "SELECT Donation_ID, Receipt_Number, Donation_date, Amount, Type FROM Donation ORDER BY Donation_ID DESC"
    )
    return rows


@app.post("/donations")
def add_donation(d: DonationIn):
    try:
        callproc(
            "add_donation",
            [
                d.receipt,
                d.date,
                d.desc,
                d.amount,
                d.type,
                d.donor_id,
                d.ngo_id,
                d.event_id,
            ],
        )
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/donations/{donation_id}/update")
def update_donation(donation_id: int, amount: float):
    execute(
        "UPDATE Donation SET Amount = %s WHERE Donation_ID = %s", [amount, donation_id]
    )
    return {"status": "ok"}


@app.get("/vendors")
def list_vendors():
    return fetchall(
        "SELECT Vendor_ID, Name, Email, Service_type FROM Vendor ORDER BY Vendor_ID DESC"
    )


@app.delete("/vendor/{vendor_id}")
def delete_vendor(vendor_id: int):
    execute("DELETE FROM Vendor WHERE Vendor_ID = %s", [vendor_id])
    return {"status": "ok"}


@app.get("/events")
def list_events():
    # Fetch base event rows
    sql = """
        SELECT
            e.Event_ID,
            e.Event_Type,
            e.Location,
            e.Venue_ID,
            v.Status AS venue_status,
            sp.Sponsor_Person_ID,
            sp.Name AS sponsor_person_name,
            s.Sponsor_ID,
            s.Name AS sponsor_name
        FROM Event e
        LEFT JOIN Venue v ON e.Venue_ID = v.Venue_ID
        LEFT JOIN Sponsor_Person sp ON e.Sponsor_Person_ID = sp.Sponsor_Person_ID
        LEFT JOIN Sponsor s ON sp.Sponsor_ID = s.Sponsor_ID
        ORDER BY e.Event_ID DESC
    """
    events = fetchall(sql)

    # Fetch donations that look like sponsorships (fallback when Sponsor_Person_ID is not set)
    sponsor_sql = """
        SELECT d.Event_ID, d.Donation_ID, d.Amount, d.Description, dn.Name AS donor_name
        FROM Donation d
        LEFT JOIN Donor dn ON d.Donor_ID = dn.Donor_ID
        WHERE d.Event_ID IS NOT NULL AND (
            LOWER(d.Description) LIKE '%sponsorship%'
            OR LOWER(d.Description) LIKE '%sponsor%'
            OR LOWER(d.Type) LIKE '%spon%'
        )
    """
    sponsor_rows = fetchall(sponsor_sql)

    # Group sponsor_rows by Event_ID for quick lookup
    sponsors_by_event = {}
    for r in sponsor_rows:
        eid = r.get('Event_ID')
        sponsors_by_event.setdefault(eid, []).append(r)

    # Attach sponsors list and sponsored_amount (sum of matched sponsorship donations)
    for e in events:
        e_id = e.get('Event_ID')
        srows = sponsors_by_event.get(e_id, [])
        e['sponsors'] = srows
        e['sponsored_amount'] = sum([float(r['Amount']) for r in srows]) if srows else 0
        # Human-friendly concatenated list for the frontend
        e['sponsors_list'] = ', '.join([f"{r.get('donor_name') or 'Unknown'} ({r.get('Amount')})" for r in srows]) if srows else ''

    return events


@app.post("/events")
def create_event(payload: dict):
    # payload should include event_type, start_date, end_date, location, ngo_id, venue_id, vendors_json
    try:
        callproc(
            "create_event_and_book_venue",
            [
                payload.get("event_type"),
                payload.get("start_date"),
                payload.get("end_date"),
                payload.get("location"),
                payload.get("ngo_id"),
                payload.get("venue_id"),
                payload.get("vendors_json"),
            ],
        )
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/audit")
def audit_log():
    return fetchall(
        "SELECT audit_id, donation_id, changed_at, action, old_amount, new_amount, note FROM Donation_Audit ORDER BY changed_at DESC LIMIT 100"
    )


@app.get("/audit/demo")
def audit_demo():
    # Return real audit rows if present; otherwise synthesize audit-like entries from existing donations
    rows = fetchall(
        "SELECT audit_id, donation_id, changed_at, action, old_amount, new_amount, note FROM Donation_Audit ORDER BY changed_at DESC LIMIT 100"
    )
    if rows:
        return rows

    # No audit rows found -> synthesize from Donation table for demo purposes
    donations = fetchall(
        "SELECT Donation_ID, Receipt_Number, Donation_date, Description, Amount, Donor_ID, NGO_ID, Event_ID FROM Donation ORDER BY Donation_ID DESC LIMIT 100"
    )
    demo = []
    for d in donations:
        demo.append({
            "audit_id": None,
            "donation_id": d.get("Donation_ID"),
            "changed_at": None,
            "action": "INSERT",
            "old_amount": None,
            "new_amount": d.get("Amount"),
            "note": f"Backfilled from Donation: {d.get('Description') or ''}" 
        })
    return demo


@app.get("/summary/ngo")
def summary_ngo():
    view_rows = fetchall("SELECT * FROM vw_ngo_summary ORDER BY NGO_ID")
    func_rows = fetchall(
        "SELECT NGO_ID, NGO_Name, get_ngos_total_donations(NGO_ID) AS total_donations FROM NGO ORDER BY NGO_ID"
    )
    return {"view": view_rows, "func": func_rows}


@app.get("/queries/nested")
def query_nested():
    sql = """
        SELECT d.Donor_ID, d.Name, SUM(n.Amount) AS total_donated
        FROM Donor d
        JOIN Donation n ON d.Donor_ID = n.Donor_ID
        GROUP BY d.Donor_ID, d.Name
        HAVING SUM(n.Amount) > (
            SELECT AVG(Amount) FROM Donation
        )
        ORDER BY total_donated DESC
    """
    return fetchall(sql)


@app.get("/queries/join")
def query_join():
    sql = """
        SELECT e.Event_ID, e.Event_Type, v.Name AS vendor_name, ev.Cost
        FROM Event e
        JOIN Event_Vendor ev ON e.Event_ID = ev.Event_ID
        JOIN Vendor v ON ev.Vendor_ID = v.Vendor_ID
        ORDER BY e.Event_ID
    """
    return fetchall(sql)


@app.get("/queries/aggregate")
def query_aggregate():
    # Use the existing view, which is correct and matches the frontend
    return fetchall("SELECT * FROM vw_monthly_donations")


@app.get("/analytics/kpis")
def analytics_kpis():
    # Return a small set of KPIs using views and aggregates
    sql = """
        SELECT
            (SELECT IFNULL(SUM(Amount),0) FROM Donation) AS total_donations,
            (SELECT COUNT(DISTINCT Donor_ID) FROM Donation) AS total_donors,
            (SELECT COUNT(*) FROM Event) AS total_events,
            (SELECT COUNT(*) FROM Sponsor) AS total_sponsors
    """
    return fetchall(sql)


@app.get("/analytics/top_sponsors")
def analytics_top_sponsors(limit: int = 10):
    # Rank sponsors by total amount associated with events they sponsored
    sql = f"""
        SELECT s.Sponsor_ID, s.Name AS sponsor_name, IFNULL(SUM(d.Amount),0) AS total_sponsored
        FROM Sponsor s
        LEFT JOIN Sponsor_Person sp ON s.Sponsor_ID = sp.Sponsor_ID
        LEFT JOIN Event e ON e.Sponsor_Person_ID = sp.Sponsor_Person_ID
        LEFT JOIN Donation d ON d.Event_ID = e.Event_ID
        GROUP BY s.Sponsor_ID, s.Name
        ORDER BY total_sponsored DESC
        LIMIT {int(limit)}
    """
    return fetchall(sql)


@app.get("/analytics/recommend")
def analytics_recommend(event_type: Optional[str] = None, limit: int = 10):
    # Recommend sponsors based on Sponsor_Interest matching the event_type text
    # and past sponsorship of similar event types.
    if not event_type:
        # fallback: return top sponsors
        return analytics_top_sponsors(limit=limit)

    # Use simple matching: interests LIKE event_type OR past events with same type
    like_pat = f"%{event_type}%"
    sql = f"""
        SELECT s.Sponsor_ID, s.Name AS sponsor_name,
            COUNT(DISTINCT e.Event_ID) AS past_matches,
            GROUP_CONCAT(DISTINCT si.interest) AS interests
        FROM Sponsor s
        LEFT JOIN Sponsor_Interest si ON s.Sponsor_ID = si.Sponsor_ID
        LEFT JOIN Sponsor_Person sp ON s.Sponsor_ID = sp.Sponsor_ID
        LEFT JOIN Event e ON e.Sponsor_Person_ID = sp.Sponsor_Person_ID
        WHERE (si.interest LIKE %s OR e.Event_Type = %s)
        GROUP BY s.Sponsor_ID, s.Name
        ORDER BY past_matches DESC
        LIMIT {int(limit)}
    """
    return fetchall(sql, [like_pat, event_type])


@app.get("/health")
def health():
    return {"status": "ok"}
