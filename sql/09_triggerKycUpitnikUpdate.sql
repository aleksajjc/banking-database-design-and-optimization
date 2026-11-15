CREATE OR ALTER TRIGGER trg_KycUpitnikUpdate ON KycUpitnik
AFTER UPDATE
AS
BEGIN
IF NOT UPDATE(ocekivaniUkupniMesecniPromet)
    RETURN;
	WITH NajnovijiKyc AS
	(
	SELECT klijentID, ocekivaniUkupniMesecniPromet, datumPrijema, ROW_NUMBER() OVER(PARTITION BY klijentID ORDER BY datumPrijema DESC, kycID DESC) as rn
	FROM KycUpitnik
	WHERE KlijentID IN (SELECT KlijentID FROM inserted)
	)
	Update k 
	SET k.aktuelniOcekivaniUkupniMesecniPromet = kyc.ocekivaniUkupniMesecniPromet
	FROM Klijent k
		JOIN inserted i ON i.klijentID = k.klijentID
		LEFT JOIN NajnovijiKyc kyc ON kyc.klijentID = k.klijentID AND kyc.rn = 1
END