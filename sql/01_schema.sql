USE BankaRacuniDB;
GO

CREATE TABLE Mesto (
    mestoID INT IDENTITY(1,1) PRIMARY KEY,
    nazivMesta NVARCHAR(100) NOT NULL,
    nazivDrzave NVARCHAR(100) NOT NULL
);



CREATE TABLE TipKlijenta (
    tipKlijentaID INT IDENTITY(1,1) PRIMARY KEY,
    nazivTipa NVARCHAR(100) NOT NULL
);

CREATE TABLE Klijent (
    klijentID INT IDENTITY(1,1) PRIMARY KEY,
    PIB VARCHAR(9) NOT NULL UNIQUE,
    maticniBroj VARCHAR(8),
    poslovnoIme NVARCHAR(200) NOT NULL,
    ulicaBroj NVARCHAR(200),
    poslovniTelefon VARCHAR(30),
    poslovniEmail NVARCHAR(254),
    delatnost NVARCHAR(200),
    webStranica NVARCHAR(255),
    drzavaOsnivanja NVARCHAR(100),
    brojZaposlenih INT,
    sifraDelatnosti VARCHAR(20),
    postanskiBrSedista VARCHAR(12),
    tipKlijentaID INT NOT NULL,
    mestoID INT NOT NULL,

    CONSTRAINT FK_Klijent_Tip
        FOREIGN KEY (tipKlijentaID)
        REFERENCES TipKlijenta(tipKlijentaID),

    CONSTRAINT FK_Klijent_Mesto
        FOREIGN KEY (mestoID)
        REFERENCES Mesto(mestoID),

    CONSTRAINT CK_Klijent_Zaposleni
        CHECK (brojZaposlenih >= 0)
);

CREATE TABLE ZahtevZaOtvaranjeRacuna (
    zahtevID INT IDENTITY(1,1) PRIMARY KEY,
    datumPrijema DATE NOT NULL,
    datumPotpisivanja DATE,
    koristiPecat BIT,
    emailZaIzmeneOkvirnogUgovora NVARCHAR(254),
    ulogaPredstavnika NVARCHAR(100),
    kategorijaPrihoda NVARCHAR(100),
    oznakaOrgJedinice NVARCHAR(50),
    klijentID INT NOT NULL,

    CONSTRAINT FK_ZahtevOtvaranje_Klijent
        FOREIGN KEY (klijentID)
        REFERENCES Klijent(klijentID)
);

CREATE TABLE FormatIzvoda (
    formatIzvodaID INT IDENTITY(1,1) PRIMARY KEY,
    nazivFormata NVARCHAR(50) NOT NULL
);

CREATE TABLE ZahtevFormatIzvoda (
    zahtevID INT NOT NULL,
    formatIzvodaID INT NOT NULL,

    CONSTRAINT PK_ZahtevFormatIzvoda
        PRIMARY KEY (zahtevID, formatIzvodaID),

    CONSTRAINT FK_ZFI_Zahtev
        FOREIGN KEY (zahtevID)
        REFERENCES ZahtevZaOtvaranjeRacuna(zahtevID),

    CONSTRAINT FK_ZFI_Format
        FOREIGN KEY (formatIzvodaID)
        REFERENCES FormatIzvoda(formatIzvodaID)
);


CREATE TABLE PodesavanjeDostave (
    zahtevID INT NOT NULL,
    dostavaIzvodID INT NOT NULL,
    email NVARCHAR(254),
    dinarskiIzvod BIT,
    dinarskaOstalaObavestenja BIT,
    devizniIzvod BIT,
    deviznaOstalaObavestenja BIT,
    obavestenjeDevizniPrilivi BIT,
    obracunProvizijeProdajaDeviza BIT,
    swiftObavestenje BIT,

    CONSTRAINT PK_PodesavanjeDostave
        PRIMARY KEY (zahtevID, dostavaIzvodID),

    CONSTRAINT FK_Podesavanje_Zahtev
        FOREIGN KEY (zahtevID)
        REFERENCES ZahtevZaOtvaranjeRacuna(zahtevID)
);


