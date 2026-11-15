-- test za INSERT triger kod Repeating single detail with master
BEGIN TRANSACTION
	INSERT INTO dbo.KycUpitnik
    (datumPrijema, klijentID, fizickoLiceID, ocekivaniUkupniMesecniPromet)
VALUES
    ('2026-11-15', 9, 9, 999999.00)

SELECT * FROM Klijent;

ROLLBACK;


--test za UPDATE triger kod Repeating single detail with master
BEGIN TRANSACTION
	UPDATE kyc
	SET kyc.ocekivaniUkupniMesecniPromet = 44444 
	FROM KycUpitnik kyc
	WHERE kyc.klijentID = 10

SELECT * FROM Klijent;

ROLLBACK;


-- Test za DELETE triger kod Repeating Single Detail with Master
BEGIN TRANSACTION;

INSERT INTO dbo.KycUpitnik
    (datumPrijema, klijentID, fizickoLiceID, ocekivaniUkupniMesecniPromet)
VALUES
    ('2026-11-15', 9, 9, 999999.00);

DELETE FROM KycUpitnik
WHERE kycID = SCOPE_IDENTITY();

SELECT * FROM KycUpitnik;
SELECT * FROM Klijent;

ROLLBACK;