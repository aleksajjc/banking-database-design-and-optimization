CREATE PARTITION FUNCTION pf_TrazenaKarticaLimit (DECIMAL(18,2))
AS RANGE LEFT FOR VALUES(50000.00, 100000.00);
GO

ALTER DATABASE BankaRacuniDB ADD FILEGROUP FG_LimitNiski;
ALTER DATABASE BankaRacuniDB ADD FILEGROUP FG_LimitSrednji;
ALTER DATABASE BankaRacuniDB ADD FILEGROUP FG_LimitVisoki;

ALTER DATABASE BankaRacuniDB ADD FILE(
	NAME = 'Banka_LimitNiski',
	FILENAME = 'C:\Banka_LimitNiski.ndf'
) TO FILEGROUP FG_LimitNiski
GO

ALTER DATABASE BankaRacuniDB ADD FILE(
	NAME = 'Banka_LimitSrednji',
	FILENAME = 'C:\Banka_LimitSrednji.ndf'
) TO FILEGROUP FG_LimitSrednji
GO

ALTER DATABASE BankaRacuniDB ADD FILE(
	NAME = 'Banka_LimitVisoki',
	FILENAME = 'C:\Banka_LimitVisoki.ndf'
) TO FILEGROUP FG_LimitVisoki
GO

CREATE PARTITION SCHEME p_TrazenaKarticaLimit
AS PARTITION pf_TrazenaKarticaLimit
TO(
	FG_LimitNiski,
	FG_LimitSrednji,
	FG_LimitVisoki
);
GO

CREATE TABLE dbo.TrazenaKartica_Partitioned
(
    zahtevKarticeID INT NOT NULL,
    fizickoLiceID INT NOT NULL,
    vrstaKarticeID INT NOT NULL,
    mesecniLimit DECIMAL(18,2),
    nazivVrsteKartice NVARCHAR(100)
)
ON p_TrazenaKarticaLimit (mesecniLimit);
GO

INSERT INTO dbo.TrazenaKartica_Partitioned
(
    zahtevKarticeID,
    fizickoLiceID,
    vrstaKarticeID,
    mesecniLimit,
    nazivVrsteKartice
)
SELECT
    zahtevKarticeID,
    fizickoLiceID,
    vrstaKarticeID,
    mesecniLimit,
    nazivVrsteKartice
FROM dbo.TrazenaKartica;

SELECT
    zahtevKarticeID,
    mesecniLimit,
    $PARTITION.pf_TrazenaKarticaLimit(mesecniLimit) AS particija
FROM dbo.TrazenaKartica_Partitioned;

