--DADES_ACADEMIQUES: 
select count(*), 'STAGE_DADES_ACADEMIQUES_COCO' As tabla from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO union all  
select count(*), 'STAGE_DADES_ACADEMIQUES_DIMAX' As tabla from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX union all  
select count(*), 'POST_DADES_ACADEMIQUES' As tabla from  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES union all  


-- EVENTS
select count(*), 'STAGE_LIVE_EVENTS_FLATENED' As tabla from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED   union all  
 
-- FACTS
select count(*), 'FACT_DADES_ACADEMIQUES_EVENTS' As tabla from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS  union all  
select count(*), 'FACT_DADES_ACADEMIQUES_EVENTS_AGG' As tabla from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG   


/*
1712745	    STAGE_DADES_ACADEMIQUES_COCO
3390446	    STAGE_DADES_ACADEMIQUES_DIMAX
5103191	    POST_DADES_ACADEMIQUES
12351002	STAGE_LIVE_EVENTS_FLATENED
15455767	FACT_DADES_ACADEMIQUES_EVENTS
5103191	    FACT_DADES_ACADEMIQUES_EVENTS_AGG

-- ### 
1712745	    STAGE_DADES_ACADEMIQUES_COCO
3390446	    STAGE_DADES_ACADEMIQUES_DIMAX
5103191	    POST_DADES_ACADEMIQUES
12351002	STAGE_LIVE_EVENTS_FLATENED
9677940	    FACT_DADES_ACADEMIQUES_EVENTS
5103191	    FACT_DADES_ACADEMIQUES_EVENTS_AGG

*/


---############ 
 select dim_assignatura_key, dim_semestre_key, dim_recursos_aprenentatge_key, count(*)
 from DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES  
 group by 1,2,3
 having count (*) > 1
 order by 3

---############ 
 select dim_assignatura_key, dim_semestre_key, dim_recursos_aprenentatge_key, count(*)
 from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO  
 group by 1,2,3
 having count (*) > 1


 /*

00.010	20012	COCO-114368	4
00.010	20012	COCO-114374	4
00.010	20012	COCO-114375	4
*/


select * 
from  DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO

where  dim_assignatura_key = '00.010'
order by 2,3




--- 

    SELECT distinct
        semestre.CODI_EXTERN AS DIM_SEMESTRE_KEY
        , asignatura.CODI_FINAL AS  DIM_ASSIGNATURA_KEY
        , coco_products.codi_recurs  AS CODI_RECURS 
        -- , coco_products.TITOL AS TITOL_RESOURCE
        ,  max (plan_publicacion.id  ) AS  PLAN_ESTUDIOS_BASE --- genera duplicados: varios planes de publicacion 
 
    FROM db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247,902 vs  247,902
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion   --247,902  vs 247,902
        on productos_plan_publicacion.versio_id = plan_publicacion.id 
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura -- 247,902  vs 247,902
        on  asignatura.id = plan_publicacion.fk_element_formacio_element_id
    
    inner join db_uoc_prod.stg_dadesra.autors_periode semestre  
        on semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID -- 247,902  vs 247,902 vs 247,151

    inner join   DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS coco_products -- 247,902  vs 247,902
        on  productos_plan_publicacion.PRODUCTE_ID  = coco_products.codi_recurs
group by  1,2,3
order by 4 desc   247,151


versio_id

with aux_cte_table as ( 

select codi_final , count(*) 
from  db_uoc_prod.stg_dadesra.autors_element_formacio  
group by codi_final
-- order by 2 desc 

having count(*) > 1  -- 250 

select * 
from  db_uoc_prod.stg_dadesra.autors_element_formacio  


)

select codi_extern , count(*) 
from  db_uoc_prod.stg_dadesra.autors_periode
group by 1
-- order by 2 desc 

having count(*) > 1  -- 250 
autors_periode


select DIM_ASSIGNATURA_KEY,  DIM_SEMESTRE_KEY, CODI_RECURS  
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED  
where  1=1
and DIM_ASSIGNATURA_KEY is not null  -- 19,265,548 
and DIM_SEMESTRE_KEY is not null  -- 19,265,548
and CODI_RECURS is not null   -- 12,209,242 vs 12,209,242 --> limitante 
-- group by 1,2,3 



