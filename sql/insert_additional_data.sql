USE ngo_management;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- ADDITIONAL DATA INSERT SCRIPT
-- This script adds new data to expand the existing database
-- Run this AFTER the original insert_data_fixed_full.sql
-- Uses INSERT IGNORE to prevent duplication on re-runs
-- ============================================================

-- Insert additional NGOs (6-10) - Doubling from 5 to 10
INSERT IGNORE INTO NGO (
        NGO_ID,
        NGO_Name,
        Registration_Number,
        Address,
        Phone,
        Email,
        Type
    )
VALUES (
        6,
        'Education Excellence Foundation',
        'REG006',
        '201 Knowledge Park, Kolkata, West Bengal',
        '+91-9876543215',
        'contact@educationexcellence.org',
        'Education'
    ),
    (
        7,
        'Rural Development Society',
        'REG007',
        '305 Village Road, Jaipur, Rajasthan',
        '+91-9876543216',
        'info@ruraldevelopment.org',
        'Rural Development'
    ),
    (
        8,
        'Animal Welfare Trust',
        'REG008',
        '450 Pet Street, Hyderabad, Telangana',
        '+91-9876543217',
        'help@animalwelfare.org',
        'Animal Welfare'
    ),
    (
        9,
        'Senior Citizen Care',
        'REG009',
        '789 Elderly Avenue, Ahmedabad, Gujarat',
        '+91-9876543218',
        'support@seniorcare.org',
        'Elder Care'
    ),
    (
        10,
        'Disaster Relief Foundation',
        'REG010',
        '123 Emergency Lane, Surat, Gujarat',
        '+91-9876543219',
        'response@disasterrelief.org',
        'Disaster Management'
    );

-- Insert additional Donors (9-16) - Doubling from 8 to 16
INSERT IGNORE INTO Donor (Donor_ID, Name, Phone, Email)
VALUES (
        9,
        'Deepak Saxena',
        '+91-9123456797',
        'deepak.saxena@email.com'
    ),
    (
        10,
        'Lakshmi Iyer',
        '+91-9123456798',
        'lakshmi.iyer@email.com'
    ),
    (
        11,
        'Manoj Reddy',
        '+91-9123456799',
        'manoj.reddy@email.com'
    ),
    (
        12,
        'Divya Menon',
        '+91-9123456800',
        'divya.menon@email.com'
    ),
    (
        13,
        'Anil Kapoor',
        '+91-9123456801',
        'anil.kapoor@email.com'
    ),
    (
        14,
        'Sneha Pillai',
        '+91-9123456802',
        'sneha.pillai@email.com'
    ),
    (
        15,
        'Rahul Bhatia',
        '+91-9123456803',
        'rahul.bhatia@email.com'
    ),
    (
        16,
        'Pooja Nambiar',
        '+91-9123456804',
        'pooja.nambiar@email.com'
    );

-- Insert additional Volunteers (9-16) - Doubling from 8 to 16
INSERT IGNORE INTO Volunteer (Vol_ID, Name, Email, Phone, Skills)
VALUES (
        9,
        'Vikram Joshi',
        'vikram.joshi@email.com',
        '+91-8123456797',
        'Project Management, Team Building, Strategy'
    ),
    (
        10,
        'Nisha Kapoor',
        'nisha.kapoor@email.com',
        '+91-8123456798',
        'Graphic Design, Content Creation, Branding'
    ),
    (
        11,
        'Rajiv Menon',
        'rajiv.menon@email.com',
        '+91-8123456799',
        'Legal Advice, Documentation, Compliance'
    ),
    (
        12,
        'Priya Desai',
        'priya.desai@email.com',
        '+91-8123456800',
        'Accounting, Finance, Budgeting'
    ),
    (
        13,
        'Suresh Rao',
        'suresh.rao@email.com',
        '+91-8123456801',
        'Healthcare, Nursing, Patient Care'
    ),
    (
        14,
        'Anjali Nair',
        'anjali.nair@email.com',
        '+91-8123456802',
        'Education, Tutoring, Mentoring'
    ),
    (
        15,
        'Kishore Kumar',
        'kishore.kumar@email.com',
        '+91-8123456803',
        'Construction, Maintenance, Repair Work'
    ),
    (
        16,
        'Smita Shah',
        'smita.shah@email.com',
        '+91-8123456804',
        'Animal Care, Training, Veterinary Support'
    );

-- Insert additional Sponsors (6-10) - Doubling from 5 to 10
INSERT IGNORE INTO Sponsor (
        Sponsor_ID,
        Name,
        Contact,
        Email,
        Focus_area,
        Description
    )
