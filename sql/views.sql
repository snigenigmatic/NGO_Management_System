-- Views for reporting and quick checks
USE ngo_management;
-- Recreate views safely on each run
DROP VIEW IF EXISTS vw_vendor_contracts;
DROP VIEW IF EXISTS vw_event_volunteer_hours;
DROP VIEW IF EXISTS vw_monthly_donations;
DROP VIEW IF EXISTS vw_ngo_summary;
-- View: NGO summary - total donations and donor count
CREATE OR REPLACE VIEW vw_ngo_summary AS
SELECT n.NGO_ID,
    n.NGO_Name,
    IFNULL(SUM(d.Amount), 0) AS total_donations,
    COUNT(DISTINCT d.Donor_ID) AS donor_count
FROM NGO n
    LEFT JOIN Donation d ON n.NGO_ID = d.NGO_ID
GROUP BY n.NGO_ID,
    n.NGO_Name;
-- View: Monthly donations (year-month, ngo, amount)
CREATE OR REPLACE VIEW vw_monthly_donations AS
SELECT DATE_FORMAT(d.Donation_date, '%Y-%m') AS `year_month`,
    d.NGO_ID AS `NGO_ID`,
    SUM(d.Amount) AS `total_amount`,
    COUNT(*) AS `donation_count`
FROM Donation d
GROUP BY d.NGO_ID,
    DATE_FORMAT(d.Donation_date, '%Y-%m');
-- View: Event volunteer hours
CREATE OR REPLACE VIEW vw_event_volunteer_hours AS
SELECT e.Event_ID,
    e.Event_Type,
    e.Location,
    IFNULL(SUM(vh.Hours_contributed), 0) AS total_hours
FROM Event e
    LEFT JOIN Volunteer_involvement vh ON e.Event_ID = vh.Event_ID
GROUP BY e.Event_ID,
    e.Event_Type,
    e.Location;
-- View: Active vendor contracts
CREATE OR REPLACE VIEW vw_vendor_contracts AS
SELECT ev.Event_ID,
    ev.Vendor_ID,
    v.Name AS vendor_name,
    ev.Cost,
    ev.Contract_Date
FROM Event_Vendor ev
    JOIN Vendor v ON ev.Vendor_ID = v.Vendor_ID;