CREATE OR ALTER TRIGGER trg_afterInsertZahtevZaOtvaranjeRacuna
ON dbo.ZahtevZaOtvaranjeRacuna
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE zor
    SET zor.nazivTipa = tk.nazivTipa
    FROM dbo.ZahtevZaOtvaranjeRacuna AS zor
    JOIN inserted AS i
        ON i.zahtevID = zor.zahtevID
    JOIN dbo.Klijent AS k
        ON k.klijentID = zor.klijentID
    JOIN dbo.TipKlijenta AS tk
        ON tk.tipKlijentaID = k.tipKlijentaID;
END;
GO