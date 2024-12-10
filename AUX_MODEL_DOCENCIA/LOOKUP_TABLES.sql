/*  DB_UOC_PROD.DD_OD TEST ACORAN

Generació del fitxer 29 aux_tables 

# PAS 1
Creation AND Insertion into DDP_UNEIX.LK_NIVELL_CATALA:
    This table stores the classification of academic levels in the Catalan language, including fields such AS the level code (COD_NIVELL), description (DS_NIVELL), AND associated level category (COD_NIVELL_CAT).
    The insertion populates the table with predefined level values, mapping different academic stages to their corresponding codes AND descriptions.

# PAS 2
Creation AND Insertion into DDP_UNEIX.LK_NIVELL_CATALA_ASSIGNATURA:
    This table associates specific academic levels (COD_NIVELL) with subject codes (COD_ASIGNATURA), allowing for a detailed classification of courses at various levels.
    The insertion of data links each level to corresponding subject codes, supporting the organization of academic curricula.
*/

/*-------------------------------- PAS 1 ---------------------------------------------------------------------------------------------------------------------*/

CREATE OR REPLACE TABLE DDP_UNEIX.LK_NIVELL_CATALA (
    ID_NIVELL INTEGER,
    COD_NIVELL STRING,
    DS_NIVELL STRING,
    COD_NIVELL_CAT STRING
);


INSERT INTO DDP_UNEIX.LK_NIVELL_CATALA (ID_NIVELL, COD_NIVELL, DS_NIVELL, COD_NIVELL_CAT)
VALUES 
    (  0, '00', 'No aplicable',              '00'),
    ( -1, '99', 'Sense informar',            '99'),
    (  1, 'A1', 'Nivell inicial',            '01'),
    (  2, 'A2', 'Nivell bàsic',              '02'),
    (  3, 'B1', 'Nivell elemental',          '01'),
    (  4, 'B2', 'Nivell intermedi',          '02'),
    (  5, 'C1', 'Nivell suficiència',        '03'),
    (  6, 'C2', 'Nivell superior',           '03'),
    (  7, 'E1', 'Certificat d\'assistència', '00'),
    (  8, 'E2', 'Sense finalitzar el curs',  '00'),
    (  9, 'CE', 'Cursos especialitzats',     '00');


SELECT * FROM  DDP_UNEIX.LK_NIVELL_CATALA;





/*-------------------------------- PAS 2 ---------------------------------------------------------------------------------------------------------------------*/



CREATE OR REPLACE TABLE DDP_UNEIX.LK_NIVELL_CATALA_ASSIGNATURA (
    ID_NC_A INTEGER,
    COD_NIVELL STRING,
    COD_ASIGNATURA STRING
);

INSERT INTO DDP_UNEIX.LK_NIVELL_CATALA_ASSIGNATURA (ID_NC_A, COD_NIVELL, COD_ASIGNATURA)
VALUES 
    (  0, '00', '00.000'),
    ( -1, '99', '99.999'),
    (  1, 'B2', '00.029'),
    (  2, 'A2', '00.132'),
    (  3, 'C1', '00.065'),
    (  4, 'C1', '00.028'),
    (  5, 'C2', '00.064'),
    (  6, 'C2', '00.098'),
    (  7, 'CE', '00.202'),
    (  8, 'C1', '00.062'),
    (  9, 'B1', '00.183');


SELECT * FROM   DDP_UNEIX.LK_NIVELL_CATALA_ASSIGNATURA;


/***

drop table  DDP_UNEIX.LK_NIVELL_CATALA_ASSIGNATURA;
drop table  DDP_UNEIX.LK_NIVELL_CATALA;

***/