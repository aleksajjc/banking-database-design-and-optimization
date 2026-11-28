CREATE OR ALTER TRIGGER trg_RacunUpdateDenorm
ON dbo.Racun
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    IF UPDATE(klijentID)
    BEGIN
        THROW 51003,
            'Izmena klijentID nije dozvoljena.',
            1;
    END

    IF UPDATE(poslovnoIme)
    BEGIN
        DECLARE @kaskada BIT = 0;

        IF TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterUpdateRacun'),
            'AFTER', 'DML') > 0

        OR TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterInsertRacun'),
            'AFTER', 'DML') > 0
        BEGIN
            SET @kaskada = 1;
        END

        IF @kaskada = 0
        BEGIN
            THROW 51004,
                'Direktna izmena poslovnog imena nije dozvoljena.',
                1;
        END
    END
END;
GO