-- -- #################################################################################################
-- -- #################################################################################################
-- -- RECURSOS_APRENDIZATJE
-- -- #################################################################################################
-- -- #################################################################################################
 
-- CREATE TABLE DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS AS
With productos_aux AS ( --que hace unico a un recurso 
        SELECT                              -- agafa els mateixos camps per conservar la estructura però dades de COCO (taules Autors)
            autors_producte.id AS CODI_RECURS,                      --   autors_producte.ID,                 -- COCO: id del producte
            autors_producte.titol AS titol_recurs,                  --   autors_producte.TITOL,                 -- COCO: Títol del producte
            'PROPI' AS origen_recurs,
            'COCO_PROD' AS origen_base_dades,
            autors_producte.versio_creacio_id,                      -- COCO: Id del pla de publicació en que es va crear                  
            -- revisar 
            'AUTORS_MODUL.PRODUCTE_CREACIO_ID' AS CODI_RECURS2,                   --  (Campo a recuperar de PRODUCTO) Producto padre - fk de producte
            autors_producte.producte_origen_id,                     -- COCO: Id del producte origen


            autors_producte.url AS url_idioma_recurs,               -- COCO: enllac_url del Producte
            autors_producte.url AS url,                             -- COCO: enllac_url del Producte
            
            autors_suport_producte_i18n.descripcio AS descripcio_suport_recurs,
            autors_tipus_tramesa_i18n.descripcio AS descripcio_tramesa_recurs,
            autors_tipus_tramesa_i18n.descripcio AS DESCRIPCIO,
            initcap(autors_idioma_producte_i18n.descripcio) AS descripcio_idioma_recurs,

            
            autors_producte.producte_origen_id,                     -- COCO: Id del producte origen
            autors_producte.codi_migracio,                          -- COCO: Codi de migració
            autors_producte.ind_material_propi,                     -- COCO: Per altes de materials no propis
            autors_producte.baixa,                                  -- COCO: Indicador de Baixa
            autors_producte.paraula_clau,                           -- COCO: Paraula Clau
            autors_producte.codi_recurs_origen,                     -- COCO: Codi recurs Origen 
            autors_producte.num_contracte,                          -- COCO: Codi contracte autoria
            autors_producte.data_tancament_real                     -- COCO: Data de producció del material
            
        FROM db_uoc_prod.stg_dadesra.autors_producte
            
        inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n
            on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id
            AND autors_suport_producte_i18n.idioma = 'CAT'
        
        inner join db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n
            on autors_producte.fk_tipus_tramesa_tipus_tra__id = autors_tipus_tramesa_i18n.fk_tipus_tramesa_tipus_tra__id
            AND autors_tipus_tramesa_i18n.idioma = 'CAT'
            
        inner join db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n
            on autors_producte.fk_idioma_producte_idioma_id = autors_idioma_producte_i18n.fk_idioma_producte_idioma___id
            AND autors_idioma_producte_i18n.idioma = 'CAT'
        
        where ifnull(autors_producte.fk_suport_producte_suport_id,0) != 0
 
            
), 


-- ####################################################################################################
-- MODUL         
-- CREATE TABLE RECURSOS_COCO_MODULS
-- ####################################################################################################

