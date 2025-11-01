-- Additional audit tables and triggers for Vendor, Event, Volunteer
USE ngo_management;
-- Drop audit triggers if they already exist (make script safe to re-run)
DROP TRIGGER IF EXISTS trg_after_insert_vendor;
DROP TRIGGER IF EXISTS trg_after_update_vendor;
DROP TRIGGER IF EXISTS trg_after_delete_vendor;
DROP TRIGGER IF EXISTS trg_after_insert_event_audit;
DROP TRIGGER IF EXISTS trg_after_update_event_audit;
DROP TRIGGER IF EXISTS trg_after_delete_event_audit;
DROP TRIGGER IF EXISTS trg_after_insert_volunteer;
DROP TRIGGER IF EXISTS trg_after_update_volunteer;
DROP TRIGGER IF EXISTS trg_after_delete_volunteer;
CREATE TABLE IF NOT EXISTS Vendor_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    vendor_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20),
    old_data JSON,
    new_data JSON
);
CREATE TABLE IF NOT EXISTS Event_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20),
    old_data JSON,
    new_data JSON
);
CREATE TABLE IF NOT EXISTS Volunteer_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    volunteer_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20),
    old_data JSON,
    new_data JSON
);
DELIMITER $$ CREATE TRIGGER trg_after_insert_vendor
AFTER
INSERT ON Vendor FOR EACH ROW BEGIN
INSERT INTO Vendor_Audit (vendor_id, action, new_data)
VALUES (
        NEW.Vendor_ID,
        'INSERT',
        JSON_OBJECT(
            'name',
            NEW.Name,
            'email',
            NEW.Email,
            'service',
            NEW.Service_type
        )
    );
END $$ CREATE TRIGGER trg_after_update_vendor
AFTER
UPDATE ON Vendor FOR EACH ROW BEGIN
INSERT INTO Vendor_Audit (vendor_id, action, old_data, new_data)
VALUES (
        OLD.Vendor_ID,
        'UPDATE',
        JSON_OBJECT(
            'name',
            OLD.Name,
            'email',
            OLD.Email,
            'service',
            OLD.Service_type
        ),
        JSON_OBJECT(
            'name',
            NEW.Name,
            'email',
            NEW.Email,
            'service',
            NEW.Service_type
        )
    );
END $$ CREATE TRIGGER trg_after_delete_vendor
AFTER DELETE ON Vendor FOR EACH ROW BEGIN
INSERT INTO Vendor_Audit (vendor_id, action, old_data)
VALUES (
        OLD.Vendor_ID,
        'DELETE',
        JSON_OBJECT(
            'name',
            OLD.Name,
            'email',
            OLD.Email,
            'service',
            OLD.Service_type
        )
    );
END $$ CREATE TRIGGER trg_after_insert_event_audit
AFTER
INSERT ON Event FOR EACH ROW BEGIN
INSERT INTO Event_Audit (event_id, action, new_data)
VALUES (
        NEW.Event_ID,
        'INSERT',
        JSON_OBJECT(
            'type',
            NEW.Event_Type,
            'start',
            NEW.Start_date,
            'end',
            NEW.End_date
        )
    );
END $$ CREATE TRIGGER trg_after_update_event_audit
AFTER
UPDATE ON Event FOR EACH ROW BEGIN
INSERT INTO Event_Audit (event_id, action, old_data, new_data)
VALUES (
        OLD.Event_ID,
        'UPDATE',
        JSON_OBJECT(
            'type',
            OLD.Event_Type,
            'start',
            OLD.Start_date,
            'end',
            OLD.End_date
        ),
        JSON_OBJECT(
            'type',
            NEW.Event_Type,
            'start',
            NEW.Start_date,
            'end',
            NEW.End_date
        )
    );
END $$ CREATE TRIGGER trg_after_delete_event_audit
AFTER DELETE ON Event FOR EACH ROW BEGIN
INSERT INTO Event_Audit (event_id, action, old_data)
VALUES (
        OLD.Event_ID,
        'DELETE',
        JSON_OBJECT(
            'type',
            OLD.Event_Type,
            'start',
            OLD.Start_date,
            'end',
            OLD.End_date
        )
    );
END $$ CREATE TRIGGER trg_after_insert_volunteer
AFTER
INSERT ON Volunteer FOR EACH ROW BEGIN
INSERT INTO Volunteer_Audit (volunteer_id, action, new_data)
VALUES (
        NEW.Vol_ID,
        'INSERT',
        JSON_OBJECT('name', NEW.Name, 'email', NEW.Email)
    );
END $$ CREATE TRIGGER trg_after_update_volunteer
AFTER
UPDATE ON Volunteer FOR EACH ROW BEGIN
INSERT INTO Volunteer_Audit (volunteer_id, action, old_data, new_data)
VALUES (
        OLD.Vol_ID,
        'UPDATE',
        JSON_OBJECT('name', OLD.Name, 'email', OLD.Email),
        JSON_OBJECT('name', NEW.Name, 'email', NEW.Email)
    );
END $$ CREATE TRIGGER trg_after_delete_volunteer
AFTER DELETE ON Volunteer FOR EACH ROW BEGIN
INSERT INTO Volunteer_Audit (volunteer_id, action, old_data)
VALUES (
        OLD.Vol_ID,
        'DELETE',
        JSON_OBJECT('name', OLD.Name, 'email', OLD.Email)
    );
END $$ DELIMITER;