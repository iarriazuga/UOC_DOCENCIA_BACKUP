

-- -- #################################################################################################
-- codi_recurs_origen = 'ERROR'
-- -- #################################################################################################
/*
select codi_recurs_origen , count(*) from codi_recurs_valoration group by 1 order by 2 desc

CODI_RECURS_ORIGEN	COUNT(*)
DIMAX	            33389
COCO	            30859
BOTH	            7290
ERROR	            11
    * not fount in base tables: 
        db_uoc_prod.stg_dadesra.autors_producte  -- coco_prod
        db_uoc_prod.stg_dadesra.autors_modul autors_modul  -- coco_mod
        db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax  -- dimax
        db_uoc_prod.stg_dadesra.dimax_v_recurs -- id_recurs --> origen tables 
    
    -- AND codi_recurs_origen = 'ERROR'
    '302376',
    '305233',
    '302376',
    '305213',
    '305213',
    '302378',
    '302378',
    '296708',
    '296716',
    '305213',
    '305233'
*/

select * 
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED 
where 1=1
and codi_recurs in (

    -- AND codi_recurs_origen = 'ERROR'
    '302376',
    '305233',
    '302376',
    '305213',
    '305213',
    '302378',
    '302378',
    '296708',
    '296716',
    '305213',
    '305233'

)



-- FROM db_uoc_prod.stg_dadesra.autors_producte  -- 55,848
select * FROM db_uoc_prod.stg_dadesra.autors_producte  
where 1=1
    AND id in (

    -- AND codi_recurs_origen = 'ERROR'
    '302376',
    '305233',
    '302376',
    '305213',
    '305213',
    '302378',
    '302378',
    '296708',
    '296716',
    '305213',
    '305233'

)


select * FROM db_uoc_prod.stg_dadesra.autors_modul autors_modul  
    -- left join productos_aux autors_producte on autors_producte.codi_recurs = autors_modul.PRODUCTE_CREACIO_ID 
where 1=1
    AND id in (

    -- AND codi_recurs_origen = 'ERROR'
    '302376',
    '305233',
    '302376',
    '305213',
    '305213',
    '302378',
    '302378',
    '296708',
    '296716',
    '305213',
    '305233'

)



select * 
from db_uoc_prod.stg_dadesra.dimax_v_recurs -- id_recurs --> origen tables 
where 1=1
    AND id_recurs in (

    -- AND codi_recurs_origen = 'ERROR'
    '302376',
    '305233',
    '302376',
    '305213',
    '305213',
    '302378',
    '302378',
    '296708',
    '296716',
    '305213',
    '305233'

)
















-- -- #################################################################################################
-- codi_recurs_origen = 'ERROR'
-- -- #################################################################################################
with aux  as ( 

select distinct
eve.codi_recurs , eve.source,  rec.origen_base_dades
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED eve

left join DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE rec 
on eve.codi_recurs = rec.codi_recurs
) 

select Origen_events , origen_base_dades,  count(*) 

from aux
group by 1,2
order by 1 desc


--- valoracion de duplicados  : conservamos --> pasar listado a frances : 
select codi_recurs, count(*) 
from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE --8,975
group by 1
having count(*) > 1 

delete from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE 


--- valoracion de duplicados 
select codi_recurs as test2 , * --codi_recurs, count(*) 
from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE --8,975
where codi_recurs in ( 



'114045',
'113965',
'122347',
'114123',
'113993',
'122487',
'113963',
'122291',
'122293',
'122351',
'122276',
'113887'
)
 order by codi_recurs desc





-- ACORAN

with aux  as ( 

select distinct
eve.codi_recurs , eve.source,  rec.origen_base_dades
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED eve

left join DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE rec 
on eve.codi_recurs = rec.codi_recurs
) 

select Origen_events , origen_base_dades,  count(*) 

from aux
group by 1,2
order by 1 desc


--- valoracion de duplicados  : conservamos --> pasar listado a frances : 
select codi_recurs, count(*) 
from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE --8,975
group by 1
having count(*) > 1 




--- valoracion de duplicados 
select codi_recurs as test2 , * --codi_recurs, count(*) 
from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE --8,975
where codi_recurs in ( 



'114045',
'113965',
'122347',
'114123',
'113993',
'122487',
'113963',
'122291',
'122293',
'122351',
'122276',
'113887'
)
 order by codi_recurs desc

-- francesc
listado asignaturas no matchean / no existen STAGE_LIVE_EVENTS_FLATENED
listado recursos no matchean / no existen STAGE_LIVE_EVENTS_FLATENED


/**
niu	null	9
niu	DIMAX	17117
niu	COCO_PROD	12893
niu	COCO_MOD	2909

-- fase 2 
niu	null	6
niu	DIMAX	17195
niu	COCO_MOD	2909
niu	COCO_PROD	10372


*/