
USE [BankaRacuniDB];
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @tabelaID INT = OBJECT_ID(N'dbo.LicniDokument', N'U');
    DECLARE @stariPK SYSNAME;
    DECLARE @pkIndex INT;
    DECLARE @uqIndex INT;
    DECLARE @sql NVARCHAR(MAX);

    IF @tabelaID IS NULL
        THROW 51000, 'Tabela LicniDokument ne postoji.', 1;

    SELECT
        @stariPK = name,
        @pkIndex = unique_index_id
    FROM sys.key_constraints
    WHERE parent_object_id = @tabelaID
      AND type = 'PK';

    SELECT @uqIndex = unique_index_id
    FROM sys.key_constraints
    WHERE parent_object_id = @tabelaID
      AND name = N'UQ_LicniDokument_Vlasnik'
      AND type = 'UQ';

    IF @stariPK IS NULL OR @uqIndex IS NULL
        THROW 51001, 'Nedostaje ocekivani PK ili UNIQUE.', 1;

    IF COLUMNPROPERTY(@tabelaID, 'licniDokID', 'IsIdentity') <> 1
        THROW 51002, 'licniDokID nema ocekivani IDENTITY.', 1;

    IF (SELECT COUNT(*)
        FROM sys.index_columns
        WHERE object_id = @tabelaID
          AND index_id = @pkIndex
          AND key_ordinal > 0) <> 1
       OR NOT EXISTS (
        SELECT 1
        FROM sys.index_columns ic
        JOIN sys.columns c
          ON c.object_id = ic.object_id
         AND c.column_id = ic.column_id
        WHERE ic.object_id = @tabelaID
          AND ic.index_id = @pkIndex
          AND ic.key_ordinal = 1
          AND c.name = 'licniDokID'
       )
        THROW 51003, 'Postojeci PK nije ocekivani.', 1;

    -- Nijedan FK ne sme zavisiti od PK koji uklanjamo.
    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE referenced_object_id = @tabelaID
          AND key_index_id <> @uqIndex
    )
        THROW 51004, 'Postoje FK zavisnosti koje treba proveriti.', 1;

    -- Uklanjanje starog primarnog kljuca.
    SET @sql =
        N'ALTER TABLE dbo.LicniDokument DROP CONSTRAINT '
        + QUOTENAME(@stariPK);

    EXEC sys.sp_executesql @sql;

    -- Kreiranje slozenog primarnog kljuca.
    ALTER TABLE dbo.LicniDokument
        ADD CONSTRAINT PK_LicniDokument
        PRIMARY KEY (fizickoLiceID, licniDokID);

    COMMIT TRANSACTION;

    PRINT N'Migracija je uspesno zavrsena.';
    PRINT N'IDENTITY, podaci i postojeci FK su sacuvani.';

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