select events.* 
    FROM  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES dades_academiques -- 7,888,532

    left join DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED events   -- 4 ultimos anos : 8,741,384 vs 123,019 --> datos by semestre, asignatura, producto grouped
        on dades_academiques.DIM_ASSIGNATURA_KEY = events.DIM_ASSIGNATURA_KEY -- 114,821,250
        AND dades_academiques.DIM_SEMESTRE_KEY = events.DIM_SEMESTRE_KEY
        AND dades_academiques.CODI_RECURS = events.CODI_RECURS -- 43k  -- agrupar por 

                AND dades_academiques.CODI_RECURS = events.CODI_RECURS -- 43k  -- agrupar por 

select events.* 










with temp_table as (
    select 
 

            
        dades_academiques.DIM_ASSIGNATURA_KEY
        , dades_academiques.DIM_SEMESTRE_KEY
        , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY    
        -- , dades_academiques. PLAN_ESTUDIOS_BASE
        , dades_academiques.ORIGEN_DADES_ACADEMIQUES
        , dades_academiques.CODI_RECURS

     

    FROM  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES dades_academiques -- 7,888,532

    left join DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED events   -- 4 ultimos anos : 8,741,384 vs 123,019 --> datos by semestre, asignatura, producto grouped
        on dades_academiques.DIM_ASSIGNATURA_KEY = events.DIM_ASSIGNATURA_KEY -- 114,821,250
        AND dades_academiques.DIM_SEMESTRE_KEY = events.DIM_SEMESTRE_KEY
        AND dades_academiques.CODI_RECURS = events.CODI_RECURS -- 43k  -- agrupar por 

) 
select * from temp_table



with aux_cte_table as ( 
select DIM_ASSIGNATURA_KEY ||DIM_SEMESTRE_KEY || CODI_RECURS as mastery_key,  * 
from  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES FACT_DADES_ACADEMIQUES_EVENTS 

) 
select * from aux_cte_table 
where mastery_key not in (
        select DIM_ASSIGNATURA_KEY ||DIM_SEMESTRE_KEY || CODI_RECURS as mastery_key  
        from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS 
    )



select * from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG 
-- order by 4 desc 
where times_used = 0

6,186,460
6,074,242

select * from  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES   


select sum(times_used) 
from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG 
 


with aux_cte_table as ( 
select DIM_ASSIGNATURA_KEY ||DIM_SEMESTRE_KEY || CODI_RECURS as mastery_key,  * 
from  DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES FACT_DADES_ACADEMIQUES_EVENTS 

) 


select distinct DIM_ASSIGNATURA_KEY , DIM_SEMESTRE_KEY,  CODI_RECURS 
from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS   -- 6,186,460 


select   DIM_ASSIGNATURA_KEY , DIM_SEMESTRE_KEY,  CODI_RECURS , EVENT_CODI_RECURS 
from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS
where EVENT_CODI_RECURS is null 
--5,091,975 no hacen match 
--5,204,193


---################################################################################################
select   DIM_ASSIGNATURA_KEY , DIM_SEMESTRE_KEY,  CODI_RECURS , EVENT_CODI_RECURS 
from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS
where EVENT_CODI_RECURS is null 
--5,091,975 no hacen match 
--5,204,193



select  count(EVENT_CODI_RECURS)  -- 10452227 --> perdemos 2M
from DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS
where EVENT_CODI_RECURS is null 



-- 3333530
select   *
from DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES
where CODI_RECURS is null --6,074,242

----##########################################################################################################################
---- Validacion conteos 
----##########################################################################################################################
----##########################################################################################################################
with aux_cte_table as ( 
    select   
        DIM_ASSIGNATURA_KEY 
        , DIM_SEMESTRE_KEY
        , CODI_RECURS
        , cast(DIM_ASSIGNATURA_KEY || DIM_SEMESTRE_KEY || CODI_RECURS as string) as master  -- 10452227 --> perdemos 2M : 
    
    from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED  -- 12,210,672 
) 
select   
    *
    , cast( DIM_ASSIGNATURA_KEY || DIM_SEMESTRE_KEY || CODI_RECURS  as string ) as master

from DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES
where cast( DIM_ASSIGNATURA_KEY || DIM_SEMESTRE_KEY || CODI_RECURS  as string )  not in ( select master from aux_cte_table )

----##########################################################################################################################

sum( )


select   sum(times_used) 
From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG  -- 10464843 vs 12224872


