CREATE OR ALTER TRIGGER trg_afterUpdateTipKlijenta
ON dbo.TipKlijenta
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(nazivTipa)
    BEGIN
        -- Prvi nivo
        UPDATE k
        SET k.nazivTipa = i.nazivTipa
        FROM dbo.Klijent AS k
        JOIN inserted AS i
            ON k.tipKlijentaID = i.tipKlijentaID;

        -- Drugi nivo
        UPDATE z
        SET z.nazivTipa = i.nazivTipa
        FROM dbo.ZahtevZaOtvaranjeRacuna AS z
        JOIN dbo.Klijent AS k
            ON z.klijentID = k.klijentID
        JOIN inserted AS i
            ON k.tipKlijentaID = i.tipKlijentaID;
    END
END;
GO