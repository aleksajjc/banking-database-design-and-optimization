USE BankaRacuniDB;
GO

-- 1. Denormalizacija uz narusavanje 2NF
ALTER TABLE dbo.TrazenaKartica
ADD nazivVrsteKartice NVARCHAR(100) NULL;

-- 2. Denormalizacija uz narusavanje 3NF
ALTER TABLE dbo.Racun
ADD poslovnoIme NVARCHAR(200) NULL;

-- 3. Denormalizacija kroz dva nivoa
ALTER TABLE dbo.Klijent
ADD nazivTipa NVARCHAR(100) NULL;

ALTER TABLE dbo.ZahtevZaOtvaranjeRacuna
ADD nazivTipa NVARCHAR(100) NULL;