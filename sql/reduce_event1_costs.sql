USE ngo_management;

-- Reduce Educational Workshop (Event 1) costs to balance the analytics
-- Current total: ₹23,000 (₹15,000 + ₹8,000)
-- New total: ₹8,500 (₹5,500 + ₹3,000)

UPDATE Event_Vendor 
SET Cost = 5500.00
WHERE Event_ID = 1 AND Vendor_ID = 1;

UPDATE Event_Vendor 
SET Cost = 3000.00
WHERE Event_ID = 1 AND Vendor_ID = 6;

-- Verify the changes
SELECT 
    e.Event_ID,
    e.Event_Type,
    SUM(ev.Cost) AS total_cost
FROM Event e
LEFT JOIN Event_Vendor ev ON e.Event_ID = ev.Event_ID
WHERE e.Event_ID = 1
GROUP BY e.Event_ID, e.Event_Type;

SELECT 'Educational Workshop costs reduced from ₹23,000 to ₹8,500' AS message;
