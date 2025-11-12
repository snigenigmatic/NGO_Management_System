USE ngo_management;

-- Fix the vw_event_roi view to prevent cartesian product
DROP VIEW IF EXISTS vw_event_roi;
CREATE OR REPLACE VIEW vw_event_roi AS
SELECT 
    e.Event_ID,
    e.Event_Type,
    e.Location,
    e.Start_date,
    e.End_date,
    COALESCE(ev_totals.total_cost, 0) AS total_cost,
    COALESCE(d_totals.donations_raised, 0) AS donations_raised,
    COALESCE(d_totals.donations_raised, 0) - COALESCE(ev_totals.total_cost, 0) AS net_impact,
    COALESCE(vi_stats.volunteer_count, 0) AS volunteer_count,
    COALESCE(vi_stats.total_volunteer_hours, 0) AS total_volunteer_hours
FROM Event e
LEFT JOIN (
    SELECT Event_ID, SUM(Cost) AS total_cost
    FROM Event_Vendor
    GROUP BY Event_ID
) ev_totals ON e.Event_ID = ev_totals.Event_ID
LEFT JOIN (
    SELECT Event_ID, SUM(Amount) AS donations_raised
    FROM Donation
    GROUP BY Event_ID
) d_totals ON e.Event_ID = d_totals.Event_ID
LEFT JOIN (
    SELECT Event_ID, 
           COUNT(DISTINCT Volunteer_ID) AS volunteer_count,
           SUM(Hours_contributed) AS total_volunteer_hours
    FROM Volunteer_involvement
    GROUP BY Event_ID
) vi_stats ON e.Event_ID = vi_stats.Event_ID;

SELECT 'View vw_event_roi has been fixed! No more cartesian product.' AS message;
