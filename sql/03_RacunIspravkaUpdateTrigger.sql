CREATE OR ALTER TRIGGER trg_RacunUpdateDenorm
ON dbo.Racun
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(klijentID)
    BEGIN
        UPDATE r
        SET r.poslovnoIme = k.poslovnoIme
        FROM dbo.Racun r
        JOIN inserted i ON r.racunID = i.racunID
        JOIN dbo.Klijent k ON k.klijentID = i.klijentID
        WHERE r.poslovnoIme IS NULL
           OR r.poslovnoIme <> k.poslovnoIme;
    END

    ELSE IF UPDATE(poslovnoIme)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN dbo.Klijent k ON k.klijentID = i.klijentID
            WHERE i.poslovnoIme IS NULL
               OR i.poslovnoIme <> k.poslovnoIme
        )
            THROW 51002,
                'Poslovno ime racuna mora odgovarati klijentu.',
                1;
    END
END;
GO
