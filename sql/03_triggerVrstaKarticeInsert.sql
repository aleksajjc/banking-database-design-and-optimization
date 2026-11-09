CREATE OR ALTER TRIGGER trg_afterInsert ON dbo.TrazenaKartica
AFTER INSERT
AS
BEGIN
	UPDATE tk 
	SET tk.nazivVrsteKartice = vk.nazivVrsteKartice
	FROM dbo.TrazenaKartica AS tk
	JOIN inserted AS i ON tk.zahtevKarticeID = i.zahtevKarticeID AND tk.vrstaKarticeID = i.vrstaKarticeID
	JOIN dbo.VrstaKartice AS vk ON i.vrstaKarticeID = vk.vrstaKarticeID
END