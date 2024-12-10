with aux_cte_table as ( 

SELECT 
    db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node,
    -- db_uoc_prod.stg_dadesra.dimax_resofite_path.id_resource,
    db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs AS id_resource,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs, -- same as  db_uoc_prod.stg_dadesra.dimax_item_dimax.id 
    -- db_uoc_prod.stg_dadesra.dimax_resofite_path.ordre,
    db_uoc_prod.stg_dadesra.dimax_item_dimax.titol,

    db_uoc_prod.stg_dadesra.dimax_v_recurs.titol AS titol_resource,
    SUBSTR(db_uoc_prod.stg_dadesra.dimax_item_dimax.titol, 0, 6) AS DIM_ASSIGNATURA_KEY
 
    FROM db_uoc_prod.stg_dadesra.dimax_resofite_path    --- registros : 17,303,400
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400
    
    left join db_uoc_prod.stg_dadesra.dimax_v_recurs 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami = db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs -- 17303400 
    
    left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra 
        on db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs = db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.id_recurs -- 17303400

    where 1=1
        AND ( 
            length( db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node ) >=  25
            or 
            db_uoc_prod.stg_dadesra.dimax_item_dimax.titol like '%Root Node:PV%' --- eliminamos : Root Node:BIBLIO
        )  
        AND db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs =  69226


) select * from aux_cte_table 


    where 1=1 AND  titol like '%Root Node:PV%'

    group by cami_node 
        AND ( 
            length( cami_node ) <  25
            -- or 
            -- db_uoc_prod.stg_dadesra.dimax_item_dimax.titol like '%Root Node:PV%' --- eliminamos : Root Node:BIBLIO
        )  
 



  select *
    FROM db_uoc_prod.stg_dadesra.dimax_resofite_path    --- registros : 17,303,400
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400



  select db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node, count(*)  -- 1,755,718
    FROM   db_uoc_prod.stg_dadesra.dimax_item_dimax 
    
    -- where db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node = ';3067899;3050333;3050332;'

    group by 1


    having count(*) > 1 

        order by 2 desc 

on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400


select db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami, count(*)  -- 1,755,718
 
    FROM db_uoc_prod.stg_dadesra.dimax_resofite_path    --- registros : 17,303,400
    
    -- left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
    --     on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400
    
    group by 1
    having count(*) > 1 
    order by 2 desc 



select * from db_uoc_prod.stg_dadesra.dimax_resofite_path
where node_recurs =  1800369


select node_cami || node_recurs    , count(*)
-- * 
from db_uoc_prod.stg_dadesra.dimax_resofite_path
    -- left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
    --     on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400

where node_cami =  52636
group by 1 
having count(*) > 1 

order by 1, 2,3,4


---##### 
select  distinct * --  node_cami , node_recurs
from db_uoc_prod.stg_dadesra.dimax_resofite_path
    -- left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
    --     on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400

where node_cami =  52636
and node_recurs = 2775575

order by 1 desc








SELECT 
    db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node,
    -- db_uoc_prod.stg_dadesra.dimax_resofite_path.id_resource,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami as id_resource,  -- id_ que equivale a la tabla de dim_catalog 
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs, -- same as  db_uoc_prod.stg_dadesra.dimax_item_dimax.id 
    -- db_uoc_prod.stg_dadesra.dimax_resofite_path.ordre,
    db_uoc_prod.stg_dadesra.dimax_item_dimax.titol,
    db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs AS id_recurs2,
    db_uoc_prod.stg_dadesra.dimax_v_recurs.titol AS titol_resource,
    SUBSTR(db_uoc_prod.stg_dadesra.dimax_item_dimax.titol, 0, 6) AS DIM_ASSIGNATURA_KEY
 

FROM db_uoc_prod.stg_dadesra.dimax_resofite_path    --- registros : 17,303,400
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400
    
    left join db_uoc_prod.stg_dadesra.dimax_v_recurs 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami = db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs -- 17303400 
    
    left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra 
        on db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs = db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.id_recurs -- 17303400



