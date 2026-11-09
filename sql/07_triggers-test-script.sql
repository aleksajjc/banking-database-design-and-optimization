-- Test za TrazenuKarticu za INSERT trigger
BEGIN TRANSACTION 

INSERT INTO TrazenaKartica(zahtevKarticeID, fizickoLiceID, vrstaKarticeID, mesecniLimit) VALUES (9,9,9,50000)

SELECT * FROM TrazenaKartica;

ROLLBACK;

-- Test za TrazenuKarticu za UPDATE trigger
BEGIN TRANSACTION

UPDATE VrstaKarticebr
SET nazivVrsteKartice = 'Promena'
WHERE vrstaKarticeID = 7
;

SELECT * FROM TrazenaKartica;
SELECT * FROM VrstaKartice;

ROLLBACK;

-- Test za Racun za INSERT trigger
BEGIN TRANSACTION
INSERT INTO Racun(brojRacuna, klijentID, vrstaRacunaID) VALUES (000001, 9,7)

SELECT * FROM Racun;

ROLLBACK;

-- Test za Racun za UPDATE trigger
BEGIN TRANSACTION
UPDATE Klijent
SET poslovnoIme = 'PROMENA'
WHERE klijentID = 9
;

SELECT * FROM Klijent;
SELECT * FROM Racun;

ROLLBACK;

--Test za two-level denormalizaciju za UPDATE trigger
BEGIN TRANSACTION
UPDATE TipKlijenta
SET nazivTipa = 'PROMENA'
WHERE tipKlijentaID = 7
;

SELECT * FROM TipKlijenta;
SELECT * FROM Klijent;
SELECT * FROM ZahtevZaOtvaranjeRacuna;

ROLLBACK;

--Test za two-level denormalizaciju za INSERT trigger
BEGIN TRANSACTION
INSERT INTO Klijent(PIB, poslovnoIme, tipKlijentaID, mestoID) VALUES ('Test','Test',7,7)
INSERT INTO ZahtevZaOtvaranjeRacuna(datumPrijema, klijentID) VALUES ('1999-01-01',9)

SELECT * FROM Klijent;
SELECT * FROM ZahtevZaOtvaranjeRacuna;
ROLLBACK;

