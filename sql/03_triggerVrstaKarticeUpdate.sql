CREATE OR ALTER TRIGGER trg_afterUpdate
ON dbo.VrstaKartice
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(nazivVrsteKartice)
    BEGIN
        UPDATE tk
        SET tk.nazivVrsteKartice = i.nazivVrsteKartice
        FROM dbo.TrazenaKartica AS tk
        JOIN inserted AS i
            ON i.vrstaKarticeID = tk.vrstaKarticeID;
    END
END;
GO