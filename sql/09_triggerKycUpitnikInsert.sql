CREATE OR ALTER TRIGGER trg_KycUpitnikInsert ON KycUpitnik
AFTER INSERT
AS
BEGIN
	WITH NajnovijiKyc AS
	(
	SELECT klijentID, ocekivaniUkupniMesecniPromet, datumPrijema, ROW_NUMBER() OVER(PARTITION BY klijentID ORDER BY datumPrijema DESC, kycID DESC) as rn
	FROM KycUpitnik
	WHERE KlijentID IN (SELECT KlijentID FROM inserted)
	)
	UPDATE k
	SET k.aktuelniOcekivaniUkupniMesecniPromet = kyc.ocekivaniUkupniMesecniPromet
	FROM Klijent k
		JOIN inserted i ON k.klijentID = i.klijentID
	    JOIN NajnovijiKyc kyc ON k.klijentID = kyc.klijentID AND kyc.rn = 1
	;
END