---##########################
with auxiliar as ( 
SELECT 

    dades_academiques.DIM_ASSIGNATURA_KEY
    , dades_academiques.DIM_SEMESTRE_KEY
    , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY
    , count( dades_academiques.CODI_RECURS )  as TIMES_USED
 

FROM  DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED dades_academiques
group by 1,2,3

) 

select  sum(times_used) 
    -- DIM_ASSIGNATURA_KEY
    -- , DIM_SEMESTRE_KEY
    -- , DIM_RECURSOS_APRENENTATGE_KEY
    -- , coalesce(TIMES_USED , 0) as TIMES_USED
from auxiliar




----##########################################################################################################################
---- Validacion conteos 
----##########################################################################################################################
----##########################################################################################################################
with aux_cte_table as ( 
    select   
        DIM_ASSIGNATURA_KEY 
        , DIM_SEMESTRE_KEY
        , CODI_RECURS
        , cast(DIM_ASSIGNATURA_KEY || DIM_SEMESTRE_KEY || CODI_RECURS as string) as master  -- 10452227 --> perdemos 2M : 
    
    from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED  -- 12,210,672 

) 
select   distinct 
        DIM_ASSIGNATURA_KEY 
        , DIM_SEMESTRE_KEY
        , CODI_RECURS
    , cast( DIM_ASSIGNATURA_KEY || DIM_SEMESTRE_KEY || CODI_RECURS  as string ) as master

from DB_UOC_PROD.DDP_DOCENCIA.POST_DADES_ACADEMIQUES
where cast( DIM_ASSIGNATURA_KEY || DIM_SEMESTRE_KEY || CODI_RECURS  as string )  not in ( select master from aux_cte_table )

----##########################################################################################################################




select   sum(times_used) 
From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG  -- 10464843 vs 12224872

select * From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG  -- 5,103,191 tiene la tabla  vs 4,990,924 no hacen cruce

select * From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG -- 4,990,924 -- coinciden los valores
where times_used = 0


--- vemos que asignaturas nos faltan 
select distinct DIM_ASSIGNATURA_KEY  --- 731  vemos que asignaturas nos faltan 
From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG agg -- 4,990,924 -- coinciden los valores

where agg.times_used = 0
and DIM_ASSIGNATURA_KEY not in (select DIM_ASSIGNATURA_KEY From DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA)


--- vemos que recursos nos faltan 
select distinct DIM_RECURSOS_APRENENTATGE_KEY  --- 52,134 -- posible concatenacion  --> NIU / COCO + Codi_recurs 
From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG agg -- 4,990,924 -- coinciden los valores
where agg.times_used = 0

and DIM_RECURSOS_APRENENTATGE_KEY not in (select DIM_RECURSOS_APRENENTATGE_KEY From DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE)  -- no NIU


--- vemos que semestre nos faltan 
select distinct DIM_SEMESTRE_KEY  --- 0
From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG agg -- 4,990,924 -- coinciden los valores
where agg.times_used = 0
and DIM_SEMESTRE_KEY not in (select DIM_SEMESTRE_KEY From DB_UOC_PROD.DD_OD.DIM_SEMESTRE)




--- vemos que asignaturas nos faltan 
select 
    -- distinct -- 1,715,908
    DIM_ASSIGNATURA_KEY 
    , DIM_RECURSOS_APRENENTATGE_KEY
    , DIM_SEMESTRE_KEY
From DB_UOC_PROD.DDP_DOCENCIA.FACT_DADES_ACADEMIQUES_EVENTS_AGG agg -- 4,990,924 -- coinciden los valores

where agg.times_used = 0
or  DIM_SEMESTRE_KEY not in (select DIM_SEMESTRE_KEY From DB_UOC_PROD.DD_OD.DIM_SEMESTRE)
and ( 
    DIM_ASSIGNATURA_KEY not in (select DIM_ASSIGNATURA_KEY From DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA) 
    or 
    DIM_RECURSOS_APRENENTATGE_KEY not in (select DIM_RECURSOS_APRENENTATGE_KEY From DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE) --)  -- 1,715,908 asignados 
    -- or 
    -- DIM_SEMESTRE_KEY not in (select DIM_SEMESTRE_KEY From DB_UOC_PROD.DD_OD.DIM_SEMESTRE)
)


select * from DB_UOC_PROD.DDP_DOCENCIA.T_COCO_PROD_TEMP_DUPLICATES_TEMP