modulos_aux AS (
    SELECT 
    
        AUTORS_MODUL.ID AS CODI_RECURS,                     -- Id del Mòdulo (Camp ja definit)
        AUTORS_MODUL.DESCRIPCIO AS titol_recurs,            -- (Camp ja definit) (Corresponde al campo Título en la tabla Producte)  --> PROBLEMA EN MODULOS, COMO LO SACO / RELACIONO
        'PROPI' AS origen_recurs,                           -- Tipus de recurs  (Camp ja definit)
        'COCO_MOD'  AS origen_base_dades,                       -- url_idioma_recurs* : NO VALID (Campo a recuperar de PRODUCTO)                                                   --> SOLO EN PROD, NO EN MODULOS
        AUTORS_MODUL.versio_creacio_id,                      -- COCO: Id del pla de publicació en que es va crear
        -- revisar 
        AUTORS_MODUL.PRODUCTE_CREACIO_ID AS CODI_RECURS2,                   --  (Campo a recuperar de PRODUCTO) Producto padre - fk de producte
        autors_producte.producte_origen_id,                     -- COCO: Id del producte origen
        
        autors_producte.url AS url_idioma_recurs,           -- url_idioma_recurs* : NO VALID (Campo a recuperar de PRODUCTO)                                                   --> SOLO EN PROD, NO EN MODULOS
        autors_producte.url AS url,                             -- COCO: enllac_url del Producte
        autors_producte.descripcio AS descripcio_tramesa_recurs,  --(Campo a recuperar de PRODUCTO)
        autors_producte.descripcio AS descripcio_suport_recurs,                 -- (Campo a recuperar de PRODUCTO)
        initcap(autors_producte.descripcio) AS descripcio_idioma_recurs,
        autors_producte.descripcio_tramesa_recurs AS descripcio_tramesa_recurs,
        autors_producte.DESCRIPCIO AS DESCRIPCIO,
        autors_producte.codi_migracio,                          -- COCO: Codi de migració
        autors_producte.ind_material_propi,                     -- COCO: Per altes de materials no propis
        autors_producte.baixa,                                  -- COCO: Indicador de Baixa
        autors_producte.baixa,                              -- (Campo a recuperar de PRODUCTO) COCO: Indicador de Baixa
        autors_producte.paraula_clau,                           -- COCO: Paraula Clau
        autors_producte.codi_recurs_origen,                     -- COCO: Codi recurs Origen 
        autors_producte.num_contracte,                      -- (Campo a recuperar de PRODUCTO) COCO: Codi contracte autoria
        autors_producte.data_tancament_real,                 -- (Campo a recuperar de PRODUCTO) COCO: Data de producció del material



        AUTORS_MODUL.OBSERVACIONS,                          --  Observacions del mòdul (Campo específico de módulo)
        AUTORS_MODUL.MODUL_ORIGEN_ID,                       -- Id del mòdul que original (Campo específico de módulo)
        AUTORS_MODUL.OBRA_ID,                               -- Id de la obra (Campo específico de módulo)
        AUTORS_MODUL.CODI_MIGRACIO                          -- (Corresponde al Codigo migración de producto)


/*
    -- revisar francesc
    'na'  AS producte_origen_id,
    'na'  AS CODI_RECURS_origen, 
    'na'  AS num_contracte 
    
    etl
    pre - stg: cargar    
    post - tranFROM --> idilicamente de un incremental  ( insert no uptdate )
    dim / fact  - transformacion --> estandarizacion  

    1 ; 
*/
    AUTORS_MODUL.id AS id,                          -- coco: mòdul id = producte
    AUTORS_MODUL.observacions,                      -- coco: mòdul observacions = producte
    AUTORS_MODUL.modul_origen_id,                   -- coco: mòdul origen
    AUTORS_MODUL.versio_creacio_id,                 -- coco: mòdul id del pla de publicació en que es va crear = producte
    AUTORS_MODUL.producte_creacio_id,               -- coco: mòdul id producte creació
    AUTORS_MODUL.obra_id,                           -- coco: mòdul obra id
    AUTORS_MODUL.descripcio,                        --coco: mòdul descripció
    AUTORS_MODUL.codi_migracio,                     -- coco: mòdul codi de migració = producte

 
FROM productos_aux autors_producte
inner join db_uoc_prod.stg_dadesra.AUTORS_MODUL AUTORS_MODUL  on autors_producte.codi_recurs = AUTORS_MODUL.PRODUCTE_CREACIO_ID 

    
) 

SELECT * FROM modulos_aux
UNION ALL
SELECT * FROM productos_aux
 
 


;

-- drop table DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS;

SELECT  titol, count(*) 
FROM db_uoc_prod.stg_dadesra.autors_producte
        inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n
            on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id
            AND autors_suport_producte_i18n.idioma = 'CAT'
        
        inner join db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n
            on autors_producte.fk_tipus_tramesa_tipus_tra__id = autors_tipus_tramesa_i18n.fk_tipus_tramesa_tipus_tra__id
            AND autors_tipus_tramesa_i18n.idioma = 'CAT'
            
        inner join db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n
            on autors_producte.fk_idioma_producte_idioma_id = autors_idioma_producte_i18n.fk_idioma_producte_idioma___id
            AND autors_idioma_producte_i18n.idioma = 'CAT'
        
        where ifnull(autors_producte.fk_suport_producte_suport_id,0) != 0

-- where titol like 'Orientaciones'
group by 1 
order by 2 desc 

limit 100;


SELECT * -- titol, count(*) 
FROM db_uoc_prod.stg_dadesra.autors_producte
where titol like 'Orientaciones'



--- 
SELECT count(*) AS numero , '1' AS src FROM db_uoc_prod.stg_dadesra.autors_producte union all  -- autors_suport_producte_i18n
SELECT count(*) AS numero , '2' AS src FROM db_uoc_prod.stg_dadesra.autors_suport_producte_i18n  union all        
SELECT count(*) AS numero , '3' AS src FROM db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n union all 
SELECT count(*) AS numero , '4' AS src FROM db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n  

/*

NUMERO	SRC
55610	 1
93	     2
4	     3
13	     4

*/


SELECT    count(*) 
FROM db_uoc_prod.stg_dadesra.autors_producte

inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 
on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id -- vs 197397 
            AND autors_suport_producte_i18n.idioma = 'CAT'  -- 51568 




SELECT   * -- distinct idioma, descripcio  
FROM  db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 


SELECT    * 
FROM db_uoc_prod.stg_dadesra.autors_producte

inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 
on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id -- vs 197397 
            AND autors_suport_producte_i18n.idioma = 'CAT'  -- 51568 


            
SELECT    * --- distinct FK_IDIOMA_PRODUCTE_IDIOMA_ID
FROM db_uoc_prod.stg_dadesra.autors_producte
/*

FK_IDIOMA_PRODUCTE_IDIOMA_ID
2
3
1
4
Null 
62
61
*/
 









