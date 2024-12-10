-- -- #################################################################################################
-- -- #################################################################################################
-- -- FACT_DOCENCIA?
-- -- #################################################################################################
-- -- #################################################################################################
/***
Reutilizar tables de docencia
- fact docencia : semestre + asignatura + estudiante ( posible aula )
- nivel asignatura / docencia / semestre --> nivel estudiante 
6M historica

*/

 
CREATE  OR REPLACE TEMPORARY  TABLE DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO_TEMPORARY  AS 
with cross_semestre_asignatura AS ( 
    
    SELECT 
        semestre.dim_semestre_key  AS semestre_id
        , codi_final AS asignatura
     
    FROM DB_UOC_PROD.DD_OD.dim_semestre semestre
    cross join   db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura 
    
    where 1=1 
        AND semestre.dim_semestre_key is not null 
        AND asignatura.codi_final is not null
    
    order by 2,1

)

, semestres_informados AS (

    SELECT 
    
        plan_publicacion.id || ' - ' || semestre.CODI_EXTERN AS  PLAN_ESTUDIOS_BASE
        , asignatura.CODI_FINAL AS  titulo_asignatura
        -- , productos_plan_publicacion.PRODUCTE_ID  AS codi_producto_coco
        , coco_products.id  AS codi_producto_coco --- dimax 
        , coco_products.TITOL AS titulo_prod_coco
        ,  semestre.CODI_EXTERN AS semestre_extract
        , * 
     -- completar distinct de estas tablas --> SELECT * 
    FROM db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247,364 
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion 
        on plan_publicacion.id =  productos_plan_publicacion.versio_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura 
    on  asignatura.id = plan_publicacion.fk_element_formacio_element_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_producte coco_products 
    on  coco_products.id = productos_plan_publicacion.PRODUCTE_ID 
    
    inner join db_uoc_prod.stg_dadesra.autors_periode semestre  
    on semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID -- no dupliciteis 247,364
 
    where 1=1  -- 247,364

    -- AND coco_products.id  is null   -- 0 

)
,  cross_semestres_informados AS ( 
        SELECT  
            cross_semestre_asignatura.asignatura
            , cross_semestre_asignatura.semestre_id
            , semestres_informados.codi_producto_coco
            , semestres_informados.titulo_prod_coco
            , semestres_informados. PLAN_ESTUDIOS_BASE
        
        FROM  cross_semestre_asignatura
        left join semestres_informados 
            on cross_semestre_asignatura.asignatura = semestres_informados.titulo_asignatura
                AND cross_semestre_asignatura.semestre_id = semestres_informados.semestre_extract
        -- where  cross_semestre_asignatura.asignatura = 'B0.911'
        
        order by  cross_semestre_asignatura.asignatura , cross_semestre_asignatura.semestre_id desc

) 
 


, informed_semesters AS (
    SELECT distinct --- 246,045
        asignatura,
        semestre_id AS informed_semestre_id,
        codi_producto_coco,
        titulo_prod_coco,
         PLAN_ESTUDIOS_BASE
    FROM cross_semestres_informados
    WHERE titulo_prod_coco IS NOT NULL
)

, ultimo_semestre_informado AS (
    SELECT
        csi.asignatura,
        csi.semestre_id,
        
        -- nulls created : no plan de estudios
        csi.codi_producto_coco,
        csi.titulo_prod_coco,
        
        csi. PLAN_ESTUDIOS_BASE,
        CASE 
            when csi.titulo_prod_coco is not null then NULL 
            else (
        
                SELECT  max( is2.informed_semestre_id ) 
                FROM informed_semesters is2
                WHERE is2.asignatura = csi.asignatura AND is2.informed_semestre_id <= csi.semestre_id
            )
        end AS last_informed_semestre
    FROM cross_semestres_informados csi
)



/*
, ultimo_semestre_informado AS (
    SELECT
        csi.asignatura,
        csi.semestre_id,
        
        -- nulls created 
        max(coalesce( csi.codi_producto_coco, '-')) AS codi_producto_coco,
        max(coalesce( csi.titulo_prod_coco, '-')) AS titulo_prod_coco,
        max(coalesce( csi. PLAN_ESTUDIOS_BASE, '-')) AS  PLAN_ESTUDIOS_BASE,
        max( inf.informed_semestre_id ) AS last_informed_semestre
        -- CASE 
        --     when csi.titulo_prod_coco is not null then NULL 
        --     else (
        
        --         SELECT  max( is2.informed_semestre_id ) 
        --         FROM informed_semesters is2
        --         WHERE is2.asignatura = csi.asignatura AND is2.informed_semestre_id <= csi.semestre_id
        --     )
        -- end AS last_informed_semestre

    FROM cross_semestres_informados csi

    left join informed_semesters inf 
        on 1=1
            AND inf.asignatura = csi.asignatura 
            AND inf.informed_semestre_id <= csi.semestre_id -- 1,632,337 to  1,397,256

    group by 1,2
 

 */
, propagacion_ultimo_semestre_informado AS (
    SELECT
        swr.asignatura,
        swr.semestre_id, -- fecha  : castear 
        COALESCE(swr.codi_producto_coco, inf.codi_producto_coco) AS codi_producto_coco, -- recurso : dimax 
        COALESCE(swr.titulo_prod_coco, inf.titulo_prod_coco) AS titulo_prod_coco,
        COALESCE(swr. PLAN_ESTUDIOS_BASE, inf. PLAN_ESTUDIOS_BASE) AS  PLAN_ESTUDIOS_BASE
        
    FROM ultimo_semestre_informado swr
    LEFT JOIN informed_semesters inf
        ON swr.asignatura = inf.asignatura
        AND swr.last_informed_semestre = inf.informed_semestre_id
)

SELECT 
    
    asignatura
    , semestre_id
    , codi_producto_coco
    , titulo_prod_coco
    ,  PLAN_ESTUDIOS_BASE
FROM propagacion_ultimo_semestre_informado

where 1=1 
    -- AND asignatura = 'B0.911' 
    AND codi_producto_coco is not null -- no tienen plan de estudios previo  --  2.9M vs  1.9M


ORDER BY asignatura, semestre_id;