VALUES (
        6,
        'EduTech Enterprises',
        '+91-4433221100',
        'info@edutech.com',
        'Education',
        'Supporting vocational training and skill development'
    ),
    (
        7,
        'AgriGrowth Foundation',
        '+91-3322110099',
        'contact@agrigrowth.org',
        'Rural Development',
        'Focuses on rural infrastructure and farming support'
    ),
    (
        8,
        'PawsAndCare Ltd',
        '+91-2211009988',
        'support@pawsandcare.com',
        'Animal Welfare',
        'Funds animal shelters and rescue operations'
    ),
    (
        9,
        'GoldenYears Trust',
        '+91-1100998877',
        'hello@goldenyears.org',
        'Elder Care',
        'Supports senior citizen homes and healthcare'
    ),
    (
        10,
        'SafeRelief Corp',
        '+91-9988776611',
        'reach@saferelief.in',
        'Disaster Management',
        'Provides emergency relief and preparedness training'
    );

-- Insert additional Sponsor_Person (6-10) - Doubling from 5 to 10
INSERT IGNORE INTO Sponsor_Person (
        Sponsor_Person_ID,
        Sponsor_ID,
        Name,
        Email,
        Phone,
        Role
    )
VALUES (
        6,
        6,
        'Anjali Verma',
        'anjali.verma@edutech.com',
        '+91-9000000006',
        'Program Director'
    ),
    (
        7,
        7,
        'Prakash Pillai',
        'prakash.pillai@agrigrowth.org',
        '+91-9000000007',
        'Field Coordinator'
    ),
    (
        8,
        8,
        'Meena Iyer',
        'meena.iyer@pawsandcare.com',
        '+91-9000000008',
        'Community Liaison'
    ),
    (
        9,
        9,
        'Arvind Nair',
        'arvind.nair@goldenyears.org',
        '+91-9000000009',
        'Operations Head'
    ),
    (
        10,
        10,
        'Kavita Desai',
        'kavita.desai@saferelief.in',
        '+91-9000000010',
        'Emergency Coordinator'
    );

-- Insert additional Sponsor_Interest
INSERT IGNORE INTO Sponsor_Interest (Sponsor_ID, interest)
VALUES (6, 'Career Training'),
    (6, 'Digital Skills'),
    (7, 'Organic Farming'),
    (7, 'Water Conservation'),
    (8, 'Pet Adoption'),
    (8, 'Animal Rights'),
    (9, 'Senior Health'),
    (9, 'Assisted Living'),
    (10, 'Emergency Response'),
    (10, 'Community Safety');

-- Insert additional Vendors (8-14) - Doubling from 7 to 14
INSERT IGNORE INTO Vendor (
        Vendor_ID,
        Name,
        Email,
        Address,
        Contact,
        Service_type,
        NGO_ID
    )
VALUES (
        8,
        'Printing Solutions',
        'orders@printingsolutions.com',
        '888 Print Plaza, Kolkata',
        '+91-6123456796',
        'Printing',
        6
    ),
    (
        9,
        'Stage & Setup Co',
        'bookings@stagesetup.com',
        '999 Event Complex, Jaipur',
        '+91-6123456797',
        'Stage Setup',
        7
    ),
    (
        10,
        'Animal Care Supplies',
        'sales@animalcare.com',
        '100 Pet Avenue, Hyderabad',
        '+91-6123456798',
        'Animal Supplies',
        8
    ),
    (
        11,
        'Furniture Rentals',
        'rent@furniturerentals.com',
        '200 Comfort Street, Ahmedabad',
        '+91-6123456799',
        'Furniture',
        9
    ),
    (
        12,
        'Emergency Equipment',
        'contact@emergencyequip.com',
        '300 Safety Hub, Surat',
        '+91-6123456800',
        'Emergency Equipment',
        10
    ),
    (
        13,
        'Event Management Pro',
        'info@eventmanagementpro.com',
        '400 Business Park, Mumbai',
        '+91-6123456801',
        'Event Planning',
        1
    ),
    (
        14,
        'Audio Visual Tech',
        'sales@avtechsolutions.com',
        '500 Tech Avenue, Bangalore',
        '+91-6123456802',
        'Audio/Visual',
        3
    );

-- Insert additional Events (8-14) - Doubling from 7 to 14
-- Note: Events 8-12 have NO sponsors or vendors
-- Only Events 13-14 have vendors assigned
INSERT IGNORE INTO Event (
        Event_ID,
        Event_Type,
        Start_date,
        End_date,
        Location,
        NGO_ID,
        Venue_ID
    )
VALUES (
        8,
        'Career Counseling Workshop',
        '2024-12-15',
        '2024-12-15',
        'Knowledge Park, Kolkata',
        6,
        1
    ),
    (
        9,
        'Rural Healthcare Camp',
        '2025-01-10',
        '2025-01-12',
        'Village Community Center, Jaipur',
        7,
        4
    ),
    (
        10,
        'Pet Adoption Drive',
        '2025-01-20',
        '2025-01-20',
        'Pet Street Park, Hyderabad',
        8,
        2
    ),
    (
        11,
        'Senior Citizen Health Fair',
        '2025-02-05',
        '2025-02-06',
        'Elderly Community Hall, Ahmedabad',
        9,
        3
    ),
    (
        12,
        'Disaster Preparedness Training',
        '2025-02-18',
        '2025-02-18',
        'Emergency Response Center, Surat',
        10,
        5
    ),
    (
        13,
        'Educational Seminar',
        '2025-03-01',
        '2025-03-01',
        'Community Hall A, Mumbai',
        1,
        1
    ),
    (
        14,
        'Health Awareness Camp',
        '2025-03-15',
        '2025-03-16',
        'Medical Center, Bangalore',
        3,
        3
    );

-- Insert additional Donations (11-20) - Doubling from 10 to 20
INSERT IGNORE INTO Donation (
        Donation_ID,
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
        11,
        'RCP011',
        '2024-11-01',
        'Support for education programs',
        3500.00,
        'Cash',
        3,
        6,
        8
    ),
    (
        12,
        'RCP012',
        '2024-11-03',
        'Rural development support',
        5500.00,
        'Online',
        4,
        7,
        NULL
    ),
    (
        13,
        'RCP013',
        '2024-11-05',
        'Animal welfare donation',
        2800.00,
        'Cheque',
        5,
        8,
        10
    ),
    (
        14,
        'RCP014',
        '2024-11-08',
        'Senior citizen care fund',
        4200.00,
        'Cash',
        6,
        9,
        NULL
    ),
    (
        15,
        'RCP015',
        '2024-11-10',
        'Emergency relief fund',
        9000.00,
        'Online',
        7,
        10,
        NULL
    ),
    (
        16,
        'RCP016',
        '2024-11-12',
        'General donation',
        6500.00,
        'Cheque',
        8,
        1,
        13
    ),
    (
        17,
        'RCP017',
        '2024-11-15',
        'Health awareness support',
        7200.00,
        'Online',
        1,
        3,
        14
    ),
    (
        18,
        'RCP018',
        '2024-11-18',
        'General donation',
        3200.00,
        'Cash',
        9,
        6,
        8
    ),
    (
        19,
        'RCP019',
        '2024-11-20',
        'Health camp support',
        4800.00,
        'Online',
        10,
        7,
        9
    ),
    (
        20,
        'RCP020',
        '2024-11-22',
        'Community development',
        5300.00,
        'Cheque',
        11,
        1,
        NULL
    );

-- Insert Event_Vendor relationships
-- Adding vendor costs for several events to make analytics more interesting
INSERT IGNORE INTO Event_Vendor (
        Event_ID,
        Vendor_ID,
        Service_Details,
        Cost,
        Contract_Date
    )
VALUES (
        8,
        8,
        'Printed materials and handouts',
        5500.00,
        '2024-12-10'
    ),
    (
        9,
        9,
        'Stage setup and equipment',
        8500.00,
        '2025-01-05'
    ),
    (
        10,
        10,
        'Animal care supplies and adoption kits',
        6200.00,
        '2025-01-15'
    ),
    (
        11,
        11,
        'Furniture and seating arrangements',
        7800.00,
        '2025-02-01'
    ),
    (
        12,
        12,
        'Emergency equipment and training materials',
        9500.00,
        '2025-02-12'
    ),
    (
        13,
        13,
        'Event planning and coordination',
        14000.00,
        '2025-02-25'
    ),
    (
        14,
        14,
        'Audio visual setup and support',
        16000.00,
        '2025-03-10'
    );

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- DATA SUMMARY
-- ============================================================
-- NGOs: 5 → 10 (added 5: IDs 6-10, REG006-REG010)
-- Donors: 8 → 16 (added 8: IDs 9-16)
-- Volunteers: 8 → 16 (added 8: IDs 9-16)
-- Sponsors: 5 → 10 (added 5: IDs 6-10)
-- Sponsor_Person: 5 → 10 (added 5: IDs 6-10)
-- Vendors: 7 → 14 (added 7: IDs 8-14)
-- Events: 7 → 14 (added 7: IDs 8-14)
--   - All new events (8-14) now have vendor costs assigned
-- Donations: 10 → 20 (added 10: IDs 11-20)
-- Event_Vendor: Added vendor relationships for Events 8-14
-- ============================================================
-- NOTE: Uses INSERT IGNORE - safe to re-run without duplication
-- ============================================================
