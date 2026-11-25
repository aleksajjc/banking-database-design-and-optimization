
CREATE OR ALTER TRIGGER trg_ZahtevOtvaranjeUpdateDenorm
ON dbo.ZahtevZaOtvaranjeRacuna
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(klijentID)
    BEGIN
        UPDATE z
        SET z.nazivTipa = t.nazivTipa
        FROM dbo.ZahtevZaOtvaranjeRacuna z
        JOIN inserted i ON i.zahtevID = z.zahtevID
        JOIN dbo.Klijent k ON k.klijentID = i.klijentID
        JOIN dbo.TipKlijenta t
            ON t.tipKlijentaID = k.tipKlijentaID
        WHERE z.nazivTipa IS NULL
           OR z.nazivTipa <> t.nazivTipa;
    END

    ELSE IF UPDATE(nazivTipa)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN dbo.Klijent k ON k.klijentID = i.klijentID
            JOIN dbo.TipKlijenta t
                ON t.tipKlijentaID = k.tipKlijentaID
            WHERE i.nazivTipa IS NULL
               OR i.nazivTipa <> t.nazivTipa
        )
            THROW 51004,
                'Naziv tipa zahteva mora odgovarati tipu klijenta.',
                1;
    END
END;
GO
