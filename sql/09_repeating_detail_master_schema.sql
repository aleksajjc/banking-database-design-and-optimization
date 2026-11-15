WITH NajnovijiKyc AS
(
	SELECT klijentID, ocekivaniUkupniMesecniPromet, datumPrijema, ROW_NUMBER() OVER(PARTITION BY klijentID ORDER BY datumPrijema DESC, kycID DESC) as rn
	FROM KycUpitnik
)
UPDATE k
SET k.aktuelniOcekivaniUkupniMesecniPromet = kyc.ocekivaniUkupniMesecniPromet
FROM Klijent k
	LEFT JOIN NajnovijiKyc kyc ON k.klijentID = kyc.klijentID AND kyc.rn = 1
;