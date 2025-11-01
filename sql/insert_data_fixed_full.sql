-- Repaired full insert script (clean copy of original `insert_data.sql`)
-- Safe to run on MySQL 8.0.43. Assumes `ddl_fixed.sql` or original `ddl.sql` has been applied.
USE ngo_management;
SET FOREIGN_KEY_CHECKS = 0;
-- Insert data into NGO table
INSERT INTO NGO (
        NGO_ID,
        NGO_Name,
        Registration_Number,
        Address,
        Phone,
        Email,
        Type
    )
VALUES (
        1,
        'Hope Foundation',
        'REG001',
        '123 Main Street, Mumbai, Maharashtra',
        '+91-9876543210',
        'info@hopefoundation.org',
        'Education'
    ),
    (
        2,
        'Green Earth Initiative',
        'REG002',
        '456 Park Avenue, Delhi, Delhi',
        '+91-9876543211',
        'contact@greenearth.org',
        'Environment'
    ),
    (
        3,
        'Health for All',
        'REG003',
        '789 Medical Complex, Bangalore, Karnataka',
        '+91-9876543212',
        'admin@healthforall.org',
        'Healthcare'
    ),
    (
        4,
        'Child Welfare Society',
        'REG004',
        '321 Children Street, Chennai, Tamil Nadu',
        '+91-9876543213',
        'info@childwelfare.org',
        'Child Welfare'
    ),
    (
        5,
        'Women Empowerment Trust',
        'REG005',
        '654 Empowerment Road, Pune, Maharashtra',
        '+91-9876543214',
        'support@womenempowerment.org',
        'Women Empowerment'
    );
-- Insert data into Donor table
INSERT INTO Donor (Donor_ID, Name, Phone, Email)
VALUES (
        1,
        'Rajesh Kumar',
        '+91-9123456789',
        'rajesh.kumar@email.com'
    ),
    (
        2,
        'Priya Sharma',
        '+91-9123456790',
        'priya.sharma@email.com'
    ),
    (
        3,
        'Amit Patel',
        '+91-9123456791',
        'amit.patel@email.com'
    ),
    (
        4,
        'Sunita Rao',
        '+91-9123456792',
        'sunita.rao@email.com'
    ),
    (
        5,
        'Vikram Singh',
        '+91-9123456793',
        'vikram.singh@email.com'
    ),
    (
        6,
        'Meera Gupta',
        '+91-9123456794',
        'meera.gupta@email.com'
    ),
    (
        7,
        'Arjun Desai',
        '+91-9123456795',
        'arjun.desai@email.com'
    ),
    (
        8,
        'Kavita Joshi',
        '+91-9123456796',
        'kavita.joshi@email.com'
    );
-- Insert data into Volunteer table
INSERT INTO Volunteer (Vol_ID, Name, Email, Phone, Skills)
VALUES (
        1,
        'Ananya Reddy',
        'ananya.reddy@email.com',
        '+91-8123456789',
        'Teaching, Communication, Event Management'
    ),
    (
        2,
        'Rohit Verma',
        'rohit.verma@email.com',
        '+91-8123456790',
        'Photography, Social Media, Marketing'
    ),
    (
        3,
        'Neha Agarwal',
        'neha.agarwal@email.com',
        '+91-8123456791',
        'Medical Knowledge, First Aid, Counseling'
    ),
    (
        4,
        'Karan Malhotra',
        'karan.malhotra@email.com',
        '+91-8123456792',
        'Fund Raising, Public Speaking, Leadership'
    ),
    (
        5,
        'Riya Chopra',
        'riya.chopra@email.com',
        '+91-8123456793',
        'Art, Creativity, Child Care'
    ),
    (
        6,
        'Sanjay Bhatt',
        'sanjay.bhatt@email.com',
        '+91-8123456794',
        'IT Support, Web Development, Database Management'
    ),
    (
        7,
        'Pooja Nair',
        'pooja.nair@email.com',
        '+91-8123456795',
        'Logistics, Planning, Coordination'
    ),
    (
        8,
        'Arun Kumar',
        'arun.kumar@email.com',
        '+91-8123456796',
        'Transportation, Heavy Lifting, Manual Work'
    );
-- Insert data into Venue table
INSERT INTO Venue (
        Venue_ID,
        Name,
        Address,
        Contact,
        Capacity,
        Type,
        Status
    )
VALUES (
        1,
        'Community Hall A',
        '123 Community Street, Mumbai',
        '+91-7123456789',
        200,
        'Indoor',
        'Available'
    ),
    (
        2,
        'City Park Amphitheater',
        '456 Park Road, Delhi',
        '+91-7123456790',
        500,
        'Outdoor',
        'Available'
    ),
    (
        3,
        'Medical Center Auditorium',
        '789 Health Avenue, Bangalore',
        '+91-7123456791',
        150,
        'Indoor',
        'Available'
    ),
    (
        4,
        'School Playground',
        '321 Education Lane, Chennai',
        '+91-7123456792',
        300,
        'Outdoor',
        'Available'
    ),
    (
        5,
        'Conference Center',
        '654 Business District, Pune',
        '+91-7123456793',
        100,
        'Indoor',
        'Booked'
    ),
    (
        6,
        'Beach Side Venue',
        '987 Coastal Road, Goa',
        '+91-7123456794',
        250,
        'Outdoor',
        'Available'
    );
