SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT 'Pre optimizacije';
WITH NajnovijiKyc AS
(
    SELECT
        klijentID,
        ocekivaniUkupniMesecniPromet,
        ROW_NUMBER() OVER (
            PARTITION BY klijentID
            ORDER BY datumPrijema DESC, kycID DESC
        ) AS rn
    FROM KycUpitnik
)
SELECT
    k.klijentID,
    k.poslovnoIme,
    kyc.ocekivaniUkupniMesecniPromet
FROM Klijent k
LEFT JOIN NajnovijiKyc kyc
    ON k.klijentID = kyc.klijentID
    AND kyc.rn = 1;

PRINT 'Posle optimizacije';
SELECT
    klijentID,
    poslovnoIme,
    aktuelniOcekivaniUkupniMesecniPromet
FROM Klijent;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;