CREATE TABLE DodatnaUsluga (
    uslugaID INT IDENTITY(1,1) PRIMARY KEY,
    nazivUsluge NVARCHAR(100) NOT NULL,
    kategorijaUsluge NVARCHAR(100)
);


CREATE TABLE ZahtevDodatnaUsluga (
    zahtevID INT NOT NULL,
    uslugaID INT NOT NULL,

    CONSTRAINT PK_ZahtevDodatnaUsluga
        PRIMARY KEY (zahtevID, uslugaID),

    CONSTRAINT FK_ZDU_Zahtev
        FOREIGN KEY (zahtevID)
        REFERENCES ZahtevZaOtvaranjeRacuna(zahtevID),

    CONSTRAINT FK_ZDU_Usluga
        FOREIGN KEY (uslugaID)
        REFERENCES DodatnaUsluga(uslugaID)
);


CREATE TABLE VrstaRacuna (
    vrstaRacunaID INT IDENTITY(1,1) PRIMARY KEY,
    nazivVrste NVARCHAR(100) NOT NULL,
    namenaRacuna NVARCHAR(100)
);

CREATE TABLE TrazeniRacun (
    zahtevID INT NOT NULL,
    vrstaRacunaID INT NOT NULL,
    osnovRacuna NVARCHAR(200),

    CONSTRAINT PK_TrazeniRacun
        PRIMARY KEY (zahtevID, vrstaRacunaID),

    CONSTRAINT FK_TrazeniRacun_Zahtev
        FOREIGN KEY (zahtevID)
        REFERENCES ZahtevZaOtvaranjeRacuna(zahtevID),

    CONSTRAINT FK_TrazeniRacun_Vrsta
        FOREIGN KEY (vrstaRacunaID)
        REFERENCES VrstaRacuna(vrstaRacunaID)
);

CREATE TABLE FizickoLice (
    fizickoLiceID INT IDENTITY(1,1) PRIMARY KEY,
    ime NVARCHAR(100) NOT NULL,
    prezime NVARCHAR(100) NOT NULL,
    JMBGIliIdentifikacioniBroj VARCHAR(30),
    drzavljanstvo NVARCHAR(100),
    datumRodjenja DATE,
    ulicaIBrojPrebivalista NVARCHAR(200),
    postanskiBrojPrebivalista VARCHAR(12),
    email NVARCHAR(254),
    brojTelefona VARCHAR(30),
    mestoRodjenjaID INT,
    mestoPrebivalistaID INT,

    CONSTRAINT FK_FizickoLice_Rodjenje
        FOREIGN KEY (mestoRodjenjaID)
        REFERENCES Mesto(mestoID),

    CONSTRAINT FK_FizickoLice_Prebivaliste
        FOREIGN KEY (mestoPrebivalistaID)
        REFERENCES Mesto(mestoID)
);

CREATE TABLE LicniDokument (
    licniDokID INT IDENTITY(1,1) PRIMARY KEY,
    vrstaDokumenta NVARCHAR(80) NOT NULL,
    brLicnogDokumenta NVARCHAR(50),
    datumIzdavanjaDokumenta DATE,
    datumVazenjaDokumenta DATE,
    nazivIzdavDok NVARCHAR(150),
    fizickoLiceID INT NOT NULL,
    mestoIzdavanjaID INT,

    CONSTRAINT UQ_LicniDokument_Vlasnik
        UNIQUE (licniDokID, fizickoLiceID),

    CONSTRAINT FK_LicniDokument_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT FK_LicniDokument_Mesto
        FOREIGN KEY (mestoIzdavanjaID)
        REFERENCES Mesto(mestoID),

    CONSTRAINT CK_LicniDokument_Datumi
        CHECK (
            datumVazenjaDokumenta >= datumIzdavanjaDokumenta
            OR datumVazenjaDokumenta IS NULL
            OR datumIzdavanjaDokumenta IS NULL
        )
);

