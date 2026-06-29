/* ==============================================================
   FILE: 02_seed_data.sql
   DESCRIPTION: INSERT statements with dummy data (15 rows each)
   ============================================================== */

USE ResortBookingDB;

-- ============================================================
-- 1. CUSTOMERS
-- ============================================================
INSERT INTO Customers (CustomerName, CustomerPhone, Email, CNIC, CustomerAddress) VALUES
('Taha Khan',      '0300-1000001', 'taha.k@gmail.com',       '42101-1111111-1', 'Gulshan-e-Iqbal, Karachi'),
('Hammad Ali',     '0321-1000002', 'hammad.ali@hotmail.com', '42101-1111111-2', 'DHA, Lahore'),
('Ghasif Raza',    '0333-1000003', 'ghasif.r@yahoo.com',     '42101-1111111-3', 'F-10, Islamabad'),
('Ezan Ahmed',     '0345-1000004', 'ezan.ahmed@gmail.com',   '42101-1111111-4', 'Cantt, Peshawar'),
('Wahab Riaz',     '0312-1000005', 'wahab.riaz@gmail.com',   '42101-1111111-5', 'Model Town, Lahore'),
('Taheer Shah',    '0301-1000006', 'taheer.s@gmail.com',     '42101-1111111-6', 'Clifton, Karachi'),
('Abdullah Malik', '0302-1000007', 'abdullah.m@gmail.com',   '42101-1111111-7', 'Satellite Town, Rawalpindi'),
('Asad Ullah',     '0303-1000008', 'asad.u@gmail.com',       '42101-1111111-8', 'Civil Lines, Quetta'),
('Mubeen Qureshi', '0304-1000009', 'mubeen.q@gmail.com',     '42101-1111111-9', 'Latifabad, Hyderabad'),
('Wasif Jutt',     '0305-1000010', 'wasif.j@gmail.com',      '42101-1111111-0', 'Sialkot Cantt'),
('Muneeb Butt',    '0306-1000011', 'muneeb.b@gmail.com',     '42101-1212121-1', 'Bahria Town, Karachi'),
('Awais Sheikh',   '0307-1000012', 'awais.s@gmail.com',      '42101-1212121-2', 'Gulberg, Lahore'),
('Ali Hassan',     '0308-1000013', 'ali.hassan@gmail.com',   '42101-1212121-3', 'Multan Cantt'),
('Ahmed Faraz',    '0309-1000014', 'ahmed.f@gmail.com',      '42101-1212121-4', 'G-11, Islamabad'),
('Danish Taimoor', '0310-1000015', 'danish.t@gmail.com',     '42101-1212121-5', 'North Nazimabad, Karachi');

-- ============================================================
-- 2. STAFF
-- ============================================================
INSERT INTO Staff (FullName, Role, Salary, Email) VALUES
('Ahsan Raza',      'Manager',       120000.00, 'ahsan.r@resort.com'),
('Imran Shahid',    'Manager',       115000.00, 'imran.s@resort.com'),
('Ahmed Bilal',     'Receptionist',   60000.00, 'ahmed.b@resort.com'),
('Sana Yousaf',     'Receptionist',   58000.00, 'sana.y@resort.com'),
('Waqas Mehmood',   'Concierge',      45000.00, 'waqas.m@resort.com'),
('Naveed Akhtar',   'Housekeeping',   35000.00, 'naveed.a@resort.com'),
('Hassan Ali',      'Housekeeping',   35000.00, 'hassan.a@resort.com'),
('Kamran Iqbal',    'Chef',           90000.00, 'kamran.i@resort.com'),
('Shahid Latif',    'Chef',           85000.00, 'shahid.l@resort.com'),
('Areeba Khan',     'Receptionist',   60000.00, 'areeba.k@resort.com'),
('Salman Farooq',   'Housekeeping',   36000.00, 'salman.f@resort.com'),
('Fahad Nawaz',     'Concierge',      46000.00, 'fahad.n@resort.com'),
('Zeeshan Ahmed',   'Manager',       130000.00, 'zeeshan.a@resort.com'),
('Usama Siddiq',    'Housekeeping',   34000.00, 'usama.s@resort.com'),
('Tariq Mehmood',   'Chef',           88000.00, 'tariq.m@resort.com');

