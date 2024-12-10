

/*
--#################################################################################################
--COMENTARIOS: 
--#################################################################################################

Duplicados elementos nos quedamos con los del modulo : estos duplicados se deben a que los modulos hann sido promocionados a productos, codigo antiguos 
algunos modulos no tienen producto origen --> tenemso que quedarnos con el modulo aunque el prodcuo este vacio 

-- union all : 112,343 vs 112,336 after duplicates deletion
-- productos : 51,568 
-- modulos   : 60,775
 
--  SELECT * FROM DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS
--  drop table DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS

*/


 
// DELETE DUPLICATES: 
-- Step 1: Create a temporary table with duplicate rows to delete
CREATE OR REPLACE TEMP TABLE DB_UOC_PROD.DDP_DOCENCIA.T_COCO_PROD_TEMP_DUPLICATES_TEMP AS
SELECT 
    CODI_RECURS,
    origen_base_dades
FROM 
    (SELECT 
        CODI_RECURS, 
        origen_base_dades,
        ROW_NUMBER() OVER(PARTITION BY CODI_RECURS ORDER BY CODI_RECURS) AS row_num
     FROM 
        DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS
    ) AS subquery
WHERE 
    row_num > 1 AND origen_base_dades = 'COCO_PROD';

-- Step 2: Delete the duplicates using the temporary table
DELETE FROM DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS
WHERE (codi_recurs, origen_base_dades) IN (
    SELECT CODI_RECURS, origen_base_dades
    FROM DB_UOC_PROD.DDP_DOCENCIA.T_COCO_PROD_TEMP_DUPLICATES_TEMP
);

-- Step 3: Drop the temporary table after use
DROP TABLE DB_UOC_PROD.DDP_DOCENCIA.T_COCO_PROD_TEMP_DUPLICATES_TEMP;

 










/***


origen_base_dades	DESCRIPCIO_IDIOMA_RECURS
COCO_MOD	    Francès
COCO_MOD	    null
COCO_MOD	    Anglès
COCO_MOD	    Castellà
COCO_MOD	    Català
COCO_PROD	    Xinès
COCO_PROD	    Anglès
COCO_PROD	    null
COCO_PROD	    Francès
COCO_PROD	    Castellà
COCO_PROD	    Català
COCO_PROD	    Alemany
DIMAX	        en
DIMAX	        pt
DIMAX	        de
DIMAX	        null
DIMAX	        ca
DIMAX	        gl
DIMAX	        it
DIMAX	        es
DIMAX	        fr
DIMAX	        eu


*/



describe table  DB_UOC_PROD.DDP_DOCENCIA.STAGE_RECURSOS_APRENENTATGE_COCO_PRODUCT_MODULS



