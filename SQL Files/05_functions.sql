/* ==============================================================
   FILE: 05_functions.sql
   DESCRIPTION: All fn_* user-defined function definitions and sample calls
   ============================================================== */

USE ResortBookingDB;

-- ============================================================
-- fn_GetCustomerTotalSpent  (Scalar Function)
-- Goal: Given a CustomerID, return the total amount that
--   customer has paid to the resort (Paid invoices only).
--   Returns 0.00 if the customer has no paid invoices.
-- ============================================================
GO
CREATE FUNCTION fn_GetCustomerTotalSpent
    (@CustomerID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalSpent DECIMAL(10, 2);

    SELECT @TotalSpent = SUM(i.TotalAmount)
    FROM Invoices i
    INNER JOIN Reservations r ON i.ResID = r.ResID
    WHERE r.CustomerID = @CustomerID
      AND i.PaymentStatus = 'Paid';

    RETURN ISNULL(@TotalSpent, 0.00);
END;
GO

-- Sample call: total revenue generated from CustomerID 1 (Taha Khan)
SELECT dbo.fn_GetCustomerTotalSpent(1) AS TotalRevenueFromTaha;


-- ============================================================
-- fn_EstimateStayCost  (Scalar Function)
-- Goal: Given a Room Type ID and a number of nights, return
--   the estimated room-only cost (excludes food and facilities).
--   Useful for giving quick quotes to prospective guests.
-- ============================================================
GO
CREATE FUNCTION fn_EstimateStayCost
    (@TypeID         INT,
     @NumberOfNights INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @BasePrice  DECIMAL(10, 2);
    DECLARE @TotalCost  DECIMAL(10, 2);

    SELECT @BasePrice = BasePrice
    FROM Room_Types
    WHERE TypeID = @TypeID;

    SET @TotalCost = @BasePrice * @NumberOfNights;

    RETURN ISNULL(@TotalCost, 0.00);
END;
GO

-- Sample call: cost for Room Type 5 (Executive Suite) for 3 nights
SELECT dbo.fn_EstimateStayCost(5, 3) AS EstimatedBill;


-- ============================================================
-- fn_GetAvailableRoomsByType  (Inline Table-Valued Function)
-- Goal: Given a room type name (e.g., 'Standard Double'),
--   return a table of all room numbers currently Available
--   for that type, along with the base price.
-- ============================================================
GO
CREATE FUNCTION fn_GetAvailableRoomsByType
    (@TypeName VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        r.RoomNumber,
        rt.BasePrice,
        r.Status
    FROM Rooms r
    INNER JOIN Room_Types rt ON r.TypeID = rt.TypeID
    WHERE rt.TypeName = @TypeName
      AND r.Status = 'Available'
);
GO

-- Sample call: all available Standard Double rooms
SELECT * FROM dbo.fn_GetAvailableRoomsByType('Standard Double');
