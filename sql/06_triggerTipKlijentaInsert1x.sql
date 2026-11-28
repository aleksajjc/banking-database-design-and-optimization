CREATE OR ALTER TRIGGER trg_afterInsertKlijent
ON dbo.Klijent
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE kl
    SET kl.nazivTipa = tk.nazivTipa
    FROM dbo.Klijent AS kl
    JOIN inserted AS i
        ON i.klijentID = kl.klijentID
    JOIN dbo.TipKlijenta AS tk
        ON tk.tipKlijentaID = kl.tipKlijentaID;
END;
GO