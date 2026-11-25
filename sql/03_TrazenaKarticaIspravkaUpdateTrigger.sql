CREATE OR ALTER TRIGGER trg_TrazenaKarticaUpdateDenorm
ON dbo.TrazenaKartica
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(vrstaKarticeID)
    BEGIN
        UPDATE tk
        SET tk.nazivVrsteKartice = vk.nazivVrsteKartice
        FROM dbo.TrazenaKartica tk
        JOIN inserted i
            ON tk.zahtevKarticeID = i.zahtevKarticeID
           AND tk.fizickoLiceID = i.fizickoLiceID
           AND tk.vrstaKarticeID = i.vrstaKarticeID
        JOIN dbo.VrstaKartice vk
            ON vk.vrstaKarticeID = i.vrstaKarticeID
        WHERE tk.nazivVrsteKartice IS NULL
           OR tk.nazivVrsteKartice <> vk.nazivVrsteKartice;
    END

    ELSE IF UPDATE(nazivVrsteKartice)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            JOIN dbo.VrstaKartice vk
                ON vk.vrstaKarticeID = i.vrstaKarticeID
            WHERE i.nazivVrsteKartice IS NULL
               OR i.nazivVrsteKartice <> vk.nazivVrsteKartice
        )
            THROW 51001,
                'Naziv vrste kartice mora odgovarati izabranoj vrsti.',
                1;
    END
END;
GO
