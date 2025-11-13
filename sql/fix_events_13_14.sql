USE ngo_management;

-- Fix Events 13 and 14 to use existing NGOs
UPDATE Event 
SET Event_Type = 'Educational Seminar',
    Location = 'Community Hall A, Mumbai',
    NGO_ID = 1,
    Venue_ID = 1
WHERE Event_ID = 13;

UPDATE Event 
SET Event_Type = 'Health Awareness Camp',
    Start_date = '2025-03-15',
    End_date = '2025-03-16',
    Location = 'Medical Center, Bangalore',
    NGO_ID = 3,
    Venue_ID = 3
WHERE Event_ID = 14;

-- Update Event_Vendor costs for these events
UPDATE Event_Vendor 
SET Service_Details = 'Event planning and coordination',
    Cost = 14000.00
WHERE Event_ID = 13;

UPDATE Event_Vendor 
SET Service_Details = 'Audio visual setup and support',
    Cost = 16000.00
WHERE Event_ID = 14;

SELECT 'Events 13 and 14 have been fixed!' AS message;
