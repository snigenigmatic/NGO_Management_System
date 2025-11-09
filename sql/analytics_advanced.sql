-- Advanced Analytics Views and Procedures
-- Run this after analytics_views.sql to add enhanced analytics capabilities
USE ngo_management;

-- ============================================================================
-- SPONSOR ANALYTICS
-- ============================================================================

-- View: Sponsor engagement summary (total sponsors, events with sponsors, avg focus match)
DROP VIEW IF EXISTS vw_sponsor_engagement;
CREATE OR REPLACE VIEW vw_sponsor_engagement AS
SELECT 
    s.Sponsor_ID,
    s.Name AS sponsor_name,
    s.Focus_area,
    COUNT(DISTINCT e.Event_ID) AS events_sponsored,
    COUNT(DISTINCT si.interest) AS interest_count,
    GROUP_CONCAT(DISTINCT si.interest ORDER BY si.interest SEPARATOR ', ') AS interests
FROM Sponsor s
LEFT JOIN Sponsor_Person sp ON s.Sponsor_ID = sp.Sponsor_ID
LEFT JOIN Event e ON e.Sponsor_Person_ID = sp.Sponsor_Person_ID
LEFT JOIN Sponsor_Interest si ON s.Sponsor_ID = si.Sponsor_ID
GROUP BY s.Sponsor_ID, s.Name, s.Focus_area;


-- ============================================================================
-- EVENT ANALYTICS
-- ============================================================================

-- View: Event ROI analysis (donations vs costs)
DROP VIEW IF EXISTS vw_event_roi;
CREATE OR REPLACE VIEW vw_event_roi AS
SELECT 
    e.Event_ID,
    e.Event_Type,
    e.Location,
    e.Start_date,
    e.End_date,
    IFNULL(SUM(ev.Cost), 0) AS total_cost,
    IFNULL(SUM(d.Amount), 0) AS donations_raised,
    IFNULL(SUM(d.Amount), 0) - IFNULL(SUM(ev.Cost), 0) AS net_impact,
    COUNT(DISTINCT vi.Volunteer_ID) AS volunteer_count,
    IFNULL(SUM(vi.Hours_contributed), 0) AS total_volunteer_hours
FROM Event e
LEFT JOIN Event_Vendor ev ON e.Event_ID = ev.Event_ID
LEFT JOIN Donation d ON e.Event_ID = d.Event_ID
LEFT JOIN Volunteer_involvement vi ON e.Event_ID = vi.Event_ID
GROUP BY e.Event_ID, e.Event_Type, e.Location, e.Start_date, e.End_date;


-- ============================================================================
-- VENDOR ANALYTICS
-- ============================================================================

-- View: Vendor performance and usage
DROP VIEW IF EXISTS vw_vendor_performance;
CREATE OR REPLACE VIEW vw_vendor_performance AS
SELECT 
    v.Vendor_ID,
    v.Name AS vendor_name,
    v.Service_type,
    COUNT(DISTINCT ev.Event_ID) AS events_served,
    IFNULL(SUM(ev.Cost), 0) AS total_revenue,
    IFNULL(AVG(ev.Cost), 0) AS avg_cost_per_event,
    MIN(ev.Contract_Date) AS first_contract,
    MAX(ev.Contract_Date) AS latest_contract
FROM Vendor v
LEFT JOIN Event_Vendor ev ON v.Vendor_ID = ev.Vendor_ID
GROUP BY v.Vendor_ID, v.Name, v.Service_type;


-- ============================================================================
-- VOLUNTEER ANALYTICS
-- ============================================================================

-- View: Top volunteers by contribution
DROP VIEW IF EXISTS vw_volunteer_impact;
CREATE OR REPLACE VIEW vw_volunteer_impact AS
SELECT 
    vol.Vol_ID,
    vol.Name AS volunteer_name,
    vol.Skills,
    COUNT(DISTINCT vi.Event_ID) AS events_participated,
    IFNULL(SUM(vi.Hours_contributed), 0) AS total_hours,
    IFNULL(AVG(vi.Hours_contributed), 0) AS avg_hours_per_event
FROM Volunteer vol
LEFT JOIN Volunteer_involvement vi ON vol.Vol_ID = vi.Volunteer_ID
GROUP BY vol.Vol_ID, vol.Name, vol.Skills;


