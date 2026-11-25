-- TrazenaKartica update trigger - unos pogresnog naziva
UPDATE dbo.TrazenaKartica
SET nazivVrsteKartice = N'Pogresan naziv'
WHERE zahtevKarticeID = 9
  AND fizickoLiceID = 9
  AND vrstaKarticeID = 7;


-- TrazenaKartica update trigger - unos ID-a vrste kartice koja postoji
BEGIN TRANSACTION;

UPDATE dbo.TrazenaKartica
SET vrstaKarticeID = 9
WHERE zahtevKarticeID = 9
  AND fizickoLiceID = 9
  AND vrstaKarticeID = 7;

SELECT *
FROM dbo.TrazenaKartica
WHERE zahtevKarticeID = 9;

ROLLBACK;


-- Racun update trigger - Test za UPDATE poslovnoIme - unos pogresnog 

BEGIN TRANSACTION;

UPDATE Racun
SET poslovnoIme = 'Pogresno ime'
WHERE klijentID = 9;

SELECT * FROM Racun;

ROLLBACK;


-- Racun update trigger - Test za UPDATE klijentID

BEGIN TRANSACTION;

UPDATE Racun
SET klijentID = 10
WHERE klijentID = 9;

SELECT
    racunID,
    klijentID,
    poslovnoIme
FROM Racun;

ROLLBACK;


-- Klijent update trigger - Test za pogresan unos
BEGIN TRANSACTION;

UPDATE Klijent
SET nazivTipa = 'Pogresan tip'
WHERE klijentID = 9;

SELECT klijentID, tipKlijentaID, nazivTipa
FROM Klijent;

ROLLBACK;

-- Klijent update trigger - Test za update tipKlijentaID
BEGIN TRANSACTION;

UPDATE Klijent
SET tipKlijentaID = 8
WHERE klijentID = 9;

SELECT klijentID, tipKlijentaID, nazivTipa
FROM Klijent
WHERE klijentID = 9;

SELECT zahtevID, klijentID, nazivTipa
FROM ZahtevZaOtvaranjeRacuna
WHERE klijentID = 9;

ROLLBACK;


-- ZahtevZaOtvaranjeRacuna update trigger - Test za unos pogresnog naziva
BEGIN TRANSACTION;

UPDATE ZahtevZaOtvaranjeRacuna
SET nazivTipa = 'Pogresan tip'
WHERE klijentID = 9;

SELECT * 
FROM ZahtevZaOtvaranjeRacuna
WHERE klijentID = 9;

ROLLBACK;

-- ZahtevZaOtvaranjeRacuna update trigger - Test za ipdate klijentID
BEGIN TRANSACTION;

UPDATE ZahtevZaOtvaranjeRacuna
SET klijentID = 10
WHERE klijentID = 9;

SELECT 
    zahtevID,
    klijentID,
    nazivTipa
FROM ZahtevZaOtvaranjeRacuna
WHERE klijentID = 10;

ROLLBACK;