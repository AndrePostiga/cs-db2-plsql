
-- Trigger para: O preço mínimo por quantidade de bytes
CREATE OR REPLACE TRIGGER minimum_price_per_mbyte
BEFORE INSERT OR UPDATE ON CHINOOK.TRACK
FOR EACH ROW
DECLARE
    mBytes float;
BEGIN
    mBytes := :NEW.BYTES/(1024*1024);
    IF (mBytes > 1 and mBytes <= 2 and :NEW.UNITPRICE < 0.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 1 to 2 MBytes is 0.99');
    ELSIF (mBytes > 2 and mBytes <= 3 and :NEW.UNITPRICE < 1.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 2 to 3 MBytes is 1.99');
    ELSIF (mBytes > 3 and mBytes <= 4 and :NEW.UNITPRICE < 2.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 3 to 4 MBytes is 2.99');
    ELSIF (mBytes > 4 and mBytes <= 5 and :NEW.UNITPRICE < 3.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 3 to 4 MBytes is 3.99');
    ELSIF (mBytes > 5 and :NEW.UNITPRICE < 4.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 5 MBytes or higher is 4.99');
    END IF;
END;

-- Scripts de teste
UPDATE CHINOOK.TRACK SET CHINOOK.TRACK.UNITPRICE=0.70 WHERE CHINOOK.TRACK.TRACKID=3;
INSERT INTO CHINOOK.TRACK (TRACKID, NAME, ALBUMID, MEDIATYPEID, GENREID, COMPOSER, MILLISECONDS, BYTES, UNITPRICE)
VALUES (99999, 'Track Teste', 1, 1, 1, 'Composer Teste', 123456, 3999999, 0.70);


-- Trigger para: Álbum com menos de 20 músicas
-- OBS: Não se pode usar o BEFORE, pois não dá pra fazer a função de agregação em uma tabela que está sendo modificada
-- Especificação: https://www.techonthenet.com/oracle/errors/ora04091.php

-- Tentativa usando BEFORE
CREATE OR REPLACE TRIGGER maximum_tracks_per_album
BEFORE INSERT OR UPDATE ON CHINOOK.TRACK
FOR EACH ROW
DECLARE
    trackCount number;
BEGIN

    SELECT count(*) INTO trackCount
    FROM CHINOOK.TRACK
    WHERE CHINOOK.TRACK.ALBUMID=:NEW.ALBUMID;

    IF (trackCount >= 10) THEN
        RAISE_APPLICATION_ERROR(-20203, 'Target album already have 10 or more tracks');
    END IF;
END;

-- Tentativa usando Compound Trigger
CREATE OR REPLACE TRIGGER maximum_tracks_per_album
FOR INSERT OR UPDATE ON CHINOOK.TRACK
COMPOUND TRIGGER

    TYPE row_track_type IS RECORD
    (
        TRACKID CHINOOK.TRACK.TRACKID%TYPE,
        NAME CHINOOK.TRACK.NAME%TYPE,
        ALBUMID CHINOOK.TRACK.ALBUMID%TYPE,
        MEDIATYPEID CHINOOK.TRACK.MEDIATYPEID%TYPE,
        GENREID CHINOOK.TRACK.GENREID%TYPE,
        COMPOSER CHINOOK.TRACK.COMPOSER%TYPE,
        MILLISECONDS CHINOOK.TRACK.MILLISECONDS%TYPE,
        BYTES CHINOOK.TRACK.BYTES%TYPE,
        UNITPRICE CHINOOK.TRACK.UNITPRICE%TYPE
    );

    TYPE table_track_type IS TABLE OF row_track_type INDEX BY PLS_INTEGER;

    table_track table_track_type;

BEFORE EACH ROW IS
BEGIN
    table_track(table_track.COUNT + 1).TRACKID := :NEW.TRACKID;
    table_track(table_track.COUNT).NAME := :NEW.NAME;
    table_track(table_track.COUNT).ALBUMID := :NEW.ALBUMID;
    table_track(table_track.COUNT).MEDIATYPEID := :NEW.MEDIATYPEID;
    table_track(table_track.COUNT).GENREID := :NEW.GENREID;
    table_track(table_track.COUNT).COMPOSER := :NEW.COMPOSER;
    table_track(table_track.COUNT).MILLISECONDS := :NEW.MILLISECONDS;
    table_track(table_track.COUNT).BYTES := :NEW.BYTES;
    table_track(table_track.COUNT).UNITPRICE := :NEW.UNITPRICE;
END BEFORE EACH ROW;

BEFORE STATEMENT IS
    trackCount number;
BEGIN
    FOR idx IN 1 .. table_track.COUNT
    LOOP
        SELECT COUNT(*) INTO trackCount FROM CHINOOK.TRACK WHERE CHINOOK.TRACK.ALBUMID=table_track(idx).ALBUMID;
        IF (trackCount > 10) THEN
            RAISE_APPLICATION_ERROR(-20203, 'Target album already have 10 or more tracks');
        END IF;
    END LOOP;
END BEFORE STATEMENT;
END;