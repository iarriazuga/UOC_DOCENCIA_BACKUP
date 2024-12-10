-- Crear la tabla con todas las columnas y una restricción UNIQUE
CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.LK_IDIOMA_2 (
 
    ID_IDIOMA INT PRIMARY KEY,
    COD_IDIOMA INT NOT NULL,
    DESC_IDIOMA VARCHAR(50) NOT NULL,
    DESC_IDIOMA_ACRONIM VARCHAR(10) NOT NULL,
    DESC_IDIOMA_ACRONIM_2_LETRAS VARCHAR(2) -- Declarada como columna regular
);

-- Insertar los datos iniciales
INSERT INTO DB_UOC_PROD.DDP_DOCENCIA.LK_IDIOMA_2 (ID_IDIOMA, COD_IDIOMA, DESC_IDIOMA, DESC_IDIOMA_ACRONIM, DESC_IDIOMA_ACRONIM_2_LETRAS)
VALUES

(0, 0, 'Sense Informar', 'SEN', 'se'),
(1, 1, 'Català', 'CAT', 'ca'),
(2, 2, 'Castellà', 'CAS', 'ca'),
(3, 3, 'Anglès', 'ANG', 'an'),
(4, 4, 'Francès', 'FRA', 'fr'),
(5, 5, 'Basc', 'BAS', 'ba'),
(6, 6, 'Gallec', 'GAL', 'ga'),
(7, 7, 'Alemany', 'ALE', 'de'),
(8, 8, 'Italià', 'ITA', 'it'),
(9, 9, 'Portuguès', 'POR', 'po'),
(10, 10, 'Holandés', 'HOL', 'ho'),
(11, 11, 'Noruec', 'NOR', 'no'),
(12, 12, 'Finlandès', 'FIN', 'fi'),
(13, 13, 'Suec', 'SUE', 'su'),
-- (14, 14, 'Altre/Altres', 'ALT', 'al'),
-- (15, 15, 'Català/Castellà', 'CAT/CAS', 'ca'),
-- (16, 16, 'Català/Anglès', 'CAT/ANG', 'ca'),
-- (17, 17, 'Català/Francès', 'CAT/FRA', 'ca'),
-- (18, 18, 'Català/Alemany', 'CAT/ALE', 'ca'),
-- (19, 19, 'Català/Italià', 'CAT/ITA', 'ca'),
(20, 20, 'Xinès', 'XIN', 'xi'),
(21, 21, 'Occità', 'OCC', 'oc'),
(22, 22, 'Portuguès', 'POR', 'pt'),
(23, 23, 'Alemany', 'ALE', 'de'),
(24, 24, 'Desconocido', 'NULL', NULL),
(26, 26, 'Gallec', 'GAL', 'gl'),
(27, 27, 'Italià', 'ITA', 'it'),
(28, 28, 'Castellà', 'CAS', 'es'),
(29, 29, 'Francès', 'FRA', 'fr'),
(30, 30, 'Basc', 'BAS', 'eu');
-- Verificar los datos finales
SELECT * FROM DB_UOC_PROD.DDP_DOCENCIA.LK_IDIOMA_2;

