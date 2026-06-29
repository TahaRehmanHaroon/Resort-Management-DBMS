/* ==============================================================
   FILE: 01_schema.sql
   DESCRIPTION: CREATE TABLE and ALTER TABLE statements
   ============================================================== */

USE ResortBookingDB;

-- ============================================================
-- SECTION 1: BASE / INDEPENDENT TABLES
-- ============================================================

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL,
    CustomerName VARCHAR(50) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    CNIC VARCHAR(50) NOT NULL,
    CustomerAddress VARCHAR(255),
    TemporaryData VARCHAR(50), -- Will be dropped via ALTER below

    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UQ_Customers_Phone UNIQUE (Phone),
    CONSTRAINT UQ_Customers_CNIC UNIQUE (CNIC)
);

CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50),
    Salary DECIMAL(10, 2),
    -- Email column will be added via ALTER below

    CONSTRAINT PK_Staff PRIMARY KEY (StaffID),
    CONSTRAINT CK_Staff_Role CHECK (Role IN ('Manager', 'Receptionist', 'Housekeeping')),
    CONSTRAINT CK_Staff_Salary CHECK (Salary > 0)
);

CREATE TABLE Room_Types (
    TypeID INT IDENTITY(1,1) NOT NULL,
    TypeName VARCHAR(5), -- Data type will be altered below
    BasePrice DECIMAL(10, 2) NOT NULL,
    MaxCapacity INT,

    CONSTRAINT PK_RoomTypes PRIMARY KEY (TypeID),
    CONSTRAINT CK_RoomTypes_Capacity CHECK (MaxCapacity > 0)
);

CREATE TABLE Facilities (
    FacilityID INT IDENTITY(1,1) NOT NULL,
    FacilityName VARCHAR(50) NOT NULL,
    HourlyRate DECIMAL(10, 2) CONSTRAINT DF_Facilities_Rate DEFAULT 0.00,

    CONSTRAINT PK_Facilities PRIMARY KEY (FacilityID),
    CONSTRAINT CK_Bad_Constraint CHECK (HourlyRate < 5) -- Will be dropped via ALTER
);

CREATE TABLE Menu_Items (
    ItemID INT IDENTITY(1,1) NOT NULL,
    ItemName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10, 2) NOT NULL, -- CHECK constraint will be added via ALTER

    CONSTRAINT PK_MenuItems PRIMARY KEY (ItemID)
);

-- ============================================================
-- SECTION 2: DEPENDENT TABLES
-- ============================================================

CREATE TABLE Reservations (
    ResID INT IDENTITY(1,1) NOT NULL,
    CustomerID INT,
    CheckInDate DATETIME NOT NULL,
    CheckOutDate DATETIME NOT NULL,
    BookingStatus VARCHAR(20) CONSTRAINT DF_Reservations_Status DEFAULT 'Confirmed',

    CONSTRAINT PK_Reservations PRIMARY KEY (ResID),
    CONSTRAINT FK_Reservations_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT CK_Reservations_Status CHECK (BookingStatus IN ('Confirmed', 'Completed', 'Cancelled')),
    CONSTRAINT CK_Reservations_Dates CHECK (CheckOutDate > CheckInDate)
);

CREATE TABLE Rooms (
    RoomID INT IDENTITY(100,1) NOT NULL,
    RoomNumber VARCHAR(10) NOT NULL,
    TypeID INT,
    StaffID INT,
    ResID INT, -- Added column (linked to active reservation)
    Status VARCHAR(20) CONSTRAINT DF_Rooms_Status DEFAULT 'Available',

    CONSTRAINT PK_Rooms PRIMARY KEY (RoomID),
    CONSTRAINT FK_Rooms_Type FOREIGN KEY (TypeID) REFERENCES Room_Types(TypeID),
    CONSTRAINT FK_Rooms_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Rooms_Res FOREIGN KEY (ResID) REFERENCES Reservations(ResID),
    CONSTRAINT UQ_Rooms_Number UNIQUE (RoomNumber),
    CONSTRAINT CK_Rooms_Status CHECK (Status IN ('Available', 'Occupied'))
);

CREATE TABLE Invoices (
    InvoiceID INT IDENTITY(1,1) NOT NULL,
    ResID INT,
    IssueDate DATETIME CONSTRAINT DF_Invoices_Date DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2) CONSTRAINT DF_Invoices_Amount DEFAULT 0.00,
    PaymentStatus VARCHAR(20) CONSTRAINT DF_Invoices_Status DEFAULT 'Pending',

    CONSTRAINT PK_Invoices PRIMARY KEY (InvoiceID),
    CONSTRAINT FK_Invoices_Res FOREIGN KEY (ResID) REFERENCES Reservations(ResID),
    CONSTRAINT UQ_Invoices_ResID UNIQUE (ResID),
    CONSTRAINT CK_Invoices_Status CHECK (PaymentStatus IN ('Pending', 'Paid'))
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) NOT NULL,
    InvoiceID INT,
    PaymentDate DATETIME CONSTRAINT DF_Payments_Date DEFAULT GETDATE(),
    Amount DECIMAL(10, 2),
    PaymentMethod VARCHAR(50),

    CONSTRAINT PK_Payments PRIMARY KEY (PaymentID),
    CONSTRAINT FK_Payments_Invoice FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID),
    CONSTRAINT UQ_Payments_InvoiceID UNIQUE (InvoiceID),
    CONSTRAINT CK_Payments_Amount CHECK (Amount > 0),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Online Transfer'))
);

-- ============================================================
-- SECTION 3: BRIDGE TABLES
-- ============================================================

-- Bridge: Which staff member handled which booking?
CREATE TABLE Res_Staff (
    BridgeID INT IDENTITY(1,1) NOT NULL,
    ResID INT,
    StaffID INT,

    CONSTRAINT PK_ResStaff PRIMARY KEY (BridgeID),
    CONSTRAINT FK_ResStaff_Res FOREIGN KEY (ResID) REFERENCES Reservations(ResID) ON DELETE CASCADE,
    CONSTRAINT FK_ResStaff_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Bridge: Facility Usage Logs
CREATE TABLE Res_Fac (
    UsageID INT IDENTITY(1,1) NOT NULL,
    ResID INT,
    FacilityID INT,
    UsageDate DATETIME CONSTRAINT DF_ResFac_Date DEFAULT GETDATE(),
    HoursUsed INT,

    CONSTRAINT PK_ResFac PRIMARY KEY (UsageID),
    CONSTRAINT FK_ResFac_Res FOREIGN KEY (ResID) REFERENCES Reservations(ResID) ON DELETE CASCADE,
    CONSTRAINT FK_ResFac_Facility FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID),
    CONSTRAINT CK_ResFac_Hours CHECK (HoursUsed > 0)
);

-- Bridge: Food / Menu Orders
CREATE TABLE Res_Menu (
    OrderID INT IDENTITY(1,1) NOT NULL,
    ResID INT,
    ItemID INT,
    Quantity INT,
    OrderDate DATETIME CONSTRAINT DF_ResMenu_Date DEFAULT GETDATE(),

    CONSTRAINT PK_ResMenu PRIMARY KEY (OrderID),
    CONSTRAINT FK_ResMenu_Res FOREIGN KEY (ResID) REFERENCES Reservations(ResID) ON DELETE CASCADE,
    CONSTRAINT FK_ResMenu_Item FOREIGN KEY (ItemID) REFERENCES Menu_Items(ItemID),
    CONSTRAINT CK_ResMenu_Qty CHECK (Quantity > 0)
);

-- ============================================================
-- SECTION 4: AUDIT / LOG TABLES
-- ============================================================

-- Stores a record of every deleted reservation
CREATE TABLE Reservations_Log (
    LogID INT IDENTITY(1,1) NOT NULL,
    ResID INT,
    CustomerID INT,
    CheckInDate DATETIME,
    DeletedDate DATETIME CONSTRAINT DF_ResLog_Date DEFAULT GETDATE(),
    DeletedByUser VARCHAR(100),

    CONSTRAINT PK_ResLog PRIMARY KEY (LogID)
);

-- Stores salary change history for staff members
CREATE TABLE Staff_Log (
    LogID INT IDENTITY(1,1) NOT NULL,
    StaffID INT,
    OldSalary DECIMAL(10, 2),
    NewSalary DECIMAL(10, 2),
    ChangeDate DATETIME CONSTRAINT DF_StaffLog_Date DEFAULT GETDATE(),

    CONSTRAINT PK_StaffLog PRIMARY KEY (LogID)
);

-- ============================================================
-- SECTION 5: ALTER STATEMENTS
-- Description:
--   Drop Column    (Customers)
--   Add Column     (Staff)
--   Alter Data Type(Room_Types)
--   Drop Constraint(Facilities)
--   Add Constraint (Menu_Items)
--   Rename Column  (Customers)
--   Update CHECK   (Invoices)
-- ============================================================

-- Remove the placeholder column from Customers
ALTER TABLE Customers DROP COLUMN TemporaryData;

-- Add Email to Staff
ALTER TABLE Staff ADD Email VARCHAR(100);

-- Widen TypeName to hold full room-type names
ALTER TABLE Room_Types ALTER COLUMN TypeName VARCHAR(50) NOT NULL;

-- Remove the overly restrictive HourlyRate < 5 constraint
ALTER TABLE Facilities DROP CONSTRAINT CK_Bad_Constraint;

-- Enforce positive pricing on menu items
ALTER TABLE Menu_Items ADD CONSTRAINT CK_Menu_Price CHECK (Price > 0);

-- Rename Phone to CustomerPhone for clarity
EXEC sp_rename 'Customers.Phone', 'CustomerPhone', 'COLUMN';

-- Recreate Invoices status check (drop old, add corrected version)
ALTER TABLE Invoices DROP CONSTRAINT CK_Invoices_Status;
ALTER TABLE Invoices ADD CONSTRAINT CK_Invoices_Status
    CHECK (PaymentStatus IN ('Pending', 'Paid'));
