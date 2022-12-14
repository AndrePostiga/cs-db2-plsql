-- Tentativa usando Trigger
CREATE OR REPLACE TRIGGER update_invoice_total
BEFORE INSERT OR UPDATE OR DELETE ON CHINOOK.INVOICELINE
FOR EACH ROW
BEGIN

    -- Inserção -> Adicione novo valor
    IF INSERTING THEN
        UPDATE CHINOOK.INVOICE
        SET TOTAL = TOTAL + (:NEW.UNITPRICE * :NEW.QUANTITY)
        WHERE INVOICEID = :NEW.INVOICEID;
    END IF;

    -- Atualização -> Remova valor anterior e adicione novo valor
    IF UPDATING THEN
        UPDATE CHINOOK.INVOICE
        SET TOTAL = TOTAL - (:OLD.UNITPRICE * :OLD.QUANTITY) + (:NEW.UNITPRICE * :NEW.QUANTITY)
        WHERE INVOICEID = :NEW.INVOICEID;
    END IF;

    -- Deleção -> Remova valor anterior
    IF DELETING THEN
        UPDATE CHINOOK.INVOICE
        SET TOTAL = TOTAL - (:OLD.UNITPRICE * :OLD.QUANTITY)
        WHERE INVOICEID = :OLD.INVOICEID;
    END IF;

END;

-- Testes
INSERT INTO CHINOOK.INVOICELINE
    (INVOICELINEID, INVOICEID, TRACKID, UNITPRICE, QUANTITY)
VALUES (3000, 324, 329, 0.99, 1);

UPDATE CHINOOK.INVOICELINE
SET QUANTITY = 2
WHERE INVOICELINEID = 3000;

UPDATE CHINOOK.INVOICELINE
SET UNITPRICE = 1.98
WHERE INVOICELINEID = 3000;

DELETE FROM CHINOOK.INVOICELINE
WHERE INVOICELINEID = 3000;