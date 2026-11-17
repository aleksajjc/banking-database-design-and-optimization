CREATE OR ALTER TRIGGER trg_TrazenaKarticaInsert ON TrazenaKartica
AFTER INSERT
AS
BEGIN
	UPDATE z 
	SET z.brojTrazenihKartica = (
		SELECT COUNT(*)
		FROM TrazenaKartica tk 
		WHERE tk.zahtevKarticeID = z.zahtevKarticeID
	)
	FROM ZahtevZaIzdavanjeKartica z
	WHERE z.zahtevKarticeID IN (SELECT i.zahtevKarticeID FROM inserted i)
END

