CREATE DATABASE IF NOT EXISTS ngo_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ngo_management;
-- NGO table
CREATE TABLE IF NOT EXISTS NGO (
    NGO_ID INT PRIMARY KEY AUTO_INCREMENT,
    NGO_Name VARCHAR(255) NOT NULL,
    Registration_Number VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255),
    Phone VARCHAR(255),
    Email VARCHAR(255) NOT NULL UNIQUE,
    Type VARCHAR(255) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Vendor table
CREATE TABLE IF NOT EXISTS Vendor (
    Vendor_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Address VARCHAR(255),
    Contact VARCHAR(255),
    Service_type VARCHAR(255) NOT NULL,
    NGO_ID INT NOT NULL,
    INDEX idx_vendor_ngo (NGO_ID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Venue table
CREATE TABLE IF NOT EXISTS Venue (
    Venue_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Contact VARCHAR(255),
    Capacity INT CHECK (Capacity > 0),
    Type VARCHAR(255) NOT NULL,
    Status VARCHAR(255) DEFAULT 'Available'
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Sponsor table
CREATE TABLE IF NOT EXISTS Sponsor (
    Sponsor_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Contact VARCHAR(255),
    Email VARCHAR(255),
    Focus_area VARCHAR(255),
    Description TEXT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Sponsor_Person table
CREATE TABLE IF NOT EXISTS Sponsor_Person (
    Sponsor_Person_ID INT PRIMARY KEY AUTO_INCREMENT,
    Sponsor_ID INT,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    Phone VARCHAR(255),
    Role VARCHAR(255),
    CONSTRAINT fk_sp_person_sponsor FOREIGN KEY (Sponsor_ID) REFERENCES Sponsor (Sponsor_ID) ON DELETE
    SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Event table
CREATE TABLE IF NOT EXISTS Event (
    Event_ID INT PRIMARY KEY AUTO_INCREMENT,
    Event_Type VARCHAR(255) NOT NULL,
    Start_date DATE NOT NULL,
    End_date DATE,
    Location VARCHAR(255),
    NGO_ID INT NOT NULL,
    Venue_ID INT,
    Sponsor_Person_ID INT NULL,
    -- Added for sponsor tracking
    CHECK (
        End_date IS NULL
        OR Start_date <= End_date
    ),
    INDEX idx_event_ngo (NGO_ID),
    INDEX idx_event_venue (Venue_ID),
    INDEX idx_event_sponsor_person (Sponsor_Person_ID),
    CONSTRAINT fk_event_sponsor_person FOREIGN KEY (Sponsor_Person_ID) REFERENCES Sponsor_Person (Sponsor_Person_ID) ON DELETE
    SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Volunteer table
CREATE TABLE IF NOT EXISTS Volunteer (
    Vol_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(255),
    Skills TEXT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Event_task table
CREATE TABLE IF NOT EXISTS Event_task (
    Task_ID INT PRIMARY KEY AUTO_INCREMENT,
    Event_ID INT NOT NULL,
    Vol_ID INT NOT NULL,
    Task_description TEXT NOT NULL,
    Status VARCHAR(255) DEFAULT 'Pending',
    INDEX idx_et_event (Event_ID),
    INDEX idx_et_vol (Vol_ID),
    UNIQUE KEY ux_event_vol_task (Event_ID, Vol_ID, Task_description(100))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Volunteer_involvement table
CREATE TABLE IF NOT EXISTS Volunteer_involvement (
    Involvement_ID INT PRIMARY KEY AUTO_INCREMENT,
    Volunteer_ID INT NOT NULL,
    Event_ID INT NOT NULL,
    Hours_contributed INT CHECK (Hours_contributed >= 0),
    Feedback TEXT,
    INDEX idx_vi_vol (Volunteer_ID),
    INDEX idx_vi_event (Event_ID),
    UNIQUE KEY ux_vol_event (Volunteer_ID, Event_ID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Donor table
CREATE TABLE IF NOT EXISTS Donor (
    Donor_ID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Phone VARCHAR(255),
    Email VARCHAR(255) UNIQUE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Donation table
CREATE TABLE IF NOT EXISTS Donation (
    Donation_ID INT PRIMARY KEY AUTO_INCREMENT,
    Receipt_Number VARCHAR(255) NOT NULL UNIQUE,
    Donation_date DATE NOT NULL,
    Description TEXT,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    Type VARCHAR(255) NOT NULL,
    Donor_ID INT NOT NULL,
    NGO_ID INT NOT NULL,
    Event_ID INT,
    INDEX idx_donor (Donor_ID),
    INDEX idx_donation_ngo (NGO_ID),
    INDEX idx_donation_event (Event_ID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Event_Vendor junction table
CREATE TABLE IF NOT EXISTS Event_Vendor (
    Event_ID INT,
    Vendor_ID INT,
    Service_Details TEXT,
    Cost DECIMAL(10, 2) CHECK (Cost >= 0),
    Contract_Date DATE,
    PRIMARY KEY (Event_ID, Vendor_ID),
    INDEX idx_ev_event (Event_ID),
    INDEX idx_ev_vendor (Vendor_ID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Sponsor_Interest table
CREATE TABLE IF NOT EXISTS Sponsor_Interest (
    Sponsor_ID INT NOT NULL,
    interest VARCHAR(255) NOT NULL,
    PRIMARY KEY (Sponsor_ID, interest(150)),
    INDEX idx_si_sponsor (Sponsor_ID),
    INDEX idx_si_interest (interest(150)),
    CONSTRAINT fk_si_sponsor FOREIGN KEY (Sponsor_ID) REFERENCES Sponsor (Sponsor_ID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Add Foreign Key Constraints
ALTER TABLE Vendor
ADD CONSTRAINT fk_vendor_ngo FOREIGN KEY (NGO_ID) REFERENCES NGO (NGO_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE Event
ADD CONSTRAINT fk_event_ngo FOREIGN KEY (NGO_ID) REFERENCES NGO (NGO_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_event_venue FOREIGN KEY (Venue_ID) REFERENCES Venue (Venue_ID) ON DELETE
SET NULL ON UPDATE CASCADE;
ALTER TABLE Event_task
ADD CONSTRAINT fk_event_task_event FOREIGN KEY (Event_ID) REFERENCES Event (Event_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_event_task_volunteer FOREIGN KEY (Vol_ID) REFERENCES Volunteer (Vol_ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE Volunteer_involvement
ADD CONSTRAINT fk_volunteer_involvement_volunteer FOREIGN KEY (Volunteer_ID) REFERENCES Volunteer (Vol_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_volunteer_involvement_event FOREIGN KEY (Event_ID) REFERENCES Event (Event_ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE Donation
ADD CONSTRAINT fk_donation_donor FOREIGN KEY (Donor_ID) REFERENCES Donor (Donor_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_donation_ngo FOREIGN KEY (NGO_ID) REFERENCES NGO (NGO_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_donation_event FOREIGN KEY (Event_ID) REFERENCES Event (Event_ID) ON DELETE
SET NULL ON UPDATE CASCADE;
ALTER TABLE Event_Vendor
ADD CONSTRAINT fk_event_vendor_event FOREIGN KEY (Event_ID) REFERENCES Event (Event_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_event_vendor_vendor FOREIGN KEY (Vendor_ID) REFERENCES Vendor (Vendor_ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE Sponsor_Person
ADD CONSTRAINT fk_sponsor_person_sponsor FOREIGN KEY (Sponsor_ID) REFERENCES Sponsor (Sponsor_ID) ON DELETE CASCADE ON UPDATE CASCADE;