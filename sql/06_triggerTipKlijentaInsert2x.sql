CREATE OR ALTER TRIGGER trg_afterInsertZahtevZaOtvaranjeRacuna ON ZahtevZaOtvaranjeRacuna
AFTER INSERT
AS
BEGIN
	UPDATE zor
	SET zor.nazivTipa = tk.nazivTipa
	FROM ZahtevZaOtvaranjeRacuna zor
	JOIN inserted i ON i.zahtevID = zor.zahtevID
	JOIN Klijent k ON k.klijentID = zor.klijentID
	JOIN TipKlijenta tk ON tk.tipKlijentaID = k.tipKlijentaID
END