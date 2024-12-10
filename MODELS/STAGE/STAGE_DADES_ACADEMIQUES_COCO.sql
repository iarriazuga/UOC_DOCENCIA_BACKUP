CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO_2 AS 


with cross_semestre_asignatura AS (
    
    SELECT distinct-- 1,422,120 vs 1,397,424
        semestre.DIM_SEMESTRE_KEY
        , asignatura.codi_final AS DIM_ASSIGNATURA_KEY
     
    FROM DB_UOC_PROD.DD_OD.dim_semestre semestre
    cross join   db_uoc_prod.stg_dadesra.autors_element_formacio asignatura  -- dim asignatura : esta tala no tiene registros unicos 
    
    where 1=1 
        AND semestre.DIM_SEMESTRE_KEY is not null 
        AND asignatura.codi_final is not null
 

)

, semestres_informados AS (

    SELECT distinct

        semestre.CODI_EXTERN AS DIM_SEMESTRE_KEY
 
        , left(asignatura.CODI_FINAL, 6) AS  DIM_ASSIGNATURA_KEY

        , coco_products.codi_recurs  AS CODI_RECURS 
        , coco_products.titol_recurs AS TITOL_RESOURCE
        -- ,  (plan_publicacion.id || '' - '' || semestre.CODI_EXTERN) AS  PLAN_ESTUDIOS_BASE --- genera duplicados: varios planes de publicacion 

 
    FROM db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247,902 vs  247,902
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion   --247,902  vs 247,902
        on plan_publicacion.id =  productos_plan_publicacion.versio_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura -- 247,902  vs 247,902
        on  asignatura.id = plan_publicacion.fk_element_formacio_element_id
    
    inner join db_uoc_prod.stg_dadesra.autors_periode semestre  
        on semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID -- 247,902  vs 247,902 vs 247,151

    inner join   DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS coco_products -- 247,902  vs 247,902
        on  coco_products.codi_recurs = productos_plan_publicacion.PRODUCTE_ID 
)

,  cross_semestres_informados AS ( 
        SELECT    --1,602,157
            cross_semestre_asignatura.DIM_ASSIGNATURA_KEY
            , cross_semestre_asignatura.DIM_SEMESTRE_KEY
            , semestres_informados.CODI_RECURS
            , semestres_informados.TITOL_RESOURCE
            -- , semestres_informados.PLAN_ESTUDIOS_BASE

        FROM  cross_semestre_asignatura 
        
        left join semestres_informados 
            on cross_semestre_asignatura.DIM_ASSIGNATURA_KEY = semestres_informados.DIM_ASSIGNATURA_KEY
                AND cross_semestre_asignatura.DIM_SEMESTRE_KEY = semestres_informados.DIM_SEMESTRE_KEY
) 

, informed_semesters AS (
    SELECT distinct --- 246,045
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY AS informed_DIM_SEMESTRE_KEY,
        CODI_RECURS,
        TITOL_RESOURCE,
        --  PLAN_ESTUDIOS_BASE
    FROM cross_semestres_informados
    WHERE TITOL_RESOURCE IS NOT NULL


)

, ultimo_semestre_informado AS (
    SELECT
        csi.DIM_ASSIGNATURA_KEY as DIM_ASSIGNATURA_KEY,
        csi.DIM_SEMESTRE_KEY as DIM_SEMESTRE_KEY,
        
        -- nulls created : no plan de estudios
        csi.CODI_RECURS as CODI_RECURS,
        csi.TITOL_RESOURCE as TITOL_RESOURCE,
        
        -- csi.PLAN_ESTUDIOS_BASE as PLAN_ESTUDIOS_BASE ,
        CASE 
            when csi.TITOL_RESOURCE is not null then NULL 
            else (
        
                SELECT  max( is2.informed_DIM_SEMESTRE_KEY ) 
                FROM informed_semesters is2
                WHERE is2.DIM_ASSIGNATURA_KEY = csi.DIM_ASSIGNATURA_KEY AND is2.informed_DIM_SEMESTRE_KEY <= csi.DIM_SEMESTRE_KEY
            )
        end AS last_informed_semestre
    FROM cross_semestres_informados csi
)

, propagacion_ultimo_semestre_informado AS (
    SELECT distinct
        swr.DIM_ASSIGNATURA_KEY,
        swr.DIM_SEMESTRE_KEY, -- fecha  : castear 
        COALESCE(swr.CODI_RECURS, inf.CODI_RECURS) AS CODI_RECURS, -- recurso : dimax 
        -- COALESCE(swr.PLAN_ESTUDIOS_BASE, inf.PLAN_ESTUDIOS_BASE) AS  PLAN_ESTUDIOS_BASE
        
    FROM ultimo_semestre_informado swr
    LEFT JOIN informed_semesters inf
        ON swr.DIM_ASSIGNATURA_KEY = inf.DIM_ASSIGNATURA_KEY
        AND swr.last_informed_semestre = inf.informed_DIM_SEMESTRE_KEY  -- 2,799,507
 
)

SELECT 

    propagacion_ultimo_semestre_informado.DIM_ASSIGNATURA_KEY
    , propagacion_ultimo_semestre_informado.DIM_SEMESTRE_KEY
    , ''COCO'' || '' - '' ||  propagacion_ultimo_semestre_informado.CODI_RECURS  as DIM_RECURSOS_APRENENTATGE_KEY
    , propagacion_ultimo_semestre_informado.CODI_RECURS as CODI_RECURS

    -- , propagacion_ultimo_semestre_informado.PLAN_ESTUDIOS_BASE
 
FROM propagacion_ultimo_semestre_informado

 -- no tienen plan de estudios asociado: crossjoin genera los campos inicio semestre, tomamos a partir del primer plan de estudios  
where propagacion_ultimo_semestre_informado.CODI_RECURS is not null --  2.9M vs  1.9M



decribe table DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO

DESCRIBE table DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO;
