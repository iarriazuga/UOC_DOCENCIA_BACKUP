---########################################################################################################################################################################
-- validaciones
---########################################################################################################################################################################

/***
-- SELECT * FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS where CODI_RECURS = '145195' -- idioma  catalan , recurso = web 
-- SELECT * FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS where CODI_RECURS = '145193' 

-- modulo : 145195 
-- producto 145193 

SELECT origen_base_dades, count(*) 
FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE
group by 1

origen_base_dades	COUNT(*)
COCO_MOD	        60775
DIMAX	            100821
COCO_PROD	        51561


*/

SELECT  origen_base_dades, FORMAT_RECURS,  count(*)  -- 4068: valores no null 
FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE

where format_recurs is null     

group by 1,2


// *** 
SELECT autors_modul.* 
FROM db_uoc_prod.stg_dadesra.autors_modul autors_modul   --- 3,984 --no tienen padre 
where producte_creacio_id is null  




//*** CODIGOS QUE NO TIENEN PADRE  */
with aux_cte_table AS ( 

        SELECT id AS CODI_RECURS
        FROM db_uoc_prod.stg_dadesra.autors_modul autors_modul  
        where producte_creacio_id is null  

)

SELECT PRODUCTE_CREACIO_ID AS padre, * -- origen_base_dades, FORMAT_RECURS,  count(*)  -- 4068: valores no null 
FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE  -- 84 

where 1=1 
    AND format_recurs is null  
    AND  CODI_RECURS not in ( SELECT CODI_RECURS FROM aux_cte_table )
    AND ORIGEN_RECURS = 'PROPI'


/***
PADRE	ID_CODI_RECURS	CODI_RECURS	TITOL_RECURS	ORIGEN_RECURS	TIPUS_RECURS	origen_base_dades	LLICENCIA_LPC	LLICENCIA_LGC	LLICENCIA_ALTRES	LLICENCIA_BIBLIOTECA	WAIT_RECURS	IDIOMA_RECURS	FORMAT_RECURS	DATA_INICI_RECURS	DATA_CADUCITAT_RECURS	CERCABLE_RECURS	INDICADOR_PUBLIC_RECURS	PUBLICAT_A_RECURS	ISBN_ISSN_RECURS	PAGINA_INICI_RECURS	PAGINA_FINAL_RECURS	BASE_DADES_RECURS	ELLIBRE_RECURS	URL_CAT_RECURS	URL_CAS_RECURS	URL_ANG_RECURS	TIPUS_GESTIO_RECURS	DESPESA_VARIABLE_RECURS	UPDATE_DATE	CREATION_DATE	PRODUCTE_CREACIO_ID	DESCRIPCIO_TRAMESA_RECURS	DESCRIPCIO_IDIOMA_RECURS	NUM_CONTRACTE	OBSERVACIONS	MODUL_ORIGEN_ID	VERSIO_CREACIO_ID	OBRA_ID	CODI_MIGRACIO	URL_IDIOMA_RECURS
243713	COCO-243721	        243721	Módulo 5	PROPI		COCO_MOD					null	null	null	null	null					0	0						ND		null	null	243713	null	null	null	null	233129	86326	null	null	null
243713	COCO-243722	        243722	Módulo 3	PROPI		COCO_MOD					null	null	null	null	null					0	0						ND		null	null	243713	null	null	null	null	233127	86326	null	null	null
246598	COCO-246600	        246600	Mòdul 2	    PROPI		COCO_MOD					null	null	null	null	null					0	0						ND		null	null	246598	null	null	null	null	null	87814	null	null	null
194597	COCO-194598	        194598	Módulo 1	PROPI		COCO_MOD					null	null	null	null	null					0	0						ND		null	null	194597	null	null	null	null	null	59881	null	null	null
244798	COCO-244801	        244801	Mòdul 3	    PROPI		COCO_MOD					null	null	null	null	null					0	0						ND		null	null	244798	null	null	null	null	null	86944	null	null	null

*/
-- modulos con padres que no existen en productos
-- modulos que no tienen asigando un padre 

SELECT * 
FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE 
where  CODI_RECURS in (
'243713',
'243713',
'246598',
'194597',
'244798'

)

SELECT *  
FROM db_uoc_prod.stg_dadesra.autors_modul autors_modul  
    left join productos_aux autors_producte on autors_producte.codi_recurs = autors_modul.PRODUCTE_CREACIO_ID 

