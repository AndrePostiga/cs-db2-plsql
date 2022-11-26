set serveroutput on size 30000;

CREATE OR REPLACE PROCEDURE
    generate
IS
    create_string varchar2(9999);
    statement varchar2(9999);
    pk_col varchar2(4000);
    TYPE values_t IS TABLE OF VARCHAR2(4000);
begin
    FOR tableObject IN (SELECT DISTINCT TABLE_NAME
                  FROM ALL_TAB_COLS
                  WHERE OWNER = 'CHINOOK') LOOP

        create_string := 'CREATE TABLE ' || tableObject.TABLE_NAME || ' (';

        FOR colName IN (WITH pk AS (
                        SELECT
                            cols.TABLE_NAME,
                            cols.COLUMN_NAME,
                            cons.CONSTRAINT_TYPE
                        FROM ALL_CONSTRAINTS cons
                        LEFT JOIN ALL_CONS_COLUMNS cols ON cols.CONSTRAINT_NAME = cons.CONSTRAINT_NAME
                        WHERE cols.OWNER='CHINOOK' AND CONSTRAINT_TYPE='P' AND cols.TABLE_NAME=tableObject.TABLE_NAME)
                            SELECT
                                ALL_TAB_COLS.TABLE_NAME,
                                ALL_TAB_COLS.DATA_TYPE,
                                ALL_TAB_COLS.COLUMN_NAME,
                                pk.CONSTRAINT_TYPE,
                                ALL_TAB_COLS.DATA_LENGTH,
                                ALL_TAB_COLS.CHAR_COL_DECL_LENGTH,
                                ALL_TAB_COLS.CHAR_LENGTH,
                                ALL_TAB_COLS.NULLABLE,
                                ALL_TAB_COLS.COLUMN_ID
                            FROM ALL_TAB_COLS
                            LEFT JOIN pk ON pk.TABLE_NAME = ALL_TAB_COLS.TABLE_NAME AND pk.COLUMN_NAME = ALL_TAB_COLS.COLUMN_NAME
                            WHERE ALL_TAB_COLS.OWNER='CHINOOK' AND ALL_TAB_COLS.TABLE_NAME=tableObject.TABLE_NAME) LOOP

            if colName.DATA_TYPE = 'VARCHAR2' then
                statement := colName.COLUMN_NAME || ' ' || colName.DATA_TYPE || '(' || colName.CHAR_LENGTH || ')';
            else
                statement := colName.COLUMN_NAME || ' ' || colName.DATA_TYPE;
            end if;

            if colName.NULLABLE = 'N' then
                statement := statement || ' NOT NULL';
            end if;

            if colName.CONSTRAINT_TYPE is not null then
                pk_col := colName.COLUMN_NAME;
            end if;

            create_string := create_string || statement || ', ';
        end loop;
        if pk_col is not null then
            create_string := create_string || 'CONSTRAINT PK_' || pk_col || ' PRIMARY KEY (' || pk_col ||')';
        end if;
        create_string := create_string || ');';
        DBMS_OUTPUT.put_line(create_string);
    end loop;

    FOR tableObject IN (SELECT DISTINCT TABLE_NAME
                  FROM ALL_TAB_COLS
                  WHERE OWNER = 'CHINOOK') LOOP

        FOR fk_info IN (SELECT
                            ALL_CONSTRAINTS.CONSTRAINT_NAME as ForeignKey,
                            ALL_CONSTRAINTS.TABLE_NAME as TableName,
                            L_Collumns.COLUMN_NAME as Collumn,
                            ALL_CONSTRAINTS.R_CONSTRAINT_NAME as References_Constraint,
                            R_Collumns.COLUMN_NAME as References_Collumn,
                            R_Collumns.TABLE_NAME as References_Table
                        FROM
                            ALL_CONSTRAINTS
                        LEFT JOIN ALL_CONS_COLUMNS R_Collumns ON R_Collumns.CONSTRAINT_NAME = ALL_CONSTRAINTS.R_CONSTRAINT_NAME
                        LEFT JOIN ALL_CONS_COLUMNS L_Collumns ON L_Collumns.CONSTRAINT_NAME = ALL_CONSTRAINTS.CONSTRAINT_NAME
                        WHERE
                            ALL_CONSTRAINTS.OWNER = 'CHINOOK' AND
                            ALL_CONSTRAINTS.CONSTRAINT_TYPE = 'R' AND
                            ALL_CONSTRAINTS.TABLE_NAME = tableObject.TABLE_NAME) LOOP
            statement := 'ALTER TABLE ' || tableObject.TABLE_NAME || ' ADD CONSTRAINT FK_' || fk_info.TableName || fk_info.Collumn ||
                         ' FOREIGN KEY (' || fk_info.Collumn || ') REFERENCES ' || fk_info.References_Table || '(' || fk_info.References_Collumn || ');';
            DBMS_OUTPUT.put_line(statement);
        end loop;
    end loop;
end;