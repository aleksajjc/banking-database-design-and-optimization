--Test za trigger insert TrazenaKartica
BEGIN TRANSACTION;
INSERT INTO TrazenaKartica
    (zahtevKarticeID, fizickoLiceID, vrstaKarticeID, mesecniLimit)
VALUES
    (9, 9, 9, 50000);

SELECT zahtevKarticeID, brojTrazenihKartica
FROM ZahtevZaIzdavanjeKartica;

ROLLBACK;

-- Test za DELETE triger TrazenaKartica

BEGIN TRANSACTION;
DELETE FROM TrazenaKartica
WHERE zahtevKarticeID = 9
  AND fizickoLiceID = 9
  AND vrstaKarticeID = 7;

SELECT zahtevKarticeID, brojTrazenihKartica
FROM ZahtevZaIzdavanjeKartica;

ROLLBACK;

-- Test za UPDATE triger TrazenaKartica

BEGIN TRANSACTION;
UPDATE TrazenaKartica
SET zahtevKarticeID = 10,
    fizickoLiceID = 11
WHERE zahtevKarticeID = 9
  AND fizickoLiceID = 9
  AND vrstaKarticeID = 8;

SELECT zahtevKarticeID, brojTrazenihKartica
FROM ZahtevZaIzdavanjeKartica;

ROLLBACK;