CREATE TABLE KycUpitnik (
    kycID INT IDENTITY(1,1) PRIMARY KEY,
    kategorijaKYC NVARCHAR(100),
    vrsenjePlacanjaPremaInostranstvu BIT,
    oznakaOrgJedinice NVARCHAR(50),
    datumPrijema DATE NOT NULL,
    datumPotpisivanja DATE,
    ocekivaniUkupniMesecniPromet DECIMAL(18,2),
    ocekivaniGotovinskiMesecniPromet DECIMAL(18,2),
    ocekivaniInostraniMesecniPromet DECIMAL(18,2),
    ocekujePrilivIzInostranstva BIT,
    ulogaZastupnika NVARCHAR(100),
    klijentID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    licniDokID INT,

    CONSTRAINT FK_Kyc_Klijent
        FOREIGN KEY (klijentID)
        REFERENCES Klijent(klijentID),

    CONSTRAINT FK_Kyc_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT FK_Kyc_LicniDokument
        FOREIGN KEY (licniDokID, fizickoLiceID)
        REFERENCES LicniDokument(licniDokID, fizickoLiceID),

    CONSTRAINT CK_Kyc_Promet
        CHECK (
            (ocekivaniUkupniMesecniPromet IS NULL
             OR ocekivaniUkupniMesecniPromet >= 0)
            AND
            (ocekivaniGotovinskiMesecniPromet IS NULL
             OR ocekivaniGotovinskiMesecniPromet >= 0)
            AND
            (ocekivaniInostraniMesecniPromet IS NULL
             OR ocekivaniInostraniMesecniPromet >= 0)
        )
);

CREATE TABLE PorekloSredstava (
    porekloID INT IDENTITY(1,1) PRIMARY KEY,
    nazivPoreklaSredstava NVARCHAR(200) NOT NULL
);

CREATE TABLE KycPorekloSredstava (
    kycID INT NOT NULL,
    porekloID INT NOT NULL,

    CONSTRAINT PK_KycPorekloSredstava
        PRIMARY KEY (kycID, porekloID),

    CONSTRAINT FK_KPS_Kyc
        FOREIGN KEY (kycID)
        REFERENCES KycUpitnik(kycID),

    CONSTRAINT FK_KPS_Poreklo
        FOREIGN KEY (porekloID)
        REFERENCES PorekloSredstava(porekloID)
);

CREATE TABLE SvrhaPoslovnogOdnosa (
    svrhaPoslOdnosaID INT IDENTITY(1,1) PRIMARY KEY,
    nazivPoslOdnosa NVARCHAR(200) NOT NULL
);

CREATE TABLE KycSvrhaPoslovnogOdnosa (
    kycID INT NOT NULL,
    svrhaPoslOdnosaID INT NOT NULL,

    CONSTRAINT PK_KycSvrhaPoslovnogOdnosa
        PRIMARY KEY (kycID, svrhaPoslOdnosaID),

    CONSTRAINT FK_KSPO_Kyc
        FOREIGN KEY (kycID)
        REFERENCES KycUpitnik(kycID),

    CONSTRAINT FK_KSPO_Svrha
        FOREIGN KEY (svrhaPoslOdnosaID)
        REFERENCES SvrhaPoslovnogOdnosa(svrhaPoslOdnosaID)
);

CREATE TABLE StvarnoVlasnistvo (
    kycID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    zahtevaPEPizjavu BIT NOT NULL DEFAULT 0,

    CONSTRAINT PK_StvarnoVlasnistvo
        PRIMARY KEY (kycID, fizickoLiceID),

    CONSTRAINT FK_StvarnoVlasnistvo_Kyc
        FOREIGN KEY (kycID)
        REFERENCES KycUpitnik(kycID),

    CONSTRAINT FK_StvarnoVlasnistvo_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID)
);

CREATE TABLE Racun (
    racunID INT IDENTITY(1,1) PRIMARY KEY,
    brojRacuna VARCHAR(34) NOT NULL UNIQUE,
    IBAN VARCHAR(34),
    osnovNamene NVARCHAR(200),
    klijentID INT NOT NULL,
    vrstaRacunaID INT NOT NULL,

    CONSTRAINT FK_Racun_Klijent
        FOREIGN KEY (klijentID)
        REFERENCES Klijent(klijentID),

    CONSTRAINT FK_Racun_Vrsta
        FOREIGN KEY (vrstaRacunaID)
        REFERENCES VrstaRacuna(vrstaRacunaID)
);

