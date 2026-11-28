CREATE OR ALTER TRIGGER trg_TrazenaKarticaUpdateDenorm
ON dbo.TrazenaKartica
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    IF UPDATE(vrstaKarticeID)
    BEGIN
        THROW 51001,
            'Izmena vrstaKarticeID nije dozvoljena.',
            1;
    END

    IF UPDATE(nazivVrsteKartice)
    BEGIN
        DECLARE @kaskada BIT = 0;

        IF TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterUpdate'),
            'AFTER', 'DML') > 0

        OR TRIGGER_NESTLEVEL(
            OBJECT_ID('dbo.trg_afterInsert'),
            'AFTER', 'DML') > 0
        BEGIN
            SET @kaskada = 1;
        END

        IF @kaskada = 0
        BEGIN
            THROW 51002,
                'Direktna izmena naziva vrste kartice nije dozvoljena.',
                1;
        END
    END
END;
GO