-- ============================================================================
-- DONATION ANALYTICS
-- ============================================================================

-- View: Donor retention and frequency
DROP VIEW IF EXISTS vw_donor_retention;
CREATE OR REPLACE VIEW vw_donor_retention AS
SELECT 
    d.Donor_ID,
    d.Name AS donor_name,
    COUNT(dn.Donation_ID) AS donation_count,
    IFNULL(SUM(dn.Amount), 0) AS lifetime_value,
    IFNULL(AVG(dn.Amount), 0) AS avg_donation,
    MIN(dn.Donation_date) AS first_donation,
    MAX(dn.Donation_date) AS latest_donation,
    DATEDIFF(MAX(dn.Donation_date), MIN(dn.Donation_date)) AS days_active
FROM Donor d
LEFT JOIN Donation dn ON d.Donor_ID = dn.Donor_ID
GROUP BY d.Donor_ID, d.Name;

-- View: Donation by type breakdown
DROP VIEW IF EXISTS vw_donation_by_type;
CREATE OR REPLACE VIEW vw_donation_by_type AS
SELECT 
    dn.Type AS donation_type,
    COUNT(*) AS donation_count,
    IFNULL(SUM(dn.Amount), 0) AS total_amount,
    IFNULL(AVG(dn.Amount), 0) AS avg_amount
FROM Donation dn
GROUP BY dn.Type;


-- ============================================================================
-- DASHBOARD SUMMARY
-- ============================================================================

-- View: Overall system KPIs
DROP VIEW IF EXISTS vw_dashboard_kpis;
CREATE OR REPLACE VIEW vw_dashboard_kpis AS
SELECT 
    (SELECT COUNT(*) FROM NGO) AS total_ngos,
    (SELECT COUNT(*) FROM Donor) AS total_donors,
    (SELECT COUNT(*) FROM Volunteer) AS total_volunteers,
    (SELECT COUNT(*) FROM Event) AS total_events,
    (SELECT IFNULL(SUM(Amount), 0) FROM Donation) AS total_donations,
    (SELECT COUNT(*) FROM Sponsor) AS total_sponsors,
    (SELECT COUNT(*) FROM Vendor) AS total_vendors;


-- ============================================================================
-- STORED PROCEDURES FOR ANALYTICS
-- ============================================================================

DELIMITER $$

-- Procedure: Get top N donors by lifetime value
DROP PROCEDURE IF EXISTS get_top_donors$$
CREATE PROCEDURE get_top_donors(IN top_n INT)
BEGIN
    SELECT 
        donor_name,
        donation_count,
        lifetime_value,
        avg_donation,
        first_donation,
        latest_donation
    FROM vw_donor_retention
    ORDER BY lifetime_value DESC
    LIMIT top_n;
END $$

-- Procedure: Get event performance for a specific NGO
DROP PROCEDURE IF EXISTS get_ngo_event_performance$$
CREATE PROCEDURE get_ngo_event_performance(IN p_ngo_id INT)
BEGIN
    SELECT 
        e.Event_ID,
        e.Event_Type,
        e.Location,
        roi.total_cost,
        roi.donations_raised,
        roi.net_impact,
        roi.volunteer_count,
        roi.total_volunteer_hours
    FROM Event e
    JOIN vw_event_roi roi ON e.Event_ID = roi.Event_ID
    WHERE e.NGO_ID = p_ngo_id
    ORDER BY roi.net_impact DESC;
END $$

-- Procedure: Get vendor rankings by service type
DROP PROCEDURE IF EXISTS get_vendor_rankings$$
CREATE PROCEDURE get_vendor_rankings(IN p_service_type VARCHAR(255))
BEGIN
    SELECT 
        vendor_name,
        Service_type,
        events_served,
        total_revenue,
        avg_cost_per_event
    FROM vw_vendor_performance
    WHERE p_service_type IS NULL OR Service_type = p_service_type
    ORDER BY events_served DESC, total_revenue DESC;
END $$

DELIMITER ;

-- Notes:
-- 1. These views provide ready-to-use analytics data for dashboards and reports
-- 2. Procedures allow parameterized queries for filtering (e.g., by NGO, date range, etc.)
-- 3. To extend: add date range filters, add more KPIs, create materialized snapshots for performance
