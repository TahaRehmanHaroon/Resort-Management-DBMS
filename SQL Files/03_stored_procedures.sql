/* ==============================================================
   FILE: 03_stored_procedures.sql
   DESCRIPTION: All sp_* stored procedure definitions and sample EXEC calls
   ============================================================== */

USE ResortBookingDB;

-- ============================================================
-- sp_UpdateReservationStatus
-- Description: Updates the booking status of a reservation.
--   If trying to mark a reservation as 'Completed', it first
--   checks that the invoice has been paid. Blocks the update
--   if the bill is still pending.
-- ============================================================
GO
CREATE PROCEDURE sp_UpdateReservationStatus
    @ResID  INT,
    @Status VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Security check: only run the invoice check when completing a stay
    IF @Status = 'Completed'
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM Invoices
            WHERE ResID = @ResID AND PaymentStatus = 'Paid'
        )
        BEGIN
            PRINT 'Action Denied: Cannot complete reservation #' + CAST(@ResID AS VARCHAR);
            PRINT 'Reason: Invoice is Pending or does not exist. Please settle the bill first.';
            RETURN;
        END
    END

    -- If the check passes (or status is Confirmed / Cancelled), update
    UPDATE Reservations
    SET BookingStatus = @Status
    WHERE ResID = @ResID;

    PRINT 'Success: Reservation #' + CAST(@ResID AS VARCHAR) + ' updated to ' + @Status + '.';
END;
GO

-- Sample call
EXEC sp_UpdateReservationStatus 5, 'Completed';


-- ============================================================
-- sp_GenerateInvoice
-- Description: Calculates and inserts an invoice for a given
--   reservation by summing:
--     Room Cost     = BasePrice  * Nights
--     Food Cost     = Item Price * Quantity
--     Facility Cost = HourlyRate * HoursUsed
-- ============================================================
GO
CREATE PROCEDURE sp_GenerateInvoice
    @ResID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RoomTotal     DECIMAL(10,2) = 0.00;
    DECLARE @FoodTotal     DECIMAL(10,2) = 0.00;
    DECLARE @FacilityTotal DECIMAL(10,2) = 0.00;
    DECLARE @GrandTotal    DECIMAL(10,2) = 0.00;
    DECLARE @Nights        INT;

    -- Number of nights (minimum 1 if same-day check-in/out)
    SELECT @Nights = DATEDIFF(DAY, CheckInDate, CheckOutDate)
    FROM Reservations
    WHERE ResID = @ResID;

    IF @Nights = 0 SET @Nights = 1;

    -- Room charges: BasePrice * Nights
    SELECT @RoomTotal = ISNULL(SUM(rt.BasePrice * @Nights), 0)
    FROM Rooms r
    JOIN Room_Types rt ON r.TypeID = rt.TypeID
    WHERE r.ResID = @ResID;

    -- Food charges: Price * Quantity
    SELECT @FoodTotal = ISNULL(SUM(m.Price * rm.Quantity), 0)
    FROM Res_Menu rm
    JOIN Menu_Items m ON rm.ItemID = m.ItemID
    WHERE rm.ResID = @ResID;

    -- Facility charges: HourlyRate * HoursUsed
    SELECT @FacilityTotal = ISNULL(SUM(f.HourlyRate * rf.HoursUsed), 0)
    FROM Res_Fac rf
    JOIN Facilities f ON rf.FacilityID = f.FacilityID
    WHERE rf.ResID = @ResID;

    SET @GrandTotal = @RoomTotal + @FoodTotal + @FacilityTotal;

    -- Insert invoice record
    INSERT INTO Invoices (ResID, IssueDate, TotalAmount, PaymentStatus)
    VALUES (@ResID, GETDATE(), @GrandTotal, 'Pending');

    -- Print breakdown for the admin
    PRINT '---------------------------------';
    PRINT 'Invoice Generated for Res ID: ' + CAST(@ResID AS VARCHAR);
    PRINT 'Room Charges:     '             + CAST(@RoomTotal     AS VARCHAR);
    PRINT 'Food Charges:     '             + CAST(@FoodTotal     AS VARCHAR);
    PRINT 'Facility Charges: '             + CAST(@FacilityTotal AS VARCHAR);
    PRINT 'GRAND TOTAL:      '             + CAST(@GrandTotal    AS VARCHAR);
    PRINT '---------------------------------';
