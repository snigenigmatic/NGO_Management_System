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
    return fetchall(
        "SELECT e.Event_ID, e.Event_Type, e.Location, e.Venue_ID, v.Status AS venue_status FROM Event e LEFT JOIN Venue v ON e.Venue_ID = v.Venue_ID ORDER BY e.Event_ID DESC"
    )


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


@app.get("/health")
def health():
    return {"status": "ok"}
