/* ==============================================================
   FILE: 04_triggers.sql
   DESCRIPTION: All trg_* trigger definitions and sample DML to test them
   ============================================================== */

USE ResortBookingDB;

-- ============================================================
-- trg_AutoFreeRoom
-- Fires: AFTER UPDATE on Reservations
-- Description: When a reservation's BookingStatus is changed to
--   'Completed' or 'Cancelled', automatically sets the linked
--   room's Status back to 'Available' and clears its ResID.
-- ============================================================
GO
CREATE TRIGGER trg_AutoFreeRoom
ON Reservations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Rooms
    SET Status = 'Available',
        ResID  = NULL
    FROM Rooms r
    INNER JOIN inserted i ON r.ResID = i.ResID
    WHERE i.BookingStatus IN ('Completed', 'Cancelled');
END;
GO

-- Test: complete reservation 8 (room 401 should become Available)
EXEC sp_UpdateReservationStatus 8, 'Completed';
SELECT RoomNumber, Status, ResID FROM Rooms WHERE RoomNumber = '401';


-- ============================================================
-- trg_LogDeletedReservation
-- Fires: AFTER DELETE on Reservations
-- Description: Archives every deleted reservation row into the
--   Reservations_Log table, capturing who deleted it via
--   SYSTEM_USER.
-- ============================================================
GO
CREATE TRIGGER trg_LogDeletedReservation
ON Reservations
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Reservations_Log (ResID, CustomerID, CheckInDate, DeletedByUser)
    SELECT
        d.ResID,
        d.CustomerID,
        d.CheckInDate,
        SYSTEM_USER
    FROM deleted d;

    PRINT 'Reservation deleted and archived to Log.';
END;
GO

-- Test: delete reservation 15 and verify the log
DELETE FROM Reservations WHERE ResID = 15;
SELECT * FROM Reservations_Log;
SELECT * FROM Reservations;


-- ============================================================
-- trg_TrackSalaryChanges
-- Fires: AFTER UPDATE on Staff
-- Description: Whenever the Salary column is updated, logs the
--   old salary, the new salary, and the timestamp into Staff_Log.
--   Only fires when the Salary value actually changes.
-- ============================================================
GO
CREATE TRIGGER trg_TrackSalaryChanges
ON Staff
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Salary)
    BEGIN
        INSERT INTO Staff_Log (StaffID, OldSalary, NewSalary, ChangeDate)
        SELECT
            d.StaffID,
            d.Salary,   -- value before the update
            i.Salary,   -- value after the update
            GETDATE()
        FROM deleted d
        INNER JOIN inserted i ON d.StaffID = i.StaffID
        WHERE d.Salary != i.Salary;

        PRINT 'Salary update detected. Change logged to Staff_Log.';
    END
END;
GO

-- Test: update a salary and verify the log
UPDATE Staff SET Salary = 65000.00 WHERE StaffID = 3;
SELECT * FROM Staff_Log;
