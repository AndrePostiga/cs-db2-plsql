
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
    ELSIF (mBytes > 5 and :NEW.UNITPRICE < 3.99) THEN
        RAISE_APPLICATION_ERROR(-20202, 'Minimum price for 5 MBytes or higher is 3.99');
    END IF;
END;

-- Scripts de teste
UPDATE CHINOOK.TRACK SET CHINOOK.TRACK.UNITPRICE=0.70 WHERE CHINOOK.TRACK.TRACKID=3;
INSERT INTO CHINOOK.TRACK (TRACKID, NAME, ALBUMID, MEDIATYPEID, GENREID, COMPOSER, MILLISECONDS, BYTES, UNITPRICE)
VALUES (99999, 'Track Teste', 1, 1, 1, 'Composer Teste', 123456, 3999999, 0.70);


-- Trigger para: Álbum com menos de 20 músicas

