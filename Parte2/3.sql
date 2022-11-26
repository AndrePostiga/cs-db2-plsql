-- Criação da Procedure
CREATE OR REPLACE PROCEDURE
    insert_track (
        id_in IN CHINOOK.TRACK.TRACKID%TYPE,
        name_in IN CHINOOK.TRACK.NAME%TYPE,
        album_in IN CHINOOK.TRACK.ALBUMID%TYPE,
        media_in IN CHINOOK.TRACK.MEDIATYPEID%TYPE,
        genre_in IN CHINOOK.TRACK.GENREID%TYPE,
        composer_in IN CHINOOK.TRACK.COMPOSER%TYPE,
        ms_in IN CHINOOK.TRACK.MILLISECONDS%TYPE,
        bytes_in IN CHINOOK.TRACK.BYTES%TYPE,
        price_in IN CHINOOK.TRACK.UNITPRICE%TYPE
    )
IS
    mBytes float;
    trackCount number;
BEGIN
    mBytes := bytes_in/(1024*1024);
    IF (mBytes > 1 and mBytes <= 2 and price_in < 0.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 1 to 2 MBytes is 0.99');
    ELSIF (mBytes > 2 and mBytes <= 3 and price_in < 1.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 2 to 3 MBytes is 1.99');
    ELSIF (mBytes > 3 and mBytes <= 4 and price_in < 2.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 3 to 4 MBytes is 2.99');
    ELSIF (mBytes > 4 and mBytes <= 5 and price_in < 3.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 3 to 4 MBytes is 3.99');
    ELSIF (mBytes > 5 and price_in < 4.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 5 MBytes or higher is 4.99');
    END IF;

    SELECT count(*) INTO trackCount
    FROM CHINOOK.TRACK
    WHERE CHINOOK.TRACK.ALBUMID=album_in;

    IF (trackCount >= 10) THEN
        RAISE_APPLICATION_ERROR(-20203, 'Target album already have 10 or more tracks');
    END IF;

    INSERT INTO CHINOOK.TRACK (TRACKID, NAME, ALBUMID, MEDIATYPEID, GENREID, COMPOSER, MILLISECONDS, BYTES, UNITPRICE)
    VALUES (id_in, name_in, album_in, media_in, genre_in, composer_in, ms_in, bytes_in, price_in);
END;


-- Criação do usuário
CREATE USER teste IDENTIFIED by testePassword
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 10M ON users;

-- Permissionamento do usuário somente pra procedure e select na tabela
GRANT CONNECT to teste;
GRANT RESOURCE to teste;
GRANT CREATE SESSION to teste;
GRANT execute on CHINOOK.INSERT_TRACK to teste;
GRANT SELECT on CHINOOK.TRACK to teste;

-- Teste da procedure
BEGIN
 CHINOOK.INSERT_TRACK(8999994, 'Track Teste', 3, 1, 1, 'Composer Teste', 123456, 4999999, 4.70);
END;