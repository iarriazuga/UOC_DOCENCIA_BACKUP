-- -- #################################################################################################
-- -- #################################################################################################
-- -- STAGE_POST_DADES_ACADEMIQUES 
-- -- #################################################################################################
-- -- #################################################################################################

CREATE OR REPLACE TABLE DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES2(

    DIM_PERSONA_KEY NUMBER(10,0) COMMENT 'Clau DIM_PERSONA_KEY.',
    DIM_ASSIGNATURA_KEY VARCHAR(6) COMMENT 'Clau assignatura.',
    DIM_SEMESTRE_KEY NUMBER(38, 0) COMMENT 'Clau semestre.',
    DIM_RECURSOS_APRENENTATGE_KEY VARCHAR(15) COMMENT 'Clau recursos d\'aprenentatge.',
    CODI_RECURS NUMBER(38, 0) COMMENT 'Codi del recurs.',
    ORIGEN_DADES_ACADEMIQUES VARCHAR(5) COMMENT 'Font de les dades acadèmiques.'

) AS 

with aux_temporary_table as (

    SELECT 
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY,
        'COCO - ' || CODI_RECURS AS DIM_RECURSOS_APRENENTATGE_KEY,
        CODI_RECURS,
        'COCO' AS ORIGEN_DADES_ACADEMIQUES
    FROM DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO

    UNION ALL

    SELECT     
        DIM_ASSIGNATURA_KEY,
        DIM_SEMESTRE_KEY,
        'DIMAX - ' || CODI_RECURS AS DIM_RECURSOS_APRENENTATGE_KEY,
        CODI_RECURS,
        'DIMAX' AS ORIGEN_DADES_ACADEMIQUES
    FROM DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX
)
 
select 

        --DIM_KEYS:
        personas_assignaturas.idp as DIM_PERSONA_KEY -- Incluido para ver el profesor de la asignatura --> Relacion 1:1 -> no genera duplicados
        , aux_temporary_table.DIM_ASSIGNATURA_KEY
        , aux_temporary_table.DIM_SEMESTRE_KEY
        , aux_temporary_table.DIM_RECURSOS_APRENENTATGE_KEY

        , aux_temporary_table.CODI_RECURS
        , aux_temporary_table.ORIGEN_DADES_ACADEMIQUES

from aux_temporary_table

left join DB_UOC_PROD.STG_DADESRA.GAT_PERSONAS_ASIGNATURAS as personas_assignaturas
    on personas_assignaturas.cod_asignatura = aux_temporary_table.DIM_ASSIGNATURA_KEY
    AND personas_assignaturas.any_academico = aux_temporary_table.DIM_SEMESTRE_KEY




/*
-- desc table  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES

with aux as ( 
select  -- *
    idp,
    any_academico as semester, --? 
    cod_asignatura, 
    nom,  
    cognom1, 
    cognom2
from  DB_UOC_PROD.STG_DADESRA.GAT_PERSONAS_ASIGNATURAS gat_personas  -- 312,202
inner join  DB_UOC_PROD.DD_OD.DIM_PERSONA dim_persona  -- 1,242,113
on dim_persona.dim_persona_key = gat_personas.idp  -- 312,187 
 
    --> perdemos solo 25 registros = 3 personas -->   30000709, 301100650, 30100462
            -- IDP	        SEMESTER
            -- 30100462	    20052
            -- 301100650	20052
            -- 30000709	    20053
            -- 30000709	    20052
    
 
) 
select semester, cod_asignatura, idp, count(*) 
from aux 
group by 1,2,3
order by 4 desc


describe table DB_UOC_PROD.DD_OD.DIM_PERSONA
 

*/