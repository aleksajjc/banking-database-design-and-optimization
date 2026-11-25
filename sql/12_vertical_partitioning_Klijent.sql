
USE BankaRacuniDB;
GO

CREATE TABLE dbo.Klijent_Poslovni
(
    klijentID INT NOT NULL PRIMARY KEY,
    PIB VARCHAR(9) NOT NULL UNIQUE,
    maticniBroj VARCHAR(8),
    poslovnoIme NVARCHAR(200) NOT NULL,
    delatnost NVARCHAR(200),
    drzavaOsnivanja NVARCHAR(100),
    brojZaposlenih INT,
    sifraDelatnosti VARCHAR(20),
    tipKlijentaID INT NOT NULL,
    nazivTipa NVARCHAR(100),
    aktuelniOcekivaniUkupniMesecniPromet DECIMAL(18,2),

    CONSTRAINT FK_KlijentPoslovni_Tip
        FOREIGN KEY (tipKlijentaID)
        REFERENCES dbo.TipKlijenta(tipKlijentaID),

    CONSTRAINT CK_KlijentPoslovni_Zaposleni
        CHECK (brojZaposlenih >= 0)
);
GO


CREATE TABLE dbo.Klijent_Kontakt
(
    klijentID INT NOT NULL PRIMARY KEY,
    ulicaBroj NVARCHAR(200),
    poslovniTelefon VARCHAR(30),
    poslovniEmail NVARCHAR(254),
    webStranica NVARCHAR(255),
    postanskiBrSedista VARCHAR(12),
    mestoID INT NOT NULL,

    CONSTRAINT FK_KlijentKontakt_Poslovni
        FOREIGN KEY (klijentID)
        REFERENCES dbo.Klijent_Poslovni(klijentID),

    CONSTRAINT FK_KlijentKontakt_Mesto
        FOREIGN KEY (mestoID)
        REFERENCES dbo.Mesto(mestoID)
);
GO


INSERT INTO dbo.Klijent_Poslovni
(
    klijentID,
    PIB,
    maticniBroj,
    poslovnoIme,
    delatnost,
    drzavaOsnivanja,
    brojZaposlenih,
    sifraDelatnosti,
    tipKlijentaID,
    nazivTipa,
    aktuelniOcekivaniUkupniMesecniPromet
)
SELECT
    klijentID,
    PIB,
    maticniBroj,
    poslovnoIme,
    delatnost,
    drzavaOsnivanja,
    brojZaposlenih,
    sifraDelatnosti,
    tipKlijentaID,
    nazivTipa,
    aktuelniOcekivaniUkupniMesecniPromet
FROM dbo.Klijent;
GO


INSERT INTO dbo.Klijent_Kontakt
(
    klijentID,
    ulicaBroj,
    poslovniTelefon,
    poslovniEmail,
    webStranica,
    postanskiBrSedista,
    mestoID
)
SELECT
    klijentID,
    ulicaBroj,
    poslovniTelefon,
    poslovniEmail,
    webStranica,
    postanskiBrSedista,
    mestoID
FROM dbo.Klijent;
GO

-- Prikaz prve particije
SELECT * FROM dbo.Klijent_Poslovni;

-- Prikaz druge particije
SELECT * FROM dbo.Klijent_Kontakt;

-- Rekonstrukcija originalne tabele
SELECT
    p.klijentID,
    p.PIB,
    p.maticniBroj,
    p.poslovnoIme,
    k.ulicaBroj,
    k.poslovniTelefon,
    k.poslovniEmail,
    p.delatnost,
    k.webStranica,
    p.drzavaOsnivanja,
    p.brojZaposlenih,
    p.sifraDelatnosti,
    k.postanskiBrSedista,
    p.tipKlijentaID,
    k.mestoID,
    p.nazivTipa,
    p.aktuelniOcekivaniUkupniMesecniPromet
FROM dbo.Klijent_Poslovni p
JOIN dbo.Klijent_Kontakt k
    ON p.klijentID = k.klijentID;
