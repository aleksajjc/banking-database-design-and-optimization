CREATE OR ALTER TRIGGER trg_afterUpdateRacun ON dbo.Klijent
AFTER UPDATE
AS
BEGIN
	IF UPDATE(poslovnoIme)
	BEGIN
		UPDATE r
		SET r.poslovnoIme = i.poslovnoIme
		FROM dbo.Racun AS r
		JOIN inserted AS i ON r.klijentID = i.klijentID
	END
END