SELECT  db_uoc_prod.stg_dadesra.autors_producte.id , count(*)
FROM db_uoc_prod.stg_dadesra.autors_producte

inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 
on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id -- vs 197397 
            AND autors_suport_producte_i18n.idioma = 'CAT'  -- 51568 

group by 1  having count(*) > 1


-- no duplicadoss







SELECT  db_uoc_prod.stg_dadesra.autors_producte.id , count(*)
FROM db_uoc_prod.stg_dadesra.autors_producte

inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 
on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id -- vs 197397 tipo de productos  
            AND autors_suport_producte_i18n.idioma = 'CAT'  -- 51568 

        
        inner join db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n
            on autors_producte.fk_tipus_tramesa_tipus_tra__id = autors_tipus_tramesa_i18n.fk_tipus_tramesa_tipus_tra__id
            AND autors_tipus_tramesa_i18n.idioma = 'CAT' -- no duplicates 
            
        inner join db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n
            on autors_producte.fk_idioma_producte_idioma_id = autors_idioma_producte_i18n.fk_idioma_producte_idioma___id
            AND autors_idioma_producte_i18n.idioma = 'CAT'

            
group by 1  having count(*) > 1

---########################################################################################################################################################################
/*** RECURSOS ***/ -- Count diferent values in inner joins: 55k > 51k > 35k > 35k
---########################################################################################################################################################################
SELECT  *
FROM db_uoc_prod.stg_dadesra.autors_producte -- 55,610 

inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 
on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id -- vs 197397 tipo de productos  
            AND autors_suport_producte_i18n.idioma = 'CAT'  -- 51568 

        -- valores no informados: Francesc confirma valores antiguos que pueden no estar informados base de datos 
        left join db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n
            on autors_producte.fk_tipus_tramesa_tipus_tra__id = autors_tipus_tramesa_i18n.fk_tipus_tramesa_tipus_tra__id
            AND autors_tipus_tramesa_i18n.idioma = 'CAT' -- no duplicates  35,257 --> convertir a left 
            
        left join db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n
            on autors_producte.fk_idioma_producte_idioma_id = autors_idioma_producte_i18n.fk_idioma_producte_idioma___id
            AND autors_idioma_producte_i18n.idioma = 'CAT'  -- 35,238 --> convertir a left : 51,568 vs 51,546


---########################################################################################################################################################################

SELECT * FROM  db_uoc_prod.stg_dadesra.autors_suport_producte_i18n 

/*
Cd-Rom programaire
Cd-Rom software
Cd-Rom software
Cd-Rom programari
Informatique
Computer
Informático
Informàtic
Word
Word

*/

SELECT * FROM db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n
/*
Publicació a l'aula
Publicación en el aula
Tramesa postal
Tramesa postal

*/


SELECT * FROM db_uoc_prod.stg_dadesra.autors_idioma_producte_i18n
/*
alemán
alemany
chino
xinès
japonès
català

*/



with aux_cte_table AS (

SELECT AUTORS_MODUL.ID AS ID_test FROM db_uoc_prod.stg_dadesra.AUTORS_MODUL AUTORS_MODUL  inner join db_uoc_prod.stg_dadesra.autors_producte on autors_producte.id = AUTORS_MODUL.PRODUCTE_CREACIO_ID 
union all 
SELECT autors_producte.id AS ID_test FROM   db_uoc_prod.stg_dadesra.autors_producte   


)
SELECT ID_test, count(*) FROM aux_cte_table 
group by 1
having count (*) > 1



SELECT * FROM db_uoc_prod.stg_dadesra.AUTORS_MODUL 
where  db_uoc_prod.stg_dadesra.AUTORS_MODUL.ID like '122668'

SELECT * FROM  db_uoc_prod.stg_dadesra.autors_producte  
where db_uoc_prod.stg_dadesra.autors_producte .ID like '122668'

SELECT * FROM db_uoc_prod.stg_dadesra.AUTORS_MODUL 
where  db_uoc_prod.stg_dadesra.AUTORS_MODUL.PRODUCTE_CREACIO_ID like '122635'

SELECT * FROM  db_uoc_prod.stg_dadesra.autors_producte  
where db_uoc_prod.stg_dadesra.autors_producte.ID like '122635'

SELECT count(*) 
FROM db_uoc_prod.stg_dadesra.AUTORS_MODUL 
inner join db_uoc_prod.stg_dadesra.autors_producte on autors_producte.id = AUTORS_MODUL.ID 





with aux_cte_table AS (

SELECT AUTORS_MODUL.ID AS ID_test FROM db_uoc_prod.stg_dadesra.AUTORS_MODUL AUTORS_MODUL  inner join db_uoc_prod.stg_dadesra.autors_producte on autors_producte.id = AUTORS_MODUL.PRODUCTE_CREACIO_ID 
union all 
SELECT autors_producte.id AS ID_test FROM   db_uoc_prod.stg_dadesra.autors_producte   


)
SELECT ID_test, count(*) FROM aux_cte_table 
group by 1
having count (*) > 1


 