-- ============================================================
-- 3. ROOM TYPES
-- ============================================================
INSERT INTO Room_Types (TypeName, BasePrice, MaxCapacity) VALUES
('Standard Single',    6000.00, 1),
('Standard Double',    9000.00, 2),
('Deluxe Single',     15000.00, 1),
('Deluxe Double',     18000.00, 2),
('Executive Suite',   30000.00, 4),
('Presidential Suite',65000.00, 6),
('Family Room',       22000.00, 4),
('Economy Room',       4500.00, 1),
('Honeymoon Suite',   40000.00, 2),
('Penthouse',         80000.00, 8),
('Studio Apartment',  25000.00, 3),
('Connecting Room',   20000.00, 4),
('Business Suite',    35000.00, 2),
('Cabana',            50000.00, 4),
('King Suite',        45000.00, 2);

-- ============================================================
-- 4. FACILITIES
-- ============================================================
INSERT INTO Facilities (FacilityName, HourlyRate) VALUES
('Swimming Pool',      500.00),
('Executive Gym',      800.00),
('Luxury Spa',        2500.00),
('Tennis Court',      1000.00),
('Conference Hall A', 8000.00),
('Sauna & Steam',     1200.00),
('Golf Course',       5000.00),
('Kids Club',          300.00),
('Business Center',   2000.00),
('Yoga Studio',        700.00),
('Badminton Court',    600.00),
('Billiard Room',      400.00),
('Cinema Hall',       1500.00),
('Jacuzzi',           1000.00),
('Cricket Ground',    3000.00);

-- ============================================================
-- 5. MENU ITEMS
-- ============================================================
INSERT INTO Menu_Items (ItemName, Category, Price) VALUES
('Chicken Biryani',    'Main Course', 750.00),
('Mutton Karahi',      'Main Course',2200.00),
('Beef Burger',        'Main Course', 950.00),
('Club Sandwich',      'Main Course', 850.00),
('Chicken Corn Soup',  'Starter',     450.00),
('Russian Salad',      'Starter',     500.00),
('Seekh Kabab',        'Starter',     800.00),
('Mix Sabzi',          'Main Course', 600.00),
('Daal Makhni',        'Main Course', 550.00),
('Garlic Naan',        'Sides',       100.00),
('Mineral Water (L)',  'Drinks',      150.00),
('Fresh Lime',         'Drinks',      250.00),
('Mint Margarita',     'Drinks',      350.00),
('Gulab Jamun',        'Dessert',     400.00),
('Kheer',              'Dessert',     450.00);

-- ============================================================
-- 6. RESERVATIONS  (must come before Rooms due to FK)
-- ============================================================
INSERT INTO Reservations (CustomerID, CheckInDate, CheckOutDate, BookingStatus) VALUES
(1,  '2025-12-10', '2025-12-20', 'Confirmed'),  -- ResID 1  → Room 101
(2,  '2025-12-12', '2025-12-18', 'Confirmed'),  -- ResID 2  → Room 103
(3,  '2025-12-14', '2025-12-16', 'Confirmed'),  -- ResID 3  → Room 201
(4,  '2025-02-14', '2025-02-15', 'Cancelled'),  -- ResID 4  → No room
(5,  '2025-12-15', '2025-12-25', 'Confirmed'),  -- ResID 5  → Room 202
(6,  '2025-12-15', '2025-12-18', 'Confirmed'),  -- ResID 6  → Room 203
(7,  '2025-12-14', '2025-12-20', 'Confirmed'),  -- ResID 7  → Room 301
(8,  '2025-12-10', '2025-12-15', 'Confirmed'),  -- ResID 8  → Room 401
(9,  '2025-12-12', '2025-12-14', 'Confirmed'),  -- ResID 9  → Room 501
(10, '2025-05-01', '2025-05-05', 'Completed'),  -- ResID 10
(11, '2025-05-10', '2025-05-15', 'Completed'),  -- ResID 11
(12, '2025-06-01', '2025-06-02', 'Completed'),  -- ResID 12
(13, '2025-06-10', '2025-06-12', 'Completed'),  -- ResID 13
(14, '2025-07-01', '2025-07-05', 'Completed'),  -- ResID 14
(15, '2025-07-20', '2025-07-25', 'Completed');  -- ResID 15