CREATE TABLE KartonDeponovanihPotpisa (
    kartonID INT IDENTITY(1,1) PRIMARY KEY,
    datumOvere DATE,
    fizickoLiceID INT NOT NULL,

    CONSTRAINT FK_Karton_Potpisnik
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID)
);

CREATE TABLE KartonRacun (
    kartonID INT NOT NULL,
    racunID INT NOT NULL,

    CONSTRAINT PK_KartonRacun
        PRIMARY KEY (kartonID, racunID),

    CONSTRAINT FK_KartonRacun_Karton
        FOREIGN KEY (kartonID)
        REFERENCES KartonDeponovanihPotpisa(kartonID),

    CONSTRAINT FK_KartonRacun_Racun
        FOREIGN KEY (racunID)
        REFERENCES Racun(racunID)
);

CREATE TABLE OvlascenjeZaRaspolaganje (
    kartonID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    nacinRaspolaganja NVARCHAR(150),
    vrstaOgranicenja NVARCHAR(150),
    valutaOgranicenja CHAR(3),
    odIznosa DECIMAL(18,2),
    doIznosa DECIMAL(18,2),
    potpisOvlascenog NVARCHAR(255),

    CONSTRAINT PK_OvlascenjeZaRaspolaganje
        PRIMARY KEY (kartonID, fizickoLiceID),

    CONSTRAINT FK_OvRaspolaganje_Karton
        FOREIGN KEY (kartonID)
        REFERENCES KartonDeponovanihPotpisa(kartonID),

    CONSTRAINT FK_OvRaspolaganje_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT CK_OvRaspolaganje_Iznosi
        CHECK (
            (odIznosa IS NULL OR odIznosa >= 0)
            AND
            (doIznosa IS NULL OR doIznosa >= 0)
            AND
            (odIznosa IS NULL OR doIznosa IS NULL
             OR doIznosa >= odIznosa)
        )
);

CREATE TABLE OvlasceniDonosiociDokument (
    ovlDokumentiID INT IDENTITY(1,1) PRIMARY KEY,
    oznakaOrganizacioneJedinice NVARCHAR(50),
    datumVazenja DATE,
    potpisZaposlenog NVARCHAR(255),
    fizickoLiceID INT NOT NULL,

    CONSTRAINT FK_OVDokument_Potpisnik
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID)
);

CREATE TABLE OvlasceniDonosiociRacun (
    ovlDokumentiID INT NOT NULL,
    racunID INT NOT NULL,

    CONSTRAINT PK_OvlasceniDonosiociRacun
        PRIMARY KEY (ovlDokumentiID, racunID),

    CONSTRAINT FK_OVR_Dokument
        FOREIGN KEY (ovlDokumentiID)
        REFERENCES OvlasceniDonosiociDokument(ovlDokumentiID),

    CONSTRAINT FK_OVR_Racun
        FOREIGN KEY (racunID)
        REFERENCES Racun(racunID)
);

CREATE TABLE NavediDonosioca (
    ovlDokumentiID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    potpisDonosioca NVARCHAR(255),
    licniDokID INT,

    CONSTRAINT PK_NavediDonosioca
        PRIMARY KEY (ovlDokumentiID, fizickoLiceID),

    CONSTRAINT FK_NavediDonosioca_Dokument
        FOREIGN KEY (ovlDokumentiID)
        REFERENCES OvlasceniDonosiociDokument(ovlDokumentiID),

    CONSTRAINT FK_NavediDonosioca_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT FK_NavediDonosioca_LicniDok
        FOREIGN KEY (licniDokID, fizickoLiceID)
        REFERENCES LicniDokument(licniDokID, fizickoLiceID)
);

