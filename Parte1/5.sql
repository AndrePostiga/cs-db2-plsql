set serveroutput on size 30000;

CREATE OR REPLACE PROCEDURE
    checa_transicao (
        tabela_checar   IN VARCHAR2,
        coluna_checar   IN VARCHAR2,
        tabela_estados   IN VARCHAR2,
        coluna_estados_destino   IN VARCHAR2,
        coluna_estados_origem   IN VARCHAR2,
        estado_objetivo   IN VARCHAR2)
IS
   TYPE estados IS TABLE OF VARCHAR2;
   TYPE checada IS TABLE OF VARCHAR2;

   coluna_objetivo checada;
   estados_possiveis estados;
   estados_destino estados;
BEGIN

    EXECUTE IMMEDIATE
         'SELECT '
      || coluna_checar
      || ' FROM '
      || tabela_checar
      BULK COLLECT INTO coluna_objetivo;

    EXECUTE IMMEDIATE

         'SELECT'
      || coluna_estados_origem
      || ' FROM '
      || tabela_estados
      BULK COLLECT INTO estados_possiveis;

    EXECUTE IMMEDIATE

         'SELECT DISTINCT'
      || coluna_estados_destino
      || ' FROM '
      || tabela_estados
      BULK COLLECT INTO estados_destino;



   FOR indx IN 1 .. coluna_objetivo.COUNT
   LOOP
      IF NOT coluna_objetivo(indx) IN estados_possiveis THEN
        RAISE_APPLICATION_ERROR(-1,'O estado do item no indice ' || indx || ' não existe na especificação do DTE');
      END IF;

        FOR indx2 IN 1 .. estados_possiveis.COUNT
        LOOP
            IF (coluna_objetivo(indx) = coluna_estados_origem(indx2)) THEN
                IF (estado_objetivo IN estados_destino(indx2)) THEN
                    EXIT;
                END IF;
            END IF;
        END LOOP;
      RAISE_APPLICATION_ERROR(-1,'O estado objetivo não é possivel a partir do atual estado origem');
   END LOOP;
END;