-- ============================================================
-- 7. ROOMS
-- ============================================================
INSERT INTO Rooms (RoomNumber, TypeID, StaffID, ResID, Status) VALUES
('101', 1,  6,  1,    'Occupied'),
('102', 1,  6,  NULL, 'Available'),
('103', 2,  6,  2,    'Occupied'),
('104', 2,  6,  NULL, 'Available'),
('201', 3,  7,  3,    'Occupied'),
('202', 3,  7,  5,    'Occupied'),
('203', 4,  7,  6,    'Occupied'),
('204', 4,  7,  NULL, 'Available'),
('301', 5,  11, 7,    'Occupied'),
('302', 6,  11, NULL, 'Available'),
('401', 7,  11, 8,    'Occupied'),
('402', 8,  11, NULL, 'Available'),
('501', 9,  14, 9,    'Occupied'),
('502', 10, 14, NULL, 'Available'),
('601', 5,  14, NULL, 'Available');

-- ============================================================
-- 8. INVOICES  (1:1 with Reservations)
-- ============================================================
INSERT INTO Invoices (ResID, IssueDate, TotalAmount, PaymentStatus) VALUES
(1,  '2025-12-10',  15000.00, 'Pending'),
(2,  '2025-12-12',  27000.00, 'Paid'),
(3,  '2025-12-14',  30000.00, 'Pending'),
(4,  '2025-02-15',      0.00, 'Paid'),
(5,  '2025-12-15', 120000.00, 'Pending'),
(6,  '2025-12-15',  45000.00, 'Pending'),
(7,  '2025-12-14', 110000.00, 'Pending'),
(8,  '2025-12-15',   9000.00, 'Paid'),
(9,  '2025-12-14',  36000.00, 'Paid'),
(10, '2025-05-05', 180000.00, 'Paid'),
(11, '2025-05-15', 125000.00, 'Paid'),
(12, '2025-06-02',   5000.00, 'Paid'),
(13, '2025-06-12',  20000.00, 'Paid'),
(14, '2025-07-05',  90000.00, 'Paid'),
(15, '2025-07-25', 250000.00, 'Paid');

-- ============================================================
-- 9. PAYMENTS
-- ============================================================
INSERT INTO Payments (InvoiceID, PaymentDate, Amount, PaymentMethod) VALUES
(2,  '2025-12-12',  27000.00, 'Credit Card'),
(8,  '2025-12-15',   9000.00, 'Cash'),
(9,  '2025-12-14',  36000.00, 'Credit Card'),
(10, '2025-05-05', 180000.00, 'Online Transfer'),
(11, '2025-05-15', 125000.00, 'Cash'),
(12, '2025-06-02',   5000.00, 'Cash'),
(13, '2025-06-12',  20000.00, 'Credit Card'),
(14, '2025-07-05',  90000.00, 'Online Transfer'),
(15, '2025-07-25', 250000.00, 'Credit Card');

-- ============================================================
-- 10. RES_STAFF  (Who managed which booking)
-- ============================================================
INSERT INTO Res_Staff (ResID, StaffID) VALUES
(1, 3), (2, 4), (3, 3),  (4, 10), (5, 3),
(6, 4), (7, 10),(8, 3),  (9, 4),  (10, 10),
(11, 3),(12, 4),(13, 10),(14, 3), (15, 4);

-- ============================================================
-- 11. RES_FAC  (Facility Usage Logs)
-- ============================================================
INSERT INTO Res_Fac (ResID, FacilityID, UsageDate, HoursUsed) VALUES
(1,  1,  '2025-01-02', 2),
(2,  2,  '2025-01-06', 1),
(5,  5,  '2025-03-02', 5),
(5,  1,  '2025-03-03', 2),
(7,  3,  '2025-03-16', 3),
(9,  10, '2025-04-06', 1),
(10, 7,  '2025-05-02', 4),
(11, 14, '2025-05-12', 1),
(14, 1,  '2025-07-02', 3),
(15, 6,  '2025-07-21', 2);

-- ============================================================
-- 12. RES_MENU  (Food / Menu Orders)
-- ============================================================
INSERT INTO Res_Menu (ResID, ItemID, Quantity, OrderDate) VALUES
(1,  1,  3,  '2025-01-01'),
(2,  3,  2,  '2025-01-06'),
(3,  11, 5,  '2025-02-11'),
(5,  2,  1,  '2025-03-01'),
(5,  10, 4,  '2025-03-01'),
(6,  4,  2,  '2025-03-11'),
(7,  12, 3,  '2025-03-18'),
(10, 1,  10, '2025-05-03'),
(12, 15, 2,  '2025-06-01'),
(15, 7,  4,  '2025-07-22');