CREATE TABLE IzjavaZaFunkcionere (
    izjavaID INT IDENTITY(1,1) PRIMARY KEY,
    vrstaJavneFunkc NVARCHAR(150),
    periodObavFunkc NVARCHAR(150),
    tipPEPpovezanosti NVARCHAR(150),
    opisCelokupneImovine NVARCHAR(MAX),
    datumPotpisivanja DATE,
    oznakaEkspoziture NVARCHAR(50),
    potpisDavaocaIzjave NVARCHAR(255),
    potpisZaposlenog NVARCHAR(255),
    kycID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    licniDokID INT,

    CONSTRAINT FK_Izjava_StvarnoVlasnistvo
        FOREIGN KEY (kycID, fizickoLiceID)
        REFERENCES StvarnoVlasnistvo(kycID, fizickoLiceID),

    CONSTRAINT FK_Izjava_LicniDokument
        FOREIGN KEY (licniDokID, fizickoLiceID)
        REFERENCES LicniDokument(licniDokID, fizickoLiceID)
);

CREATE TABLE IzvorCelokupneImovine (
    izvorCelokupneImoID INT IDENTITY(1,1) PRIMARY KEY,
    nazivIzvora NVARCHAR(200) NOT NULL
);

CREATE TABLE IzjavaIzvorCelokupneImovine (
    izjavaID INT NOT NULL,
    izvorCelokupneImoID INT NOT NULL,

    CONSTRAINT PK_IzjavaIzvorCelokupneImovine
        PRIMARY KEY (izjavaID, izvorCelokupneImoID),

    CONSTRAINT FK_IzjavaIzvor_Izjava
        FOREIGN KEY (izjavaID)
        REFERENCES IzjavaZaFunkcionere(izjavaID),

    CONSTRAINT FK_IzjavaIzvor_Izvor
        FOREIGN KEY (izvorCelokupneImoID)
        REFERENCES IzvorCelokupneImovine(izvorCelokupneImoID)
);

CREATE TABLE OsnovPoreklaImovine (
    osnovPoreklaID INT IDENTITY(1,1) PRIMARY KEY,
    nazivOsnova NVARCHAR(200) NOT NULL
);

CREATE TABLE IzjavaOsnovPoreklaImovine (
    izjavaID INT NOT NULL,
    osnovPoreklaID INT NOT NULL,

    CONSTRAINT PK_IzjavaOsnovPoreklaImovine
        PRIMARY KEY (izjavaID, osnovPoreklaID),

    CONSTRAINT FK_IzjavaOsnov_Izjava
        FOREIGN KEY (izjavaID)
        REFERENCES IzjavaZaFunkcionere(izjavaID),

    CONSTRAINT FK_IzjavaOsnov_Osnov
        FOREIGN KEY (osnovPoreklaID)
        REFERENCES OsnovPoreklaImovine(osnovPoreklaID)
);

CREATE TABLE ZahtevZaIzdavanjeKartica (
    zahtevKarticeID INT IDENTITY(1,1) PRIMARY KEY,
    nacinKomunikacije NVARCHAR(100),
    datumPotpisivanja DATE,
    nazivNosiocaNaKartici NVARCHAR(200),
    nacinDostaveKartice NVARCHAR(100),
    ekspozituraZaDostavu NVARCHAR(150),
    racunID INT NOT NULL,
    kontaktLiceID INT NOT NULL,
    zastupnikID INT NOT NULL,

    CONSTRAINT FK_ZahtevKartica_Racun
        FOREIGN KEY (racunID)
        REFERENCES Racun(racunID),

    CONSTRAINT FK_ZahtevKartica_Kontakt
        FOREIGN KEY (kontaktLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT FK_ZahtevKartica_Zastupnik
        FOREIGN KEY (zastupnikID)
        REFERENCES FizickoLice(fizickoLiceID)
);

CREATE TABLE VrstaKartice (
    vrstaKarticeID INT IDENTITY(1,1) PRIMARY KEY,
    nazivVrsteKartice NVARCHAR(100) NOT NULL
);

CREATE TABLE KorisnikUZahtevu (
    zahtevKarticeID INT NOT NULL,
    fizickoLiceID INT NOT NULL,

    CONSTRAINT PK_KorisnikUZahtevu
        PRIMARY KEY (zahtevKarticeID, fizickoLiceID),

    CONSTRAINT FK_KUZ_Zahtev
        FOREIGN KEY (zahtevKarticeID)
        REFERENCES ZahtevZaIzdavanjeKartica(zahtevKarticeID),

    CONSTRAINT FK_KUZ_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID)
);

