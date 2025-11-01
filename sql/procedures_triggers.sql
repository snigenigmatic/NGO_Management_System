-- Procedures, functions and triggers for Review-3
USE ngo_management;
-- Make script idempotent: drop existing routines/triggers if they exist
DROP FUNCTION IF EXISTS get_ngos_total_donations;
DROP PROCEDURE IF EXISTS add_donation;
DROP PROCEDURE IF EXISTS create_event_and_book_venue;
DROP PROCEDURE IF EXISTS show_ngo_totals;
DROP TRIGGER IF EXISTS trg_before_insert_donation;
DROP TRIGGER IF EXISTS trg_after_update_donation;
DROP TRIGGER IF EXISTS trg_after_insert_event;
-- Audit table for Donation changes
CREATE TABLE IF NOT EXISTS Donation_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    donation_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20),
    old_amount DECIMAL(10, 2),
    new_amount DECIMAL(10, 2),
    note TEXT
);
-- Function: total donations for an NGO
DELIMITER $$ CREATE FUNCTION get_ngos_total_donations(p_ngo_id INT) RETURNS DECIMAL(12, 2) DETERMINISTIC BEGIN
DECLARE v_total DECIMAL(12, 2) DEFAULT 0;
SELECT IFNULL(SUM(Amount), 0) INTO v_total
FROM Donation
WHERE NGO_ID = p_ngo_id;
RETURN v_total;
END $$ DELIMITER;
DELIMITER $$ CREATE PROCEDURE add_donation(
    IN p_receipt VARCHAR(255),
    IN p_date DATE,
    IN p_desc TEXT,
    IN p_amount DECIMAL(10, 2),
    IN p_type VARCHAR(255),
    IN p_donor_id INT,
    IN p_ngo_id INT,
    IN p_event_id INT
) BEGIN -- Basic validation
DECLARE v_count INT DEFAULT 0;
SELECT COUNT(*) INTO v_count
FROM Donor
WHERE Donor_ID = p_donor_id;
IF v_count = 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Donor does not exist';
END IF;
SELECT COUNT(*) INTO v_count
FROM NGO
WHERE NGO_ID = p_ngo_id;
IF v_count = 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'NGO does not exist';
END IF;
IF p_amount <= 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Donation amount must be positive';
END IF;
-- Insert donation
INSERT INTO Donation (
        Receipt_Number,
        Donation_date,
        Description,
        Amount,
        Type,
        Donor_ID,
        NGO_ID,
        Event_ID
    )
VALUES (
        p_receipt,
        p_date,
        p_desc,
        p_amount,
        p_type,
        p_donor_id,
        p_ngo_id,
        p_event_id
    );
END $$ DELIMITER;
DELIMITER $$ CREATE TRIGGER trg_before_insert_donation BEFORE
INSERT ON Donation FOR EACH ROW BEGIN IF NEW.Amount <= 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Amount must be > 0';
END IF;
END $$ DELIMITER;
DELIMITER $$ CREATE TRIGGER trg_after_update_donation
AFTER
UPDATE ON Donation FOR EACH ROW BEGIN IF OLD.Amount IS NULL
    AND NEW.Amount IS NOT NULL
    OR OLD.Amount <> NEW.Amount THEN
INSERT INTO Donation_Audit (
        donation_id,
        action,
        old_amount,
        new_amount,
        note
    )
VALUES (
        NEW.Donation_ID,
        'UPDATE',
        OLD.Amount,
        NEW.Amount,
        CONCAT('Updated by trigger at ', NOW())
    );
END IF;
END $$ DELIMITER;
DELIMITER $$ CREATE TRIGGER trg_after_insert_event
AFTER
INSERT ON Event FOR EACH ROW BEGIN IF NEW.Venue_ID IS NOT NULL THEN
UPDATE Venue
SET Status = 'Booked'
WHERE Venue_ID = NEW.Venue_ID;
END IF;
END $$ DELIMITER;
DELIMITER $$ CREATE PROCEDURE create_event_and_book_venue(
    IN p_event_type VARCHAR(255),
    IN p_start DATE,
    IN p_end DATE,
    IN p_location VARCHAR(255),
    IN p_ngo_id INT,
    IN p_venue_id INT,
    IN p_vendors JSON
) BEGIN
DECLARE i INT DEFAULT 0;
DECLARE n INT DEFAULT 0;
DECLARE vendor_obj JSON;
DECLARE vendor_id INT;
DECLARE v_cost DECIMAL(10, 2);
DECLARE v_details TEXT;
DECLARE new_event_id INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Failed to create event and book venue (rolled back)';
END;
START TRANSACTION;
-- basic checks
IF p_venue_id IS NOT NULL THEN IF (
    SELECT COUNT(*)
    FROM Venue
    WHERE Venue_ID = p_venue_id
        AND Status = 'Available'
) = 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Venue not available or does not exist';
END IF;
END IF;
-- insert event
INSERT INTO Event (
        Event_Type,
        Start_date,
        End_date,
        Location,
        NGO_ID,
        Venue_ID
    )
VALUES (
        p_event_type,
        p_start,
        p_end,
        p_location,
        p_ngo_id,
        p_venue_id
    );
SET new_event_id = LAST_INSERT_ID();
-- attach vendors if provided
IF p_vendors IS NOT NULL
AND JSON_LENGTH(p_vendors) > 0 THEN
SET n = JSON_LENGTH(p_vendors);
SET i = 0;
WHILE i < n DO
SET vendor_obj = JSON_EXTRACT(p_vendors, CONCAT('$[', i, ']'));
SET vendor_id = CAST(
        JSON_EXTRACT(vendor_obj, '$.vendor_id') AS SIGNED
    );
SET v_cost = CAST(
        JSON_EXTRACT(vendor_obj, '$.cost') AS DECIMAL(10, 2)
    );
SET v_details = JSON_UNQUOTE(JSON_EXTRACT(vendor_obj, '$.details'));
INSERT INTO Event_Vendor (
        Event_ID,
        Vendor_ID,
        Service_Details,
        Cost,
        Contract_Date
    )
VALUES (
        new_event_id,
        vendor_id,
        v_details,
        v_cost,
        CURDATE()
    );
SET i = i + 1;
END WHILE;
END IF;
-- book venue (mark as Booked)
IF p_venue_id IS NOT NULL THEN
UPDATE Venue
SET Status = 'Booked'
WHERE Venue_ID = p_venue_id;
END IF;
COMMIT;
END $$ DELIMITER;
DELIMITER $$ CREATE PROCEDURE show_ngo_totals() BEGIN
SELECT NGO_ID,
    NGO_Name,
    get_ngos_total_donations(NGO_ID) AS total_donations
FROM NGO;
END $$ DELIMITER;