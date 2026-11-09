CREATE OR ALTER TRIGGER trg_afterUpdate ON dbo.VrstaKartice
AFTER UPDATE
AS
BEGIN
	UPDATE tk
	SET tk.nazivVrsteKartice = i.nazivVrsteKartice
	FROM dbo.TrazenaKartica AS tk
	JOIN inserted AS i ON i.vrstaKarticeID = tk.vrstaKarticeID
END