CREATE OR ALTER TRIGGER trg_KlijentUpdateDenorm
ON dbo.Klijent
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    IF UPDATE(tipKlijentaID)
    BEGIN
        THROW 51005,
            'Izmena tipKlijentaID nije dozvoljena.',
            1;
    END

    IF UPDATE(nazivTipa)
    BEGIN
        DECLARE @kaskada BIT = 0;

        IF TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterUpdateTipKlijenta'),
            'AFTER', 'DML') > 0

        OR TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterInsertKlijent'),
            'AFTER', 'DML') > 0
        BEGIN
            SET @kaskada = 1;
        END

        IF @kaskada = 0
        BEGIN
            THROW 51006,
                'Direktna izmena naziva tipa klijenta nije dozvoljena.',
                1;
        END
    END
END;
GO