CREATE TABLE TrazenaKartica (
    zahtevKarticeID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    vrstaKarticeID INT NOT NULL,
    mesecniLimit DECIMAL(18,2),

    CONSTRAINT PK_TrazenaKartica
        PRIMARY KEY (
            zahtevKarticeID,
            fizickoLiceID,
            vrstaKarticeID
        ),

    CONSTRAINT FK_TrazenaKartica_Korisnik
        FOREIGN KEY (zahtevKarticeID, fizickoLiceID)
        REFERENCES KorisnikUZahtevu(
            zahtevKarticeID, fizickoLiceID
        ),

    CONSTRAINT FK_TrazenaKartica_Vrsta
        FOREIGN KEY (vrstaKarticeID)
        REFERENCES VrstaKartice(vrstaKarticeID),

    CONSTRAINT CK_TrazenaKartica_Limit
        CHECK (mesecniLimit >= 0)
);

CREATE TABLE UgovorODinarskomRacunu (
    ugovorDinID INT IDENTITY(1,1) PRIMARY KEY,
    brojUgovora NVARCHAR(50),
    datumZakljucenja DATE NOT NULL,
    nazivOrgJedinice NVARCHAR(150),
    adresaOrgJedinice NVARCHAR(200),
    funkcijaZastupnika NVARCHAR(150),
    potpisKorisnika NVARCHAR(255),
    racunID INT NOT NULL UNIQUE,
    zahtevID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    mestoZakljucenjaID INT NOT NULL,
    mestoOrgJediniceID INT NOT NULL,

    CONSTRAINT FK_UgovorDin_Racun
        FOREIGN KEY (racunID)
        REFERENCES Racun(racunID),

    CONSTRAINT FK_UgovorDin_Zahtev
        FOREIGN KEY (zahtevID)
        REFERENCES ZahtevZaOtvaranjeRacuna(zahtevID),

    CONSTRAINT FK_UgovorDin_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT FK_UgovorDin_MestoZakljucenja
        FOREIGN KEY (mestoZakljucenjaID)
        REFERENCES Mesto(mestoID),

    CONSTRAINT FK_UgovorDin_MestoOrgJedinice
        FOREIGN KEY (mestoOrgJediniceID)
        REFERENCES Mesto(mestoID)
);

CREATE TABLE UgovorODeviznomRacunu (
    ugovorDevID INT IDENTITY(1,1) PRIMARY KEY,
    brojUgovora NVARCHAR(50),
    datumZakljucenja DATE NOT NULL,
    nazivOrgJedinice NVARCHAR(150),
    adresaOrgJedinice NVARCHAR(200),
    funkcijaZastupnika NVARCHAR(150),
    potpisKorisnika NVARCHAR(255),
    racunID INT NOT NULL UNIQUE,
    zahtevID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    mestoZakljucenjaID INT NOT NULL,
    mestoOrgJediniceID INT NOT NULL,

    CONSTRAINT FK_UgovorDev_Racun
        FOREIGN KEY (racunID)
        REFERENCES Racun(racunID),

    CONSTRAINT FK_UgovorDev_Zahtev
        FOREIGN KEY (zahtevID)
        REFERENCES ZahtevZaOtvaranjeRacuna(zahtevID),

    CONSTRAINT FK_UgovorDev_Lice
        FOREIGN KEY (fizickoLiceID)
        REFERENCES FizickoLice(fizickoLiceID),

    CONSTRAINT FK_UgovorDev_MestoZakljucenja
        FOREIGN KEY (mestoZakljucenjaID)
        REFERENCES Mesto(mestoID),

    CONSTRAINT FK_UgovorDev_MestoOrgJedinice
        FOREIGN KEY (mestoOrgJediniceID)
        REFERENCES Mesto(mestoID)
);



