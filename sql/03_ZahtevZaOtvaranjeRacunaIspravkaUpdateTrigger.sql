CREATE OR ALTER TRIGGER trg_ZahtevOtvaranjeUpdateDenorm
ON dbo.ZahtevZaOtvaranjeRacuna
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    IF UPDATE(klijentID)
    BEGIN
        THROW 51007,
            'Izmena klijentID nije dozvoljena.',
            1;
    END

    IF UPDATE(nazivTipa)
    BEGIN
        DECLARE @kaskada BIT = 0;

        IF TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterUpdateTipKlijenta'),
            'AFTER', 'DML') > 0

        OR TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterInsertZahtevZaOtvaranjeRacuna'),
            'AFTER', 'DML') > 0
        BEGIN
            SET @kaskada = 1;
        END

        IF @kaskada = 0
        BEGIN
            THROW 51008,
                'Direktna izmena naziva tipa zahteva nije dozvoljena.',
                1;
        END
    END
END;
GO