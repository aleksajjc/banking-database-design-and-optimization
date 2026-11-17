CREATE OR ALTER TRIGGER trg_TrazenaKarticaUpdate
ON dbo.TrazenaKartica
AFTER UPDATE
AS
BEGIN

    IF NOT UPDATE(zahtevKarticeID)
        RETURN;

    ;WITH PogodjeniZahtevi AS
    (
        SELECT zahtevKarticeID FROM inserted
        UNION
        SELECT zahtevKarticeID FROM deleted
    )
    UPDATE z
    SET z.brojTrazenihKartica =
        (
            SELECT COUNT(*)
            FROM dbo.TrazenaKartica AS tk
            WHERE tk.zahtevKarticeID = z.zahtevKarticeID
        )
    FROM dbo.ZahtevZaIzdavanjeKartica AS z
    JOIN PogodjeniZahtevi AS p
        ON p.zahtevKarticeID = z.zahtevKarticeID;
END;
GO