-- Insert data into Vendor table
INSERT INTO Vendor (
        Vendor_ID,
        Name,
        Email,
        Address,
        Contact,
        Service_type,
        NGO_ID
    )
VALUES (
        1,
        'Catering Plus',
        'orders@cateringplus.com',
        '111 Food Street, Mumbai',
        '+91-6123456789',
        'Catering',
        1
    ),
    (
        2,
        'Sound & Light Pro',
        'bookings@soundlightpro.com',
        '222 Tech Avenue, Delhi',
        '+91-6123456790',
        'Audio/Visual',
        2
    ),
    (
        3,
        'Medical Supplies Co',
        'sales@medicalsupplies.com',
        '333 Health Road, Bangalore',
        '+91-6123456791',
        'Medical Equipment',
        3
    ),
    (
        4,
        'Event Decorators',
        'info@eventdecorators.com',
        '444 Decoration Lane, Chennai',
        '+91-6123456792',
        'Decoration',
        4
    ),
    (
        5,
        'Transport Solutions',
        'bookings@transportsolutions.com',
        '555 Transport Hub, Pune',
        '+91-6123456793',
        'Transportation',
        5
    ),
    (
        6,
        'Photography Studio',
        'contact@photostudio.com',
        '666 Camera Street, Mumbai',
        '+91-6123456794',
        'Photography',
        1
    ),
    (
        7,
        'Security Services',
        'info@securityservices.com',
        '777 Safety Road, Delhi',
        '+91-6123456795',
        'Security',
        2
    );
-- Insert data into Event table
INSERT INTO Event (
        Event_ID,
        Event_Type,
        Start_date,
        End_date,
        Location,
        NGO_ID,
        Venue_ID
    )
VALUES (
        1,
        'Educational Workshop',
        '2024-11-15',
        '2024-11-15',
        'Community Hall A, Mumbai',
        1,
        1
    ),
    (
        2,
        'Tree Plantation Drive',
        '2024-11-20',
        '2024-11-22',
        'City Park, Delhi',
        2,
        2
    ),
    (
        3,
        'Health Checkup Camp',
        '2024-12-01',
        '2024-12-03',
        'Medical Center, Bangalore',
        3,
        3
    ),
    (
        4,
        'Children''s Day Celebration',
        '2024-11-14',
        '2024-11-14',
        'School Playground, Chennai',
        4,
        4
    ),
    (
        5,
        'Women Empowerment Seminar',
        '2024-12-10',
        '2024-12-10',
        'Conference Center, Pune',
        5,
        5
    ),
    (
        6,
        'Blood Donation Camp',
        '2024-11-25',
        '2024-11-25',
        'Medical Center, Bangalore',
        3,
        3
    ),
    (
        7,
        'Beach Cleanup Drive',
        '2024-12-05',
        '2024-12-05',
        'Beach Side Venue, Goa',
        2,
        6
    );
-- Insert data into Donation table
INSERT INTO Donation (
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
        1,
        'RCP001',
        '2024-10-01',
        'Donation for educational materials',
        5000.00,
        'Cash',
        1,
        1,
        1
    ),
    (
        2,
        'RCP002',
        '2024-10-05',
        'General donation',
        3000.00,
        'Online',
        2,
        1,
        1
    ),
    (
        3,
        'RCP003',
        '2024-10-10',
        'Support for health camp',
        10000.00,
        'Cheque',
        3,
        3,
        3
    ),
    (
        4,
        'RCP004',
        '2024-10-12',
        'Donation for children''s activities',
        2500.00,
        'Cash',
        4,
        4,
        4
    ),
    (
        5,
        'RCP005',
        '2024-10-15',
        'Women Empowerment funding',
        7500.00,
        'Online',
        5,
        5,
        5
    ),
    (
        6,
        'RCP006',
        '2024-10-18',
        'General donation',
        4000.00,
        'Cash',
        6,
        2,
        NULL
    ),
    (
        7,
        'RCP007',
        '2024-10-20',
        'Online support',
        6000.00,
        'Online',
        7,
        3,
        6
    ),
    (
        8,
        'RCP008',
        '2024-10-22',
        'Sponsorship',
        8000.00,
        'Cheque',
        8,
        1,
        1
    ),
    (
        9,
        'RCP009',
        '2024-10-25',
        'Donation for events',
        1500.00,
        'Cash',
        1,
        2,
        2
    ),
    (
        10,
        'RCP010',
        '2024-10-28',
        'Large donor',
        2000.00,
        'Online',
        2,
        4,
        4
    );
SET FOREIGN_KEY_CHECKS = 1;