CREATE OR ALTER TRIGGER trg_KlijentUpdateDenorm
ON dbo.Klijent
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(tipKlijentaID)
    BEGIN
        -- Prvi nivo
        UPDATE k
        SET k.nazivTipa = t.nazivTipa
        FROM dbo.Klijent k
        JOIN inserted i ON i.klijentID = k.klijentID
        JOIN dbo.TipKlijenta t
            ON t.tipKlijentaID = i.tipKlijentaID
        WHERE k.nazivTipa IS NULL
           OR k.nazivTipa <> t.nazivTipa;

        -- Drugi nivo
        UPDATE z
        SET z.nazivTipa = t.nazivTipa
        FROM dbo.ZahtevZaOtvaranjeRacuna z
        JOIN inserted i ON i.klijentID = z.klijentID
        JOIN dbo.TipKlijenta t
            ON t.tipKlijentaID = i.tipKlijentaID
        WHERE z.nazivTipa IS NULL
           OR z.nazivTipa <> t.nazivTipa;
    END

    ELSE IF UPDATE(nazivTipa)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN dbo.TipKlijenta t
                ON t.tipKlijentaID = i.tipKlijentaID
            WHERE i.nazivTipa IS NULL
               OR i.nazivTipa <> t.nazivTipa
        )
            THROW 51003,
                'Naziv tipa klijenta mora odgovarati TipKlijenta.',
                1;
    END
END;
GO
