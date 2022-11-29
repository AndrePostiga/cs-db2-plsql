/* Criar a tabela de IDs */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CHINOOK.TB_SEQ_ID';
EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
END;
/

CREATE TABLE CHINOOK.TB_SEQ_ID
(
    TABLE_NAME    VARCHAR2 (30) NOT NULL,
    SEQ_ID        NUMBER (18)
)
TABLESPACE TBS_DADOS;

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX CHINOOK.SEQ_ID_PK';
EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
END;
/

CREATE UNIQUE INDEX CHINOOK.SEQ_ID_PK
    ON CHINOOK.TB_SEQ_ID (TABLE_NAME)
    TABLESPACE TBS_INDICES
    NOPARALLEL;

BEGIN
    EXECUTE IMMEDIATE 'DROP CONSTRAINT SEQ_ID_PK';
EXCEPTION
    WHEN OTHERS
    THEN
        NULL;
END;
/

ALTER TABLE CHINOOK.TB_SEQ_ID
    ADD (
        CHECK ("SEQ_ID" IS NOT NULL),
        CONSTRAINT SEQ_ID_PK PRIMARY KEY (TABLE_NAME)
            USING INDEX TABLESPACE TBS_INDICES);



INSERT INTO chinook.tb_seq_id (TABLE_NAME, SEQ_ID)
    SELECT 'ALBUM' TABLE_NAME, MAX (ALBUMID) SEQ_ID FROM CHINOOK.album
    UNION
    SELECT 'ARTIST' TABLE_NAME, MAX (ARTISTID) SEQ_ID FROM CHINOOK.ARTIST
    UNION
    SELECT 'CUSTOMER' TABLE_NAME, MAX (CUSTOMERID) SEQ_ID FROM CHINOOK.CUSTOMER
    UNION
    SELECT 'EMPLOYEE' TABLE_NAME, MAX (EMPLOYEEID) SEQ_ID FROM CHINOOK.EMPLOYEE
    UNION
    SELECT 'GENRE' TABLE_NAME, MAX (GENREID) SEQ_ID FROM CHINOOK.GENRE
    UNION
    SELECT 'INVOICE' TABLE_NAME, MAX (INVOICEID) SEQ_ID FROM CHINOOK.INVOICE
    UNION
    SELECT 'INVOICELINE' TABLE_NAME, MAX (INVOICELINEID) SEQ_ID
      FROM CHINOOK.INVOICELINE
    UNION
    SELECT 'MEDIATYPE' TABLE_NAME, MAX (MEDIATYPEID) SEQ_ID FROM CHINOOK.MEDIATYPE
    UNION
    SELECT 'PLAYLIST' TABLE_NAME, MAX (PLAYLISTID) SEQ_ID FROM CHINOOK.PLAYLIST
    UNION
    SELECT 'TRACK' TABLE_NAME, MAX (TRACKID) SEQ_ID FROM CHINOOK.TRACK;

COMMIT;



/* Criar a procedure que retorna o novo sequencial de ID a ser gravado */
CREATE OR REPLACE PROCEDURE chinook.get_seq_id (v_table_name       VARCHAR2,
                                                v_seq_id       OUT NUMBER)
IS
    d_seq_id       NUMBER (18);
BEGIN
    
    v_seq_id := NULL;

    SELECT seq_id
      INTO d_seq_id
      FROM CHINOOK.TB_SEQ_ID
     WHERE table_name = v_table_name
    FOR UPDATE;

    IF (d_seq_id is null)
    THEN
        raise_application_error (
            -20033,
               '55555, No row for '
            || v_table_name
            || ' in CHINOOK.TB_SEQ_ID table.');
    END IF;

    UPDATE CHINOOK.TB_SEQ_ID
       SET seq_id = seq_id + 1
     WHERE table_name = v_table_name;

    SELECT seq_id
      INTO d_seq_id
      FROM CHINOOK.TB_SEQ_ID
     WHERE table_name = v_table_name;


    IF (d_seq_id IS NULL)
    THEN
        raise_application_error (
            -20033,
            '55557, No valid sequence number found in CHINOOK.TB_SEQ_ID table.');
    END IF;

    v_seq_id := d_seq_id;
END;
/



/* Cria um procedimento para gravacao na tabela chinook.track */
CREATE OR REPLACE PROCEDURE CHINOOK.INSERT_TRACK_Q5 (v_track_name     VARCHAR2,
                                                  v_album_id       NUMBER,
                                                  v_media_type     NUMBER,
                                                  v_genre_id       NUMBER,
                                                  v_composer       VARCHAR2,
                                                  v_milliseconds   NUMBER,
                                                  v_bytes          NUMBER,
                                                  v_unit_price     NUMBER)
IS
    d_seq_id        NUMBER;
    d_trans_error   NUMBER;
    d_table_name    VARCHAR2 (30);
BEGIN
    d_table_name := 'TRACK';

    BEGIN
        chinook.get_seq_id (d_table_name, d_seq_id);
    EXCEPTION
        WHEN OTHERS
        THEN
            d_trans_error := SQLCODE;
    END;

    IF (d_trans_error != 0)
    THEN
        raise_application_error (
            -20033,
            '60001, No entry in SEQ_ID for ' || d_table_name || '.');
    END IF;


    BEGIN
        INSERT INTO CHINOOK.TRACK (TRACKID,
                                   NAME,
                                   ALBUMID,
                                   MEDIATYPEID,
                                   GENREID,
                                   COMPOSER,
                                   MILLISECONDS,
                                   BYTES,
                                   UNITPRICE)
             VALUES (d_seq_id,
                     v_track_name,
                     v_album_id,
                     v_media_type,
                     v_genre_id,
                     v_composer,
                     v_milliseconds,
                     v_bytes,
                     v_unit_price);
    END;
END;
/
