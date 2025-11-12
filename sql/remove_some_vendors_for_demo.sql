-- Remove vendors from some events to demonstrate vendor recommendations
-- This will create a mix of events with/without vendors for demo purposes

USE ngo_management;

-- Remove vendors from events 8, 10, 12 (keep sponsors if they exist)
-- This will make these events show vendor recommendations

DELETE FROM Event_Vendor WHERE Event_ID = 8;  -- Career Counseling Workshop
DELETE FROM Event_Vendor WHERE Event_ID = 10; -- Pet Adoption Drive
DELETE FROM Event_Vendor WHERE Event_ID = 12; -- Disaster Preparedness Training

-- Optionally, remove vendors from event 2 (which has a sponsor)
-- This will show sponsor-only scenario
DELETE FROM Event_Vendor WHERE Event_ID = 2;  -- Tree Plantation Drive

-- Summary after this script:
-- Events 1, 3, 4, 5: BOTH vendor and sponsor (button disabled)
-- Event 2: SPONSOR only (will show vendor recommendations)
-- Events 9, 11, 13, 14: VENDOR only (will show sponsor recommendations)
-- Events 6, 7, 8, 10, 12, 18: NEITHER (will show both recommendations)

SELECT 'Vendors removed successfully for demo purposes' AS Status;
