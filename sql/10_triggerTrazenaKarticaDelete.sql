CREATE OR ALTER TRIGGER trg_TrazenaKarticaDelete
ON dbo.TrazenaKartica
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE z
    SET z.brojTrazenihKartica =
        (
            SELECT COUNT(*)
            FROM dbo.TrazenaKartica AS tk
            WHERE tk.zahtevKarticeID = z.zahtevKarticeID
        )
    FROM dbo.ZahtevZaIzdavanjeKartica AS z
    WHERE z.zahtevKarticeID IN
        (SELECT zahtevKarticeID FROM deleted);
END;