END;
GO

-- Sample calls
EXEC sp_GenerateInvoice 1;
EXEC sp_GenerateInvoice 5;


-- ============================================================
-- sp_ProcessPayment
-- Description: Processes a payment for an invoice.
--   Validates that the invoice exists and is unpaid, then
--   inserts a Payment record and marks the Invoice as 'Paid'
--   inside an atomic transaction.
-- ============================================================
GO
CREATE PROCEDURE sp_ProcessPayment
    @TargetInvoiceID INT,
    @PaymentMethod   VARCHAR(50)  -- 'Cash', 'Credit Card', 'Online Transfer'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AmountToPay   DECIMAL(10,2);
    DECLARE @CurrentStatus VARCHAR(20);

    -- Retrieve invoice details
    SELECT
        @AmountToPay   = TotalAmount,
        @CurrentStatus = PaymentStatus
    FROM Invoices
    WHERE InvoiceID = @TargetInvoiceID;

    -- Validation: invoice must exist
    IF @AmountToPay IS NULL
    BEGIN
        PRINT 'Error: Invoice ID ' + CAST(@TargetInvoiceID AS VARCHAR) + ' not found.';
        RETURN;
    END

    -- Validation: invoice must not already be paid
    IF @CurrentStatus = 'Paid'
    BEGIN
        PRINT 'Error: Invoice #' + CAST(@TargetInvoiceID AS VARCHAR) + ' is already marked as PAID.';
        RETURN;
    END

    -- Atomic transaction: insert payment + update invoice status
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Payments (InvoiceID, PaymentDate, Amount, PaymentMethod)
        VALUES (@TargetInvoiceID, GETDATE(), @AmountToPay, @PaymentMethod);

        UPDATE Invoices
        SET PaymentStatus = 'Paid'
        WHERE InvoiceID = @TargetInvoiceID;

        COMMIT TRANSACTION;
        PRINT 'Success! Payment of ' + CAST(@AmountToPay AS VARCHAR) + ' received via ' + @PaymentMethod;
        PRINT 'Invoice #' + CAST(@TargetInvoiceID AS VARCHAR) + ' is now marked as Paid.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Transaction Failed: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Sample call
EXEC sp_ProcessPayment 2, 'Cash';


-- ============================================================
-- sp_CreateReservation_Simple
-- Description: Creates a new reservation for a customer.
--   Validates that the requested room exists and is available,
--   inserts the reservation, then marks the room as Occupied.
-- ============================================================
GO
CREATE PROCEDURE sp_CreateReservation_Simple
    @CustomerID   INT,
    @RoomNumber   VARCHAR(10),
    @CheckInDate  DATETIME,
    @CheckOutDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewResID      INT;
    DECLARE @CurrentStatus VARCHAR(20);

    -- Step 1: Validate room existence and availability
    SELECT @CurrentStatus = Status
    FROM Rooms
    WHERE RoomNumber = @RoomNumber;

    IF @CurrentStatus IS NULL
    BEGIN
        PRINT 'Error: Room ' + @RoomNumber + ' does not exist.';
        RETURN;
    END

    IF @CurrentStatus = 'Occupied'
    BEGIN
        PRINT 'Error: Room ' + @RoomNumber + ' is already Occupied.';
        RETURN;
    END

    -- Step 2: Insert the reservation
    INSERT INTO Reservations (CustomerID, CheckInDate, CheckOutDate, BookingStatus)
    VALUES (@CustomerID, @CheckInDate, @CheckOutDate, 'Confirmed');

    -- Step 3: Capture the new reservation ID
    SELECT @NewResID = MAX(ResID) FROM Reservations;

    -- Step 4: Mark the room as Occupied and link it to the reservation
    UPDATE Rooms
    SET Status = 'Occupied',
        ResID  = @NewResID
    WHERE RoomNumber = @RoomNumber;

    PRINT 'Success: Reservation #' + CAST(@NewResID AS VARCHAR) + ' created for Room ' + @RoomNumber;
END;
GO

-- Sample call
EXEC sp_CreateReservation_Simple
    @CustomerID   = 2,
    @RoomNumber   = '102',
    @CheckInDate  = '2025-12-28',
    @CheckOutDate = '2025-12-30';

SELECT * FROM Rooms WHERE RoomNumber = '102';
