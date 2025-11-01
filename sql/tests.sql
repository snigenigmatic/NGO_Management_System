-- Quick test script to run checks on existing DB objects (idempotent where possible)
USE ngo_management;
-- Create/refresh routines and views
SOURCE procedures_triggers.sql;
SOURCE views.sql;
-- 4) Run a few checks
SELECT 'NGO summary' AS info;
SELECT *
FROM vw_ngo_summary;
SELECT 'Monthly donations' AS info;
SELECT *
FROM vw_monthly_donations;
SELECT 'Event volunteer hours' AS info;
SELECT *
FROM vw_event_volunteer_hours;
-- 5) Try stored procedure add_donation (example)
-- Generate a highly-unique receipt per run (timestamp + random suffix)
SET @rcp := CONCAT(
        'RCP',
        DATE_FORMAT(NOW(), '%Y%m%d%H%i%S'),
        LPAD(FLOOR(RAND() * 1000000), 6, '0')
    );
CALL add_donation(
    @rcp,
    CURDATE(),
    'Test donation via proc',
    100.00,
    'Cash',
    1,
    1,
    1
);
-- 6) Check audit table by updating a donation
UPDATE Donation
SET Amount = Amount + 50
WHERE Donation_ID = 1;
SELECT *
FROM Donation_Audit
ORDER BY changed_at DESC
LIMIT 10;
SELECT 'Tests completed' AS Message;