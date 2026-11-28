-- TrazenaKartica update trigger - direktna izmena naziva
BEGIN TRANSACTION;

UPDATE dbo.TrazenaKartica
SET nazivVrsteKartice = N'Pogresan naziv'
WHERE zahtevKarticeID = 9
    AND fizickoLiceID = 9
    AND vrstaKarticeID = 7;

ROLLBACK;

-- TrazenaKartica update trigger - direktna izmena na ispravan naziv
BEGIN TRANSACTION;

UPDATE dbo.TrazenaKartica
SET nazivVrsteKartice = nazivVrsteKartice
WHERE zahtevKarticeID = 9
    AND fizickoLiceID = 9
    AND vrstaKarticeID = 7;

ROLLBACK;

-- TrazenaKartica update trigger - unos ID-a vrste kartice koja postoji
BEGIN TRANSACTION;

UPDATE dbo.TrazenaKartica
SET vrstaKarticeID = 9
WHERE zahtevKarticeID = 9
    AND fizickoLiceID = 9
    AND vrstaKarticeID = 7;

ROLLBACK;


-- Racun update trigger - Test za UPDATE poslovnoIme - direktna izmena poslovnog imena

BEGIN TRANSACTION;

UPDATE dbo.Racun
SET poslovnoIme = N'Pogresno ime'
WHERE klijentID = 9;

ROLLBACK;


-- Racun update trigger - Test za UPDATE klijentID - direktna izmena klijentID

BEGIN TRANSACTION;

UPDATE dbo.Racun
SET klijentID = 10
WHERE klijentID = 9;

ROLLBACK;


-- Klijent update trigger - direktna izmena nazivTipa
BEGIN TRANSACTION;

UPDATE dbo.Klijent
SET nazivTipa = N'Pogresan tip'
WHERE klijentID = 9;

ROLLBACK;

-- Klijent update trigger - direktna izmena tipKlijentID
BEGIN TRANSACTION;

UPDATE dbo.Klijent
SET tipKlijentaID = 8
WHERE klijentID = 9;

ROLLBACK;


-- ZahtevZaOtvaranjeRacuna update trigger - direktna izmena nazivTipa
BEGIN TRANSACTION;

UPDATE dbo.ZahtevZaOtvaranjeRacuna
SET nazivTipa = N'Pogresan tip'
WHERE klijentID = 9;

ROLLBACK;

-- ZahtevZaOtvaranjeRacuna update trigger - direktna izmena klijentID
BEGIN TRANSACTION;

UPDATE dbo.ZahtevZaOtvaranjeRacuna
SET klijentID = 10
WHERE klijentID = 9;

ROLLBACK;