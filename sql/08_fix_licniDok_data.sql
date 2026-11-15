USE BankaRacuniDB;
GO

UPDATE dbo.LicniDokument
SET nazivIzdavDok =
    CASE licniDokID
        WHEN 9 THEN N'Sluzba Beograd'
        WHEN 10 THEN N'Sluzba Beograd'
        WHEN 11 THEN N'Sluzba Beograd'
        WHEN 12 THEN N'Sluzba Beograd'
    END
WHERE licniDokID IN (9, 10, 11, 12);

-- Provera izmenjenih podataka
SELECT
    fizickoLiceID,
    licniDokID,
    vrstaDokumenta,
    nazivIzdavDok
FROM dbo.LicniDokument
WHERE licniDokID IN (9, 10, 11, 12);