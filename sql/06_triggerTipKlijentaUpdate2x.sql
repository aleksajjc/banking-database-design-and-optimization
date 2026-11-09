CREATE OR ALTER TRIGGER trg_afterUpdateTipKlijenta ON TipKlijenta
AFTER UPDATE
AS
BEGIN
	IF UPDATE(nazivTipa)
	BEGIN
		UPDATE Klijent
		SET nazivTipa = i.nazivTipa
		FROM Klijent
		JOIN inserted AS i ON Klijent.tipKlijentaID = i.tipKlijentaID

		UPDATE ZahtevZaOtvaranjeRacuna
		SET nazivTipa = i.nazivTipa
		FROM ZahtevZaOtvaranjeRacuna
		JOIN Klijent ON ZahtevZaOtvaranjeRacuna.klijentID = Klijent.klijentID  
		JOIN inserted AS i ON Klijent.tipKlijentaID = i.tipKlijentaID
	END
END