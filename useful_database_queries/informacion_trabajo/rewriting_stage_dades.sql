-- -- #################################################################################################
-- -- #################################################################################################
-- -- STAGE_DADES_ACADEMIQUES_DIMAX
-- -- #################################################################################################
-- -- #################################################################################################

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX AS  -- DDP_DOCENCIA

with dimax_resofite_path_unified AS (  
    select  distinct
        db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs,  
        db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami,
        -- db_uoc_prod.stg_dadesra.dimax_resofite_path.id_resource,
        -- db_uoc_prod.stg_dadesra.dimax_resofite_path.ordre,
    from db_uoc_prod.stg_dadesra.dimax_resofite_path  -- 18,056,913 vs 12,349,852

)
, node_structure_aplanation AS ( 
    SELECT  
        db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node,

        -- dimax_resofite_path_unified.node_cami as id_resource,  -- id_ que equivale a la tabla de dim_catalog 
        dimax_resofite_path_unified.node_cami,
        dimax_resofite_path_unified.node_recurs, -- same as  db_uoc_prod.stg_dadesra.dimax_item_dimax.id 

        ARRAY_SIZE(SPLIT(db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node, ';'))  as length_resources, 
        
        db_uoc_prod.stg_dadesra.dimax_item_dimax.titol,
        -- db_uoc_prod.stg_dadesra.dimax_v_recurs.titol AS titol_resource,
        SUBSTR(db_uoc_prod.stg_dadesra.dimax_item_dimax.titol, 0, 6) AS DIM_ASSIGNATURA_KEY
 
    FROM dimax_resofite_path_unified   --- registros : 17,303,400
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
        on dimax_resofite_path_unified.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400
    
    left join db_uoc_prod.stg_dadesra.dimax_v_recurs 
        on dimax_resofite_path_unified.node_cami = db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs -- 17303400 
    
    left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra 
        on db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs = db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.id_recurs -- 17303400

    where  ( 
        ARRAY_SIZE(SPLIT(db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node, ';')) = 5 
        or  
        db_uoc_prod.stg_dadesra.dimax_item_dimax.titol like '%Root Node:PV%'  --- evitar semestres   "Root Node:BIBLIO" --> falla la distancia 
    )
) 

, node_structure_asignaturas AS ( 
 
    SELECT   -- 3,731,701 vs  3,731,701
 
        CAMI_NODE
        , NODE_CAMI  -- recurso:  
        , NODE_RECURS  -- 
        , DIM_ASSIGNATURA_KEY  
        , ARRAY_SIZE(SPLIT(CAMI_NODE, ';'))  as length_resources
        , titol
        , SPLIT_PART(CAMI_NODE, ';', ARRAY_SIZE(SPLIT(CAMI_NODE, ';'))-1) AS NODE_RECURS_SEMESTRE
        -- , SPLIT_PART(CAMI_NODE, ';', ARRAY_SIZE(SPLIT(CAMI_NODE, ';'))-2) AS NODE_RECURS_intermedio
        -- , SPLIT_PART(CAMI_NODE, ';', ARRAY_SIZE(SPLIT(CAMI_NODE, ';'))-3) AS NODE_RECURS_ASSIGNATURA
 
    FROM node_structure_aplanation  -- 3,731,701 vs 310,915 ( with distinct )
    
    where length_resources = 5

) 




,  node_structure_semestres  AS ( 
    SELECT distinct -- 148,966

        NODE_RECURS as NODE_RECURS_SEMESTRE  
        , REPLACE(titol, 'Root Node:PV', '') as DIM_SEMESTRE_KEY 

    FROM node_structure_aplanation   
    where titol like '%Root Node:PV%'  --- evitar semestres   "Root Node:BIBLIO" --> falla la distancia 

)   


SELECT   

    'DIMAX'|| '-'||  node_structure_asignaturas.node_cami as DIM_RECURSOS_APRENENTATGE_KEY
    , node_structure_semestres.DIM_SEMESTRE_KEY
    , node_structure_asignaturas.DIM_ASSIGNATURA_KEY

    , node_structure_asignaturas.NODE_RECURS_SEMESTRE
    , node_structure_asignaturas.NODE_RECURS
    , node_structure_asignaturas.cami_node -- uso para path 
    , node_structure_asignaturas.node_cami --- as recurso de aprendizaje 
    -- , node_structure_asignaturas.titol_resource   




    FROM  node_structure_asignaturas    
    inner join node_structure_semestres on  node_structure_asignaturas.NODE_RECURS_SEMESTRE = node_structure_semestres.NODE_RECURS_SEMESTRE  
    

    -- where DIM_ASSIGNATURA_KEY like '20.819' 
    -- AND node_structure_asignaturas.cami_node like '%;3427092;3417142;3281320;' 
    -- 6_462_729 va  6_342_169 --> se pierden  120,560 
    -- 1,6k La aplicación tinene 20 años y antes se usaba para otras cosas, está obsoleto lo que está bajo BIBLIO
    -- Francesc nodo BIBLIO es algo histórico y de cuando Diamx se usaba para otra función.... Ignoramos el nodo Biblio.


/*

NODE_RECURS_SEMESTRE	COUNT(*)	TITOL  --> cambian los nums 75,569 
30058	                43	        Root Node:PROVES
438561	                15631	    Root Node:FPNOV10
817691	                17331	    Root Node:FPNOV11
384004	                15049	    Root Node:FPMAR10
247308	                13378	    Root Node:FPMAR09
30043	                28285	    Root Node:BIBLIO
768692	                15557	    Root Node:FPMAR11
296535	                15286	    Root Node:FPNOV09

*/

select *
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX --   inner() 3,656,132 = 3,656,132
--  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX


select distinct node_cami
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX --  3,731,701 vs inner() 3,656,132
-- 70,239


select distinct id_recurs -- 101,985 vs 70,239 tabla final 
from db_uoc_prod.stg_dadesra.dimax_v_recurs 

select distinct NODE_RECURS  -- 306,145
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX --  3,731,701 vs inner() 3,656,132



select distinct id
from db_uoc_prod.stg_dadesra.dimax_item_dimax  -- 1,755,718   > 300k incluidos en db_uoc_prod.stg_dadesra.dimax_resofite_path



--# VALORACION ASIGNATURAS
select DISTINCT  DIM_ASSIGNATURA_KEY  -- 14,294
from node_structure_asignaturas


select distinct dim_assignatura_key  --14,294 VS 14,142  
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX --  3,731,701 vs inner() 3,656,132


select  *  -- 3,656,132 VS  3,655,656 -> 
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX RA

LEFT JOIN DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE AP 
ON RA.DIM_RECURSOS_APRENENTATGE_KEY = AP.DIM_RECURSOS_APRENENTATGE_KEY


SELECT DIM_RECURSOS_APRENENTATGE_KEY AS TEST2, * 
FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE






select  DISTINCT NODE_CAMI -- *  -- 3,656,132 VS  3,655,656 -> 476
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX RA

LEFT JOIN DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE AP 
ON RA.DIM_RECURSOS_APRENENTATGE_KEY = AP.DIM_RECURSOS_APRENENTATGE_KEY

WHERE  AP.DIM_RECURSOS_APRENENTATGE_KEY IS NULL 


SELECT * 
FROM db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax    
WHERE CODI_RECURS IN ( 
'122912',
'123948',
'123103',
'123105',
'122998',
'123109') 

select * from db_uoc_prod.stg_dadesra.dimax_v_recurs where id_recurs = 122912 limit 50;

'123998',
'123994',
'123879',
'122994',
'123008',
'123722',
'123099',
'123100',
'122955',
'122919',
'122904',
'123002',
'14314',
'122978',
'123954',
'123104',
'123084',
'123095',
'123765',
'123066',
'123732',
'122958',
'123723',
'122936',
'105354',
'123006',
'123001',
'123003',
'123098',
'123926',
'122991',
'123953',
'123107',
'123878',
'123101',
'122897',
'122902',
'123020',
'123010',
'123108',
'122979',
'122949',
'122908',
'122935',
'14316',
'123121',
'122996',
'123073',
'122895',
'123995',
'123007',
'122971',
'123999',
'123548',
'122945',
'123176',
'123731',
'123520',
'122906',
'122937',
'124001',
'122921',
'123950',
'123096',
'122916',
'123072',
'123997',
'123097',
'122952',
'123004',
'123000',
'122992',
'122909',
'122954',
'122893',
'123359',
'122947',
'122905',
'122948',
'123947',
'122901',
'123018',
'123022',
'122917',
'122950',
'124000',
'123952',
'123083',
'122953',
'122957',
'122977',
'123019',
'123992',
'123549',
'122910',
'122914',
'122942',
'123996',
'124002',
'123070',
'123005',
'123949',
'122892',
'123106',
'123013',
'122911',
'123287',
'122951',
'122944',
'122946',
'123021',
'123067',
'123071',
'123993',
'123102',
'122933',
'122956',
'123161',
'122899',
'123951',
'122943',
'123023',
'122913',
'122907',
'123946',
'122999',
'123798'

)














SELECT * 
-- FROM db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax  
from db_uoc_prod.stg_dadesra.dimax_v_recurs  
WHERE id_recurs IN ( 
'122912',
'123948',
'123103',
'123105',
'122998',
'123109') 

FRANCESC: 
db_uoc_prod.stg_dadesra.dimax_v_recurs

USAMOS PARA HACER RA_DIMAX: 
db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax 


db_uoc_prod.stg_dadesra.dimax_v_recurs > db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax 

select * from db_uoc_prod.stg_dadesra.dimax_v_recurs where id_recurs = 122912 limit 50;

select DISTINCT id_recurs  from db_uoc_prod.stg_dadesra.dimax_v_recurs  -- 101,985

select DISTINCT CODI_RECURS  from db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax -- 100,821

--# RECURSOS NO INCLUIDOS: 
select DISTINCT id_recurs  
from db_uoc_prod.stg_dadesra.dimax_v_recurs  -- 101,985

WHERE ID_RECURS NOT IN (
    select DISTINCT CODI_RECURS  
    from db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax --  101,985 VS 100,821  = 1,164 
)
