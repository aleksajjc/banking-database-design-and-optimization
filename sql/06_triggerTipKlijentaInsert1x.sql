CREATE OR ALTER TRIGGER trg_afterInsertKlijent ON Klijent
AFTER INSERT
AS
BEGIN
	UPDATE kl 
	SET kl.nazivTipa = tk.nazivTipa
	FROM Klijent AS kl
	JOIN inserted i ON i.klijentID = kl.klijentID
	JOIN TipKlijenta tk ON tk.tipKlijentaID = kl.tipKlijentaID
END