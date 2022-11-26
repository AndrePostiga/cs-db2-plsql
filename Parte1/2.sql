set serveroutput on size 30000;

CREATE OR REPLACE PROCEDURE
    delete_indexes_of_table (table_in IN VARCHAR2)
IS
   TYPE values_t IS TABLE OF VARCHAR2(4000);
   l_values   values_t;
BEGIN
    SELECT DISTINCT ALL_INDEXES.INDEX_NAME BULK COLLECT INTO l_values
    FROM
        ALL_INDEXES
    LEFT JOIN ALL_IND_COLUMNS ON ALL_IND_COLUMNS.INDEX_NAME = ALL_INDEXES.INDEX_NAME
    WHERE
        ALL_INDEXES.OWNER = 'CHINOOK' AND
        ALL_INDEXES.TABLE_NAME = 'PLAYLISTTRACK';

   FOR indx IN 1 .. l_values.COUNT
   LOOP
      execute immediate 'DROP INDEX '||ind.index_name;
   END LOOP;
END;

--v2

CREATE OR REPLACE PROCEDURE
    delete_indexes_of_table (table_in IN VARCHAR2)
IS
   TYPE values_t IS TABLE OF VARCHAR2(4000);
    l_values values_t;
    c_values values_t;
BEGIN

    SELECT DISTINCT
        ALL_INDEXES.INDEX_NAME,  ALL_CONSTRAINTS.CONSTRAINT_NAME BULK COLLECT INTO l_values, c_values
    FROM
        ALL_INDEXES
    LEFT JOIN ALL_IND_COLUMNS ON ALL_IND_COLUMNS.INDEX_NAME = ALL_INDEXES.INDEX_NAME
    LEFT JOIN ALL_CONSTRAINTS ON ALL_CONSTRAINTS.INDEX_NAME = ALL_INDEXES.INDEX_NAME
    WHERE
        ALL_INDEXES.OWNER = 'CHINOOK' AND
        ALL_INDEXES.TABLE_NAME = table_in;

   FOR indx IN 1 .. l_values.COUNT
   LOOP
       IF (c_values(indx) is not null) then
           execute immediate 'ALTER TABLE ' || table_in || ' DROP CONSTRAINT ' || c_values(indx);
       end if;

      execute immediate 'DROP INDEX '|| l_values(indx);
   END LOOP;
END;
