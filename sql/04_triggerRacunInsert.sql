CREATE OR ALTER TRIGGER trg_afterInsertRacun ON dbo.Racun
AFTER INSERT
AS
BEGIN
	UPDATE r 
	SET r.poslovnoIme = kl.poslovnoIme
	FROM dbo.Racun AS r
	JOIN inserted AS i ON r.racunID = i.racunID AND r.klijentID = i.klijentID
	JOIN dbo.Klijent AS kl ON i.klijentID = kl.klijentID
END