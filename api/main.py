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


# ============================================================================
# NGO ENDPOINTS
# ============================================================================

class NGOIn(BaseModel):
    name: str
    registration: str
    address: Optional[str] = None
    phone: Optional[str] = None
    email: str
    type: str


@app.get("/ngos")
def list_ngos():
    """Get all NGOs."""
    return fetchall(
        "SELECT NGO_ID, NGO_Name, Registration_Number, Type, Email, Phone, Address FROM NGO ORDER BY NGO_ID DESC"
    )


@app.post("/ngos")
def create_ngo(ngo: NGOIn):
    """Create a new NGO."""
    try:
        execute(
            """INSERT INTO NGO (NGO_Name, Registration_Number, Address, Phone, Email, Type) 
               VALUES (%s, %s, %s, %s, %s, %s)""",
            [ngo.name, ngo.registration, ngo.address, ngo.phone, ngo.email, ngo.type]
        )
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.put("/ngos/{ngo_id}")
def update_ngo(ngo_id: int, ngo: NGOIn):
    """Update an existing NGO."""
    try:
        execute(
            """UPDATE NGO 
               SET NGO_Name = %s, Registration_Number = %s, Address = %s, 
                   Phone = %s, Email = %s, Type = %s 
               WHERE NGO_ID = %s""",
            [ngo.name, ngo.registration, ngo.address, ngo.phone, ngo.email, ngo.type, ngo_id]
        )
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.delete("/ngos/{ngo_id}")
def delete_ngo(ngo_id: int):
    """Delete an NGO."""
    try:
        execute("DELETE FROM NGO WHERE NGO_ID = %s", [ngo_id])
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/sponsors/recommend")
def recommend_sponsors(q: str):
    """Recommend sponsors for an event description or event_type string.
    Calls the stored procedure `recommend_sponsors_for_event` which returns matching sponsors.
    """
    if not q or not q.strip():
        raise HTTPException(status_code=400, detail="Query parameter 'q' is required")

    try:
        # Call the stored procedure which returns a result set
        rows = fetchall("CALL recommend_sponsors_for_event(%s)", [q])
        return rows
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Recommendation query failed: {e}")


@app.get("/vendors/recommend")
def recommend_vendors(q: str):
    """Recommend vendors for an event description or event_type string.
    Calls the stored procedure `recommend_vendors_for_event` which returns matching vendors.
    """
    if not q or not q.strip():
        raise HTTPException(status_code=400, detail="Query parameter 'q' is required")

    try:
        rows = fetchall("CALL recommend_vendors_for_event(%s)", [q])
        return rows
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Vendor recommendation failed: {e}")


@app.get("/events")
def list_events():
    return fetchall(
        """SELECT e.Event_ID, e.Event_Type, e.Location, e.Venue_ID, 
           v.Status AS venue_status, n.NGO_Name, n.Type AS ngo_type
           FROM Event e 
           LEFT JOIN Venue v ON e.Venue_ID = v.Venue_ID 
           LEFT JOIN NGO n ON e.NGO_ID = n.NGO_ID
           ORDER BY e.Event_ID DESC"""
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


# ============================================================================
# ANALYTICS ENDPOINTS
# ============================================================================

@app.get("/analytics/dashboard")
def analytics_dashboard():
    """Get overall dashboard KPIs and summary statistics."""
    kpis = fetchall("SELECT * FROM vw_dashboard_kpis")
    return {
        "kpis": kpis[0] if kpis else {},
        "recent_donations": fetchall(
            "SELECT Donation_ID, Amount, Donation_date, Type FROM Donation ORDER BY Donation_date DESC LIMIT 10"
        ),
        "upcoming_events": fetchall(
            "SELECT Event_ID, Event_Type, Start_date, Location FROM Event WHERE Start_date >= CURDATE() ORDER BY Start_date LIMIT 10"
        ),
    }


@app.get("/analytics/sponsors")
def analytics_sponsors():
    """Get sponsor engagement analytics."""
    return fetchall("SELECT * FROM vw_sponsor_engagement ORDER BY events_sponsored DESC")


@app.get("/analytics/events")
def analytics_events():
    """Get event ROI and performance analytics."""
    return fetchall("SELECT * FROM vw_event_roi ORDER BY net_impact DESC")


@app.get("/analytics/vendors")
def analytics_vendors():
    """Get vendor performance and usage analytics."""
    return fetchall("SELECT * FROM vw_vendor_performance ORDER BY total_revenue DESC")


@app.get("/analytics/volunteers")
def analytics_volunteers():
    """Get volunteer impact and contribution analytics."""
    return fetchall("SELECT * FROM vw_volunteer_impact ORDER BY total_hours DESC")


@app.get("/analytics/donors")
def analytics_donors():
    """Get donor retention and lifetime value analytics."""
    return fetchall("SELECT * FROM vw_donor_retention ORDER BY lifetime_value DESC")


@app.get("/analytics/donations/by-type")
def analytics_donations_by_type():
    """Get donation breakdown by type (Cash, Online, Check, etc.)."""
    return fetchall("SELECT * FROM vw_donation_by_type ORDER BY total_amount DESC")


@app.get("/analytics/top-donors")
def analytics_top_donors(limit: int = 10):
    """Get top N donors by lifetime value (default 10)."""
    try:
        rows = fetchall("CALL get_top_donors(%s)", [limit])
        return rows
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get top donors: {e}")


@app.get("/analytics/ngo/{ngo_id}/events")
def analytics_ngo_events(ngo_id: int):
    """Get event performance for a specific NGO."""
    try:
        rows = fetchall("CALL get_ngo_event_performance(%s)", [ngo_id])
        return rows
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get NGO event performance: {e}")


@app.get("/analytics/vendor-rankings")
def analytics_vendor_rankings(service_type: str = None):
    """Get vendor rankings, optionally filtered by service type."""
    try:
        rows = fetchall("CALL get_vendor_rankings(%s)", [service_type])
        return rows
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get vendor rankings: {e}")


@app.get("/health")
def health():
    return {"status": "ok"}
