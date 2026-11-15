CREATE OR ALTER TRIGGER trg_KycUpitnikDelete ON KycUpitnik
AFTER DELETE
AS
BEGIN
    ;WITH NajnovijiKyc AS
    (
        SELECT klijentID, ocekivaniUkupniMesecniPromet, datumPrijema,
               ROW_NUMBER() OVER(
                   PARTITION BY klijentID
                   ORDER BY datumPrijema DESC, kycID DESC
               ) AS rn
        FROM KycUpitnik
        WHERE klijentID IN (SELECT klijentID FROM deleted)
    )
    UPDATE k
    SET k.aktuelniOcekivaniUkupniMesecniPromet = kyc.ocekivaniUkupniMesecniPromet
    FROM Klijent k
        JOIN (SELECT DISTINCT klijentID FROM deleted) d
            ON d.klijentID = k.klijentID
        LEFT JOIN NajnovijiKyc kyc
            ON kyc.klijentID = k.klijentID AND kyc.rn = 1;
END;
GO
