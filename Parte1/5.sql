set serveroutput on size 30000;

CREATE OR REPLACE PROCEDURE
    checa_transicao (
        tabela_checar   IN VARCHAR2,
        coluna_checar   IN VARCHAR2,
        tabela_estados   IN VARCHAR2,
        coluna_estados   IN VARCHAR2,
        tabela_transicao IN VARCHAR2,
        coluna_estados_destino   IN VARCHAR2,
        coluna_estados_origem   IN VARCHAR2,
        estado_ojetivo IN VARCHAR2)
IS
   TYPE estados IS TABLE OF number;
   TYPE checada IS TABLE OF VARCHAR2;

    checar checada;
    estados_possiveis estados;
    estados_destino estados;
    estados_origem estados;
    destinos_possiveis estados;
BEGIN
    DBMS_OUTPUT.put_line('Entrou');
    EXECUTE IMMEDIATE
         'SELECT '
      || coluna_checar
      || ' FROM '
      || tabela_checar
      BULK COLLECT INTO checar;

    EXECUTE IMMEDIATE

         'SELECT DISTINCT'
      || coluna_estados
      || ' FROM '
      || tabela_estados
      BULK COLLECT INTO estados_possiveis;

    EXECUTE IMMEDIATE

         'SELECT'
      || coluna_estados_origem
      || ' FROM '
      || tabela_transicao
      BULK COLLECT INTO estados_origem;

    EXECUTE IMMEDIATE

         'SELECT'
      || coluna_estados_destino
      || ' FROM '
      || tabela_transicao
      BULK COLLECT INTO estados_destino;



   FOR indx IN 1 .. checar.COUNT
   LOOP
      IF NOT checar(indx) MEMBER OF (estados_possiveis) THEN
        RAISE_APPLICATION_ERROR(-1,'O estado do item no indice ' || indx || ' não existe na especificação do DTE');
      END IF;

        FOR indx2 IN 1 .. estados_origem.COUNT
            LOOP
                IF estados_origem(indx2) = checar(indx) THEN
                    EXECUTE IMMEDIATE
                        'INSERT INTO' || destinos_possiveis || 'VALUES' || (estados_destino(indx2));
                end if;
            end loop;
        IF NOT estado_ojetivo MEMBER OF (destinos_possiveis) THEN
            DBMS_OUTPUT.put_line('O estado objetivo não é possivel a partir do atual estado origem');
        end if;


   END LOOP;
END;




CREATE TABLE EstadosApp(
    ID number,
    EstadosPossiveis VARCHAR2(255),
    CONSTRAINT pk_id PRIMARY KEY (ID)
    );
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (1,'App iniciado');
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (2,'login');
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (3,'menu principal');
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (4,'perfil usuario');
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (5, 'noticias');
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (6, 'configurações');
INSERT INTO EstadosApp(ID, EstadosPossiveis) VALUES (7,'categorias');


CREATE TABLE TransicoesApp(
    ID number,
    EstadoOrigem NUMBER,
    EstadoDestino NUMBER,
    CONSTRAINT fk_origem FOREIGN KEY (EstadoOrigem) REFERENCES EstadosApp(ID),
    CONSTRAINT fk_destino FOREIGN KEY (EstadoDestino) REFERENCES EstadosApp(ID),
    CONSTRAINT pk_ID_transicoes PRIMARY KEY (ID)
);

INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (1,1,2);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (2,2,3);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (3,3,4);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (4,3,5);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (5,3,6);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (6,3,7);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (7,4,3);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (8,5,3);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (9,6,3);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (10,7,3);
INSERT INTO TransicoesApp(ID, EstadoOrigem, EstadoDestino) VALUES (11,6,2);


select c1.EstadosPossiveis Origem, c2.EstadosPossiveis Destino
    from TransicoesApp t
        JOIN EstadosApp c1 on t.EstadoOrigem = c1.ID
        JOIN EstadosApp c2 on t.EstadoDestino = c2.ID;

CREATE TABLE Teste(
    ID number,
    colunaTeste number,
    CONSTRAINT fk_teste FOREIGN KEY (colunaTeste) REFERENCES EstadosApp(ID)
);
INSERT INTO Teste VALUES(1,1);
INSERT INTO Teste VALUES(4,6);
INSERT INTO Teste VALUES(3,4);
INSERT INTO Teste VALUES(2,3);


CALL checa_transicao('Teste', 'colunaTeste', 'EstadosApp', 'EstadosPossiveis', 'TransicoesApp', 'EstadoDestino', 'EstadoOrigem', '6');

ALTER PROCEDURE checa_transicao COMPILE;