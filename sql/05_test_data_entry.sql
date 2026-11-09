USE [BankaRacuniDB];
GO

IF DB_NAME() <> N'BankaRacuniDB' OR @@TRANCOUNT <> 0
BEGIN
    RAISERROR (N'Pokreni skriptu u bazi BankaRacuniDB van postojeæe transakcije.', 16, 1);
    RETURN;
END;

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET IMPLICIT_TRANSACTIONS OFF;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Sve ostale tabele zavise od bar jedne od ovih tabela preko obaveznih FK veza.
    IF EXISTS (SELECT 1 FROM dbo.Mesto WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.TipKlijenta WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.FormatIzvoda WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.DodatnaUsluga WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.VrstaRacuna WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.FizickoLice WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.PorekloSredstava WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.SvrhaPoslovnogOdnosa WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.IzvorCelokupneImovine WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.OsnovPoreklaImovine WITH (TABLOCKX, HOLDLOCK))
        OR EXISTS (SELECT 1 FROM dbo.VrstaKartice WITH (TABLOCKX, HOLDLOCK))
        THROW 50001, N'Za unos test podataka potrebna je prazna baza BankaRacuniDB.', 1;

    -- Šifarnici
    INSERT INTO dbo.Mesto (nazivMesta, nazivDrzave)
    VALUES (N'Beograd', N'Srbija'), (N'Novi Sad', N'Srbija'), (N'Niš', N'Srbija');

    INSERT INTO dbo.TipKlijenta (nazivTipa)
    VALUES (N'Pravno lice'), (N'Preduzetnik'), (N'Neprofitno pravno lice');

    INSERT INTO dbo.FormatIzvoda (nazivFormata)
    VALUES (N'.pdf'), (N'.xml'), (N'.txt');

    INSERT INTO dbo.VrstaRacuna (nazivVrste, namenaRacuna)
    VALUES (N'Dinarski raèun', N'Redovan'),
           (N'Devizni raèun', N'Redovan'),
           (N'Devizni raèun', N'Namenski');

    INSERT INTO dbo.PorekloSredstava (nazivPoreklaSredstava)
    VALUES (N'Prodaja proizvoda i/ili pružanje usluga iz registrovane delatnosti'),
           (N'Sredstva iz kredita'),
           (N'Donacije i sponzorstva');

    INSERT INTO dbo.SvrhaPoslovnogOdnosa (nazivPoslOdnosa)
    VALUES (N'Obavljanje platnog prometa u zemlji'),
           (N'Obavljanje meðunarodnog platnog prometa'),
           (N'Obavljanje gotovinskih transakcija iz redovnog poslovanja');

    INSERT INTO dbo.IzvorCelokupneImovine (nazivIzvora)
    VALUES (N'Zarada'), (N'Nasledstvo'), (N'Prihod od kapitala (dobit, dividenda)');

    INSERT INTO dbo.OsnovPoreklaImovine (nazivOsnova)
    VALUES (N'Zarada'), (N'Ugovor, rešenje o nasleðivanju ili faktura'),
           (N'Izjava o poreklu novca');

    INSERT INTO dbo.VrstaKartice (nazivVrsteKartice)
    VALUES (N'DinaCard poslovna kartica'),
           (N'Mastercard Business Contactless kartica'),
           (N'VISA Premium Business kartica');

    INSERT INTO dbo.DodatnaUsluga (nazivUsluge, kategorijaUsluge)
    SELECT v.nazivUsluge, N'Digitalni servis'
    FROM (VALUES (N'NLB eBizKlik'), (N'Halcom'), (N'Office iBanking')) AS v(nazivUsluge)
    UNION ALL
    SELECT nazivVrsteKartice, N'Platne kartice'
    FROM dbo.VrstaKartice;

    -- Klijenti, zastupnici i njihovi lièni dokumenti
    INSERT INTO dbo.Klijent (
        PIB, maticniBroj, poslovnoIme, ulicaBroj, poslovniTelefon, poslovniEmail,
        delatnost, webStranica, drzavaOsnivanja, brojZaposlenih, sifraDelatnosti,
        postanskiBrSedista, tipKlijentaID, mestoID, nazivTipa
    )
    SELECT v.PIB, v.maticniBroj, v.poslovnoIme, v.ulicaBroj, v.poslovniTelefon, v.poslovniEmail,
           v.delatnost, v.webStranica, m.nazivDrzave, v.brojZaposlenih, v.sifraDelatnosti,
           v.postanskiBroj, t.tipKlijentaID, m.mestoID, t.nazivTipa
    FROM (VALUES
        ('000000101', '00000101', N'AnaFirma', N'Test ulica 11', '000-100-0101',
         N'finansije@anafirma.example', N'Raèunarsko programiranje', N'https://anafirma.example',
         18, '6201', '11000', N'Pravno lice', N'Beograd'),
        ('000000102', '00000102', N'MarkoFirma', N'Test ulica 22', '000-100-0102',
         N'finansije@markofirma.example', N'Drumski prevoz tereta', N'https://markofirma.example',
         72, '4941', '21000', N'Pravno lice', N'Novi Sad'),
        ('000000103', '00000103', N'JelenaPreduzetnica', N'Test ulica 33', '000-100-0103',
         N'jelena@jelenapreduzetnica.example', N'Specijalizovane dizajnerske delatnosti', N'https://jelenapreduzetnica.example',
         2, '7410', '21000', N'Preduzetnik', N'Novi Sad'),
        ('000000104', '00000104', N'PetarUdruzenje', N'Test ulica 44', '000-100-0104',
         N'finansije@petarudruzenje.example', N'Delatnost ostalih organizacija na bazi uèlanjenja',
         N'https://petarudruzenje.example', 4, '9499', '18000', N'Neprofitno pravno lice', N'Niš')
    ) AS v(PIB, maticniBroj, poslovnoIme, ulicaBroj, poslovniTelefon, poslovniEmail,
           delatnost, webStranica, brojZaposlenih, sifraDelatnosti, postanskiBroj, nazivTipa, nazivMesta)
    JOIN dbo.TipKlijenta AS t ON t.nazivTipa = v.nazivTipa
    JOIN dbo.Mesto AS m ON m.nazivMesta = v.nazivMesta;

    INSERT INTO dbo.FizickoLice (
        ime, prezime, JMBGIliIdentifikacioniBroj, drzavljanstvo, datumRodjenja,
        ulicaIBrojPrebivalista, postanskiBrojPrebivalista, email, brojTelefona,
        mestoRodjenjaID, mestoPrebivalistaID
    )
    SELECT v.ime, v.prezime, v.testJMBG, N'Srbija', v.datumRodjenja,
           v.adresa, v.postanskiBroj, v.email, v.telefon, mr.mestoID, mp.mestoID
    FROM (VALUES
        (N'Ana', N'Test1', '0000000000101', '19850312', N'Test naselje 1', '11000',
         N'ana@anafirma.example', '000-200-0101', N'Beograd', N'Beograd'),
        (N'Marko', N'Test2', '0000000000102', '19790625', N'Test naselje 2', '21000',
         N'marko@markofirma.example', '000-200-0102', N'Niš', N'Novi Sad'),
        (N'Jelena', N'Test3', '0000000000103', '19910807', N'Test naselje 3', '21000',
         N'jelena@jelenapreduzetnica.example', '000-200-0103', N'Novi Sad', N'Novi Sad'),
        (N'Petar', N'Test4', '0000000000104', '19821119', N'Test naselje 4', '18000',
         N'petar@petarudruzenje.example', '000-200-0104', N'Niš', N'Niš')
    ) AS v(ime, prezime, testJMBG, datumRodjenja, adresa, postanskiBroj, email, telefon,
           mestoRodjenja, mestoPrebivalista)
    JOIN dbo.Mesto AS mr ON mr.nazivMesta = v.mestoRodjenja
    JOIN dbo.Mesto AS mp ON mp.nazivMesta = v.mestoPrebivalista;

    -- Broj dosijea važi samo unutar skripte. FK kolone koriste ID-jeve koje je dodelio SQL Server.
    DECLARE @Dosije TABLE (
        brojDosijea INT PRIMARY KEY,
        klijentID INT NOT NULL UNIQUE,
        fizickoLiceID INT NOT NULL UNIQUE
    );

    INSERT INTO @Dosije (brojDosijea, klijentID, fizickoLiceID)
    SELECT v.brojDosijea, k.klijentID, f.fizickoLiceID
    FROM (VALUES
        (1, '000000101', '0000000000101'),
        (2, '000000102', '0000000000102'),
        (3, '000000103', '0000000000103'),
        (4, '000000104', '0000000000104')
    ) AS v(brojDosijea, PIB, testJMBG)
    JOIN dbo.Klijent AS k ON k.PIB = v.PIB
    JOIN dbo.FizickoLice AS f ON f.JMBGIliIdentifikacioniBroj = v.testJMBG;

    INSERT INTO dbo.LicniDokument (
        vrstaDokumenta, brLicnogDokumenta, datumIzdavanjaDokumenta, datumVazenjaDokumenta,
        nazivIzdavDok, fizickoLiceID, mestoIzdavanjaID
    )
    SELECT v.vrsta, v.broj, v.izdat, v.vaziDo, N'MUP – PU ' + m.nazivMesta,
           d.fizickoLiceID, m.mestoID
    FROM (VALUES
        (1, N'Lièna karta', N'TEST-LK-101', '20210712', '20310712'),
        (2, N'Lièna karta', N'TEST-LK-102', '20230516', '20330516'),
        (3, N'Lièna karta', N'TEST-LK-103', '20220405', '20320405'),
        (4, N'Pasoš', N'TEST-PAS-104', '20240910', '20340910')
    ) AS v(brojDosijea, vrsta, broj, izdat, vaziDo)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.FizickoLice AS f ON f.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.Mesto AS m ON m.mestoID = f.mestoPrebivalistaID;

    -- Zahtevi za otvaranje raèuna, formati i dostava izvoda, dodatne usluge
    INSERT INTO dbo.ZahtevZaOtvaranjeRacuna (
        datumPrijema, datumPotpisivanja, koristiPecat, emailZaIzmeneOkvirnogUgovora,
        ulogaPredstavnika, kategorijaPrihoda, oznakaOrgJedinice, klijentID, nazivTipa
    )
    SELECT v.primljen, v.potpisan, v.pecat,
           CASE WHEN k.nazivTipa = N'Preduzetnik' THEN k.poslovniEmail END,
           v.uloga, v.kategorijaPrihoda, v.oj, d.klijentID, k.nazivTipa
    FROM (VALUES
        (1, '20261005', '20261005', 1, N'Zakonski zastupnik upisan u registar',
         N'do 1.000.000 EUR', N'TEST-BG'),
        (2, '20261007', '20261007', 0, N'Zakonski zastupnik upisan u registar',
         N'preko 1.000.000 EUR', N'TEST-NS'),
        (3, '20261012', '20261012', 0, N'Preduzetnik', NULL, N'TEST-NS'),
        (4, '20261014', '20261014', 1, N'Zakonski zastupnik upisan u registar',
         N'do 1.000.000 EUR', N'TEST-NI')
    ) AS v(brojDosijea, primljen, potpisan, pecat, uloga, kategorijaPrihoda, oj)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Klijent AS k ON k.klijentID = d.klijentID;

    INSERT INTO dbo.ZahtevFormatIzvoda (zahtevID, formatIzvodaID)
    SELECT z.zahtevID, f.formatIzvodaID
    FROM (VALUES (1, N'.pdf'), (2, N'.xml'), (3, N'.txt'), (4, N'.pdf')) AS v(brojDosijea, formatIzvoda)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.FormatIzvoda AS f ON f.nazivFormata = v.formatIzvoda;

    INSERT INTO dbo.PodesavanjeDostave (
        zahtevID, dostavaIzvodID, email, dinarskiIzvod, dinarskaOstalaObavestenja,
        devizniIzvod, deviznaOstalaObavestenja, obavestenjeDevizniPrilivi,
        obracunProvizijeProdajaDeviza, swiftObavestenje
    )
    SELECT z.zahtevID, 1, k.poslovniEmail, v.dinIzvod, v.dinObavestenja, v.devIzvod,
           v.devObavestenja, v.devPrilivi, v.devProvizija, v.swift
    FROM (VALUES
        (1, 1, 1, 0, 0, 0, 0, 0),
        (2, 0, 0, 1, 1, 1, 1, 1),
        (3, 1, 0, 0, 0, 0, 0, 0),
        (4, 0, 0, 1, 0, 1, 0, 0)
    ) AS v(brojDosijea, dinIzvod, dinObavestenja, devIzvod, devObavestenja, devPrilivi, devProvizija, swift)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Klijent AS k ON k.klijentID = d.klijentID
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID;

    -- Izabrani servisi i kartice na zahtevu za otvaranje raèuna.
    INSERT INTO dbo.ZahtevDodatnaUsluga (zahtevID, uslugaID)
    SELECT z.zahtevID, u.uslugaID
    FROM (VALUES
        (1, N'NLB eBizKlik'),
        (1, N'DinaCard poslovna kartica'),
        (1, N'Mastercard Business Contactless kartica'),
        (2, N'Halcom'),
        (3, N'NLB eBizKlik'),
        (3, N'DinaCard poslovna kartica'),
        (3, N'VISA Premium Business kartica'),
        (4, N'Office iBanking')
    ) AS v(brojDosijea, usluga)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.DodatnaUsluga AS u ON u.nazivUsluge = v.usluga;

    INSERT INTO dbo.TrazeniRacun (zahtevID, vrstaRacunaID, osnovRacuna)
    SELECT z.zahtevID, vr.vrstaRacunaID, v.osnov
    FROM (VALUES
        (1, N'Dinarski raèun', N'Redovan', NULL),
        (2, N'Devizni raèun', N'Redovan', NULL),
        (3, N'Dinarski raèun', N'Redovan', NULL),
        (4, N'Devizni raèun', N'Namenski', N'Raèun donacija i sponzorstava')
    ) AS v(brojDosijea, vrsta, namena, osnov)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.VrstaRacuna AS vr ON vr.nazivVrste = v.vrsta AND vr.namenaRacuna = v.namena;

    -- KYC i PEP. Prometi iz KYC upitnika su u EUR.
    INSERT INTO dbo.KycUpitnik (
        kategorijaKYC, vrsenjePlacanjaPremaInostranstvu, oznakaOrgJedinice, datumPrijema,
        datumPotpisivanja, ocekivaniUkupniMesecniPromet, ocekivaniGotovinskiMesecniPromet,
        ocekivaniInostraniMesecniPromet, ocekujePrilivIzInostranstva, ulogaZastupnika,
        klijentID, fizickoLiceID, licniDokID
    )
    SELECT v.kategorija, v.placanjaIno, z.oznakaOrgJedinice, z.datumPrijema, z.datumPotpisivanja,
           v.ukupno, v.gotovinski, v.inostrani, v.priliviIno, z.ulogaPredstavnika,
           d.klijentID, d.fizickoLiceID, ld.licniDokID
    FROM (VALUES
        (1, N'A – Pravno lice', 0, 28000.00, 1200.00, 0.00, 0),
        (2, N'A – Pravno lice', 1, 210000.00, 0.00, 130000.00, 1),
        (3, N'B – Fizièko lice koje obavlja delatnost', 0, 8000.00, 1500.00, 0.00, 0),
        (4, N'C – Neprofitno pravno lice', 0, 16000.00, 0.00, 12000.00, 1)
    ) AS v(brojDosijea, kategorija, placanjaIno, ukupno, gotovinski, inostrani, priliviIno)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.LicniDokument AS ld ON ld.fizickoLiceID = d.fizickoLiceID;

    INSERT INTO dbo.KycPorekloSredstava (kycID, porekloID)
    SELECT u.kycID, p.porekloID
    FROM (VALUES
        (1, N'Prodaja proizvoda i/ili pružanje usluga iz registrovane delatnosti'),
        (2, N'Sredstva iz kredita'),
        (3, N'Prodaja proizvoda i/ili pružanje usluga iz registrovane delatnosti'),
        (4, N'Donacije i sponzorstva')
    ) AS v(brojDosijea, poreklo)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.KycUpitnik AS u ON u.klijentID = d.klijentID
    JOIN dbo.PorekloSredstava AS p ON p.nazivPoreklaSredstava = v.poreklo;

    INSERT INTO dbo.KycSvrhaPoslovnogOdnosa (kycID, svrhaPoslOdnosaID)
    SELECT u.kycID, s.svrhaPoslOdnosaID
    FROM (VALUES
        (1, N'Obavljanje platnog prometa u zemlji'),
        (2, N'Obavljanje meðunarodnog platnog prometa'),
        (3, N'Obavljanje gotovinskih transakcija iz redovnog poslovanja'),
        (4, N'Obavljanje meðunarodnog platnog prometa')
    ) AS v(brojDosijea, svrha)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.KycUpitnik AS u ON u.klijentID = d.klijentID
    JOIN dbo.SvrhaPoslovnogOdnosa AS s ON s.nazivPoslOdnosa = v.svrha;

    INSERT INTO dbo.StvarnoVlasnistvo (kycID, fizickoLiceID, zahtevaPEPizjavu)
    SELECT u.kycID, u.fizickoLiceID, CASE WHEN d.brojDosijea IN (2, 3) THEN 1 ELSE 0 END
    FROM dbo.KycUpitnik AS u
    JOIN @Dosije AS d ON d.klijentID = u.klijentID;

    INSERT INTO dbo.IzjavaZaFunkcionere (
        tipPEPpovezanosti, opisCelokupneImovine, datumPotpisivanja, oznakaEkspoziture,
        potpisDavaocaIzjave, potpisZaposlenog, kycID, fizickoLiceID, licniDokID
    )
    SELECT v.povezanost, v.imovina, u.datumPotpisivanja, u.oznakaOrgJedinice,
           N'TEST-POTPIS – ' + f.ime + N' ' + f.prezime, N'TEST-POTPIS-BANKE',
           u.kycID, u.fizickoLiceID, u.licniDokID
    FROM (VALUES
        (2, N'Èlan uže porodice funkcionera – supružnik èlana gradskog veæa',
         N'Kuæa steèena nasleðivanjem.'),
        (3, N'Bliski saradnik funkcionera – poslovni partner èlana uprave javnog preduzeæa',
         N'Putnièko vozilo i štedni ulog iz zarade.')
    ) AS v(brojDosijea, povezanost, imovina)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.FizickoLice AS f ON f.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.KycUpitnik AS u ON u.klijentID = d.klijentID
    JOIN dbo.StvarnoVlasnistvo AS sv
        ON sv.kycID = u.kycID AND sv.fizickoLiceID = u.fizickoLiceID
    WHERE sv.zahtevaPEPizjavu = 1;

    INSERT INTO dbo.IzjavaIzvorCelokupneImovine (izjavaID, izvorCelokupneImoID)
    SELECT i.izjavaID, x.izvorCelokupneImoID
    FROM (VALUES
        (2, N'Nasledstvo'), (3, N'Zarada')
    ) AS v(brojDosijea, izvor)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.KycUpitnik AS u ON u.klijentID = d.klijentID
    JOIN dbo.IzjavaZaFunkcionere AS i ON i.kycID = u.kycID
    JOIN dbo.IzvorCelokupneImovine AS x ON x.nazivIzvora = v.izvor;

    INSERT INTO dbo.IzjavaOsnovPoreklaImovine (izjavaID, osnovPoreklaID)
    SELECT i.izjavaID, o.osnovPoreklaID
    FROM (VALUES
        (2, N'Ugovor, rešenje o nasleðivanju ili faktura'), (3, N'Zarada')
    ) AS v(brojDosijea, osnov)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.KycUpitnik AS u ON u.klijentID = d.klijentID
    JOIN dbo.IzjavaZaFunkcionere AS i ON i.kycID = u.kycID
    JOIN dbo.OsnovPoreklaImovine AS o ON o.nazivOsnova = v.osnov;

    -- Raèuni i ugovori. Namena se preuzima iz zahteva, a poslovno ime iz Klijenta.
    INSERT INTO dbo.Racun (brojRacuna, IBAN, osnovNamene, klijentID, vrstaRacunaID, poslovnoIme)
    SELECT v.brojRacuna, v.IBAN, tr.osnovRacuna, d.klijentID, tr.vrstaRacunaID, k.poslovnoIme
    FROM (VALUES
        (1, '000000000000000101', NULL),
        (2, '000000000000000102', 'RS00000000000000000102'),
        (3, '000000000000000103', NULL),
        (4, '000000000000000104', 'RS00000000000000000104')
    ) AS v(brojDosijea, brojRacuna, IBAN)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Klijent AS k ON k.klijentID = d.klijentID
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.TrazeniRacun AS tr ON tr.zahtevID = z.zahtevID;

    INSERT INTO dbo.UgovorODinarskomRacunu (
        brojUgovora, datumZakljucenja, nazivOrgJedinice, adresaOrgJedinice,
        funkcijaZastupnika, potpisKorisnika, racunID, zahtevID, fizickoLiceID,
        mestoZakljucenjaID, mestoOrgJediniceID
    )
    SELECT v.brojUgovora, v.zakljucen, N'Ekspozitura ' + m.nazivMesta, v.adresa,
           v.funkcija, N'TEST-POTPIS – ' + f.ime + N' ' + f.prezime,
           r.racunID, z.zahtevID, d.fizickoLiceID, m.mestoID, m.mestoID
    FROM (VALUES
        (1, N'TEST-DIN-2026-001', '20261006', N'Test adresa banke 10', N'Direktorka'),
        (3, N'TEST-DIN-2026-002', '20261013', N'Test adresa banke 20', N'Preduzetnica')
    ) AS v(brojDosijea, brojUgovora, zakljucen, adresa, funkcija)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Racun AS r ON r.klijentID = d.klijentID
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.FizickoLice AS f ON f.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.Klijent AS k ON k.klijentID = d.klijentID
    JOIN dbo.Mesto AS m ON m.mestoID = k.mestoID;

    INSERT INTO dbo.UgovorODeviznomRacunu (
        brojUgovora, datumZakljucenja, nazivOrgJedinice, adresaOrgJedinice,
        funkcijaZastupnika, potpisKorisnika, racunID, zahtevID, fizickoLiceID,
        mestoZakljucenjaID, mestoOrgJediniceID
    )
    SELECT v.brojUgovora, v.zakljucen, N'Ekspozitura ' + m.nazivMesta, v.adresa,
           v.funkcija, N'TEST-POTPIS – ' + f.ime + N' ' + f.prezime,
           r.racunID, z.zahtevID, d.fizickoLiceID, m.mestoID, m.mestoID
    FROM (VALUES
        (2, N'TEST-DEV-2026-001', '20261008', N'Test adresa banke 20', N'Direktor'),
        (4, N'TEST-DEV-2026-002', '20261015', N'Test adresa banke 30', N'Predsednik udruženja')
    ) AS v(brojDosijea, brojUgovora, zakljucen, adresa, funkcija)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Racun AS r ON r.klijentID = d.klijentID
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.FizickoLice AS f ON f.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.Klijent AS k ON k.klijentID = d.klijentID
    JOIN dbo.Mesto AS m ON m.mestoID = k.mestoID;

    -- Kartoni deponovanih potpisa i ovlašæenja
    INSERT INTO dbo.KartonDeponovanihPotpisa (datumOvere, fizickoLiceID)
    SELECT v.overen, d.fizickoLiceID
    FROM (VALUES (1, '20261006'), (2, '20261008'), (3, '20261013'), (4, '20261015')) AS v(brojDosijea, overen)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea;

    INSERT INTO dbo.KartonRacun (kartonID, racunID)
    SELECT kp.kartonID, r.racunID
    FROM @Dosije AS d
    JOIN dbo.KartonDeponovanihPotpisa AS kp ON kp.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.Racun AS r ON r.klijentID = d.klijentID;

    INSERT INTO dbo.OvlascenjeZaRaspolaganje (
        kartonID, fizickoLiceID, nacinRaspolaganja, vrstaOgranicenja,
        valutaOgranicenja, odIznosa, doIznosa, potpisOvlascenog
    )
    SELECT kp.kartonID, d.fizickoLiceID, N'Samostalno', v.ogranicenje,
           v.valuta, v.odIznosa, v.doIznosa, N'TEST-POTPIS – ' + f.ime + N' ' + f.prezime
    FROM (VALUES
        (1, N'Neogranièeno', NULL, NULL, NULL),
        (2, N'Ogranièeno', 'EUR', 0.00, 25000.00),
        (3, N'Ogranièeno', 'RSD', 0.00, 300000.00),
        (4, N'Ogranièeno', 'EUR', 0.00, 10000.00)
    ) AS v(brojDosijea, ogranicenje, valuta, odIznosa, doIznosa)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.KartonDeponovanihPotpisa AS kp ON kp.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.FizickoLice AS f ON f.fizickoLiceID = d.fizickoLiceID;

    INSERT INTO dbo.OvlasceniDonosiociDokument (
        oznakaOrganizacioneJedinice, datumVazenja, potpisZaposlenog, fizickoLiceID
    )
    SELECT z.oznakaOrgJedinice, DATEADD(YEAR, 1, kp.datumOvere), N'TEST-POTPIS-BANKE', d.fizickoLiceID
    FROM @Dosije AS d
    JOIN dbo.ZahtevZaOtvaranjeRacuna AS z ON z.klijentID = d.klijentID
    JOIN dbo.KartonDeponovanihPotpisa AS kp ON kp.fizickoLiceID = d.fizickoLiceID;

    INSERT INTO dbo.OvlasceniDonosiociRacun (ovlDokumentiID, racunID)
    SELECT od.ovlDokumentiID, r.racunID
    FROM @Dosije AS d
    JOIN dbo.OvlasceniDonosiociDokument AS od ON od.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.Racun AS r ON r.klijentID = d.klijentID;

    INSERT INTO dbo.NavediDonosioca (ovlDokumentiID, fizickoLiceID, potpisDonosioca, licniDokID)
    SELECT od.ovlDokumentiID, d.fizickoLiceID, N'TEST-POTPIS – ' + f.ime + N' ' + f.prezime, ld.licniDokID
    FROM @Dosije AS d
    JOIN dbo.OvlasceniDonosiociDokument AS od ON od.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.FizickoLice AS f ON f.fizickoLiceID = d.fizickoLiceID
    JOIN dbo.LicniDokument AS ld ON ld.fizickoLiceID = d.fizickoLiceID;

    -- Preko ugovora povezujemo dinarski raèun sa karticama izabranim pri otvaranju.
    DECLARE @IzabraneKartice TABLE (
        racunID INT NOT NULL,
        vrstaKarticeID INT NOT NULL,
        PRIMARY KEY (racunID, vrstaKarticeID)
    );

    INSERT INTO @IzabraneKartice (racunID, vrstaKarticeID)
    SELECT ud.racunID, vk.vrstaKarticeID
    FROM dbo.UgovorODinarskomRacunu AS ud
    JOIN dbo.ZahtevDodatnaUsluga AS zd ON zd.zahtevID = ud.zahtevID
    JOIN dbo.DodatnaUsluga AS u ON u.uslugaID = zd.uslugaID
    JOIN dbo.VrstaKartice AS vk ON vk.nazivVrsteKartice = u.nazivUsluge
    WHERE u.kategorijaUsluge = N'Platne kartice';

    -- Jedan zahtev za izdavanje po raèunu sa bar jednom izabranom karticom.
    INSERT INTO dbo.ZahtevZaIzdavanjeKartica (
        nacinKomunikacije, datumPotpisivanja, nazivNosiocaNaKartici, nacinDostaveKartice,
        ekspozituraZaDostavu, racunID, kontaktLiceID, zastupnikID
    )
    SELECT v.nacinKomunikacije, v.datumPotpisivanja, v.nazivNosiocaNaKartici, v.nacinDostaveKartice,
           v.ekspozituraZaDostavu, r.racunID, d.fizickoLiceID, d.fizickoLiceID
    FROM (VALUES
        (1, '20261009', N'Poštom', N'ANAFIRMA', N'Slanje na adresu sedišta', NULL),
        (3, '20261014', N'E-mail', N'JELENAPREDUZETNICA', N'Slanje u ekspozituru', N'Ekspozitura Novi Sad')
    ) AS v(brojDosijea, datumPotpisivanja, nacinKomunikacije, nazivNosiocaNaKartici,
           nacinDostaveKartice, ekspozituraZaDostavu)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Racun AS r ON r.klijentID = d.klijentID
    WHERE EXISTS (SELECT 1 FROM @IzabraneKartice AS ik WHERE ik.racunID = r.racunID);

    INSERT INTO dbo.KorisnikUZahtevu (zahtevKarticeID, fizickoLiceID)
    SELECT zahtevKarticeID, zastupnikID
    FROM dbo.ZahtevZaIzdavanjeKartica;

    -- Svaka izabrana vrsta ima svoju stavku. Meseèni limiti su u RSD.
    INSERT INTO dbo.TrazenaKartica (
        zahtevKarticeID, fizickoLiceID, vrstaKarticeID, mesecniLimit, nazivVrsteKartice
    )
    SELECT z.zahtevKarticeID, kz.fizickoLiceID, vk.vrstaKarticeID, v.mesecniLimit, vk.nazivVrsteKartice
    FROM (VALUES
        (1, N'DinaCard poslovna kartica', 60000.00),
        (1, N'Mastercard Business Contactless kartica', 140000.00),
        (3, N'VISA Premium Business kartica', 180000.00),
        (3, N'DinaCard poslovna kartica', 45000.00)
    ) AS v(brojDosijea, nazivVrsteKartice, mesecniLimit)
    JOIN @Dosije AS d ON d.brojDosijea = v.brojDosijea
    JOIN dbo.Racun AS r ON r.klijentID = d.klijentID
    JOIN dbo.ZahtevZaIzdavanjeKartica AS z ON z.racunID = r.racunID
    JOIN dbo.KorisnikUZahtevu AS kz ON kz.zahtevKarticeID = z.zahtevKarticeID
    JOIN dbo.VrstaKartice AS vk ON vk.nazivVrsteKartice = v.nazivVrsteKartice
    JOIN @IzabraneKartice AS ik ON ik.racunID = z.racunID AND ik.vrstaKarticeID = vk.vrstaKarticeID;

    -- Provera sva èetiri denormalizovana polja pre potvrde transakcije.
    IF EXISTS (
        SELECT 1 FROM dbo.TrazenaKartica AS tk
        JOIN dbo.VrstaKartice AS vk ON vk.vrstaKarticeID = tk.vrstaKarticeID
        WHERE tk.nazivVrsteKartice IS NULL OR tk.nazivVrsteKartice <> vk.nazivVrsteKartice
    ) OR EXISTS (
        SELECT 1 FROM dbo.Racun AS r
        JOIN dbo.Klijent AS k ON k.klijentID = r.klijentID
        WHERE r.poslovnoIme IS NULL OR r.poslovnoIme <> k.poslovnoIme
    ) OR EXISTS (
        SELECT 1 FROM dbo.Klijent AS k
        JOIN dbo.TipKlijenta AS t ON t.tipKlijentaID = k.tipKlijentaID
        WHERE k.nazivTipa IS NULL OR k.nazivTipa <> t.nazivTipa
    ) OR EXISTS (
        SELECT 1 FROM dbo.ZahtevZaOtvaranjeRacuna AS z
        JOIN dbo.Klijent AS k ON k.klijentID = z.klijentID
        WHERE z.nazivTipa IS NULL OR z.nazivTipa <> k.nazivTipa
    )
        THROW 50002, N'Denormalizovane vrednosti se razlikuju od izvora.', 1;

    DECLARE @BrojRedova TABLE (tabela SYSNAME, ocekivano INT, upisano BIGINT);

    INSERT INTO @BrojRedova (tabela, ocekivano, upisano)
    SELECT N'DodatnaUsluga', 6, COUNT_BIG(*) FROM dbo.DodatnaUsluga UNION ALL
    SELECT N'FizickoLice', 4, COUNT_BIG(*) FROM dbo.FizickoLice UNION ALL
    SELECT N'FormatIzvoda', 3, COUNT_BIG(*) FROM dbo.FormatIzvoda UNION ALL
    SELECT N'IzjavaIzvorCelokupneImovine', 2, COUNT_BIG(*) FROM dbo.IzjavaIzvorCelokupneImovine UNION ALL
    SELECT N'IzjavaOsnovPoreklaImovine', 2, COUNT_BIG(*) FROM dbo.IzjavaOsnovPoreklaImovine UNION ALL
    SELECT N'IzjavaZaFunkcionere', 2, COUNT_BIG(*) FROM dbo.IzjavaZaFunkcionere UNION ALL
    SELECT N'IzvorCelokupneImovine', 3, COUNT_BIG(*) FROM dbo.IzvorCelokupneImovine UNION ALL
    SELECT N'KartonDeponovanihPotpisa', 4, COUNT_BIG(*) FROM dbo.KartonDeponovanihPotpisa UNION ALL
    SELECT N'KartonRacun', 4, COUNT_BIG(*) FROM dbo.KartonRacun UNION ALL
    SELECT N'Klijent', 4, COUNT_BIG(*) FROM dbo.Klijent UNION ALL
    SELECT N'KorisnikUZahtevu', 2, COUNT_BIG(*) FROM dbo.KorisnikUZahtevu UNION ALL
    SELECT N'KycPorekloSredstava', 4, COUNT_BIG(*) FROM dbo.KycPorekloSredstava UNION ALL
    SELECT N'KycSvrhaPoslovnogOdnosa', 4, COUNT_BIG(*) FROM dbo.KycSvrhaPoslovnogOdnosa UNION ALL
    SELECT N'KycUpitnik', 4, COUNT_BIG(*) FROM dbo.KycUpitnik UNION ALL
    SELECT N'LicniDokument', 4, COUNT_BIG(*) FROM dbo.LicniDokument UNION ALL
    SELECT N'Mesto', 3, COUNT_BIG(*) FROM dbo.Mesto UNION ALL
    SELECT N'NavediDonosioca', 4, COUNT_BIG(*) FROM dbo.NavediDonosioca UNION ALL
    SELECT N'OsnovPoreklaImovine', 3, COUNT_BIG(*) FROM dbo.OsnovPoreklaImovine UNION ALL
    SELECT N'OvlasceniDonosiociDokument', 4, COUNT_BIG(*) FROM dbo.OvlasceniDonosiociDokument UNION ALL
    SELECT N'OvlasceniDonosiociRacun', 4, COUNT_BIG(*) FROM dbo.OvlasceniDonosiociRacun UNION ALL
    SELECT N'OvlascenjeZaRaspolaganje', 4, COUNT_BIG(*) FROM dbo.OvlascenjeZaRaspolaganje UNION ALL
    SELECT N'PodesavanjeDostave', 4, COUNT_BIG(*) FROM dbo.PodesavanjeDostave UNION ALL
    SELECT N'PorekloSredstava', 3, COUNT_BIG(*) FROM dbo.PorekloSredstava UNION ALL
    SELECT N'Racun', 4, COUNT_BIG(*) FROM dbo.Racun UNION ALL
    SELECT N'StvarnoVlasnistvo', 4, COUNT_BIG(*) FROM dbo.StvarnoVlasnistvo UNION ALL
    SELECT N'SvrhaPoslovnogOdnosa', 3, COUNT_BIG(*) FROM dbo.SvrhaPoslovnogOdnosa UNION ALL
    SELECT N'TipKlijenta', 3, COUNT_BIG(*) FROM dbo.TipKlijenta UNION ALL
    SELECT N'TrazenaKartica', 4, COUNT_BIG(*) FROM dbo.TrazenaKartica UNION ALL
    SELECT N'TrazeniRacun', 4, COUNT_BIG(*) FROM dbo.TrazeniRacun UNION ALL
    SELECT N'UgovorODeviznomRacunu', 2, COUNT_BIG(*) FROM dbo.UgovorODeviznomRacunu UNION ALL
    SELECT N'UgovorODinarskomRacunu', 2, COUNT_BIG(*) FROM dbo.UgovorODinarskomRacunu UNION ALL
    SELECT N'VrstaKartice', 3, COUNT_BIG(*) FROM dbo.VrstaKartice UNION ALL
    SELECT N'VrstaRacuna', 3, COUNT_BIG(*) FROM dbo.VrstaRacuna UNION ALL
    SELECT N'ZahtevDodatnaUsluga', 8, COUNT_BIG(*) FROM dbo.ZahtevDodatnaUsluga UNION ALL
    SELECT N'ZahtevFormatIzvoda', 4, COUNT_BIG(*) FROM dbo.ZahtevFormatIzvoda UNION ALL
    SELECT N'ZahtevZaIzdavanjeKartica', 2, COUNT_BIG(*) FROM dbo.ZahtevZaIzdavanjeKartica UNION ALL
    SELECT N'ZahtevZaOtvaranjeRacuna', 4, COUNT_BIG(*) FROM dbo.ZahtevZaOtvaranjeRacuna;

    IF EXISTS (SELECT 1 FROM @BrojRedova WHERE upisano <> ocekivano)
    BEGIN
        SELECT tabela, ocekivano, upisano FROM @BrojRedova WHERE upisano <> ocekivano ORDER BY tabela;
        THROW 50003, N'Broj redova se razlikuje od oèekivanog. Unos je poništen.', 1;
    END;

    SELECT tabela, ocekivano, upisano FROM @BrojRedova ORDER BY tabela;
    PRINT N'Transakcija je otvorena. Posle pregleda izvrši COMMIT ili ROLLBACK u istom SSMS prozoru.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

COMMIT;