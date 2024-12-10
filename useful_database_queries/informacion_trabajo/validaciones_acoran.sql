
--#########################################################################################
-- SNOWFLAKE: 
--#########################################################################################
select cast(  PLAN_ESTUDIOS_BASE as string) as  PLAN_ESTUDIOS_BASE1  from aux_planes_estudio_base

where  PLAN_ESTUDIOS_BASE not in (
    select distinct 
 
    CASE 
        WHEN CHARINDEX('-',  PLAN_ESTUDIOS_BASE) > 0 THEN 
            SUBSTRING( PLAN_ESTUDIOS_BASE, 1, CHARINDEX('-',  PLAN_ESTUDIOS_BASE) - 1)
        ELSE  PLAN_ESTUDIOS_BASE
    END AS  PLAN_ESTUDIOS_BASE1

    from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO 
    WHERE  PLAN_ESTUDIOS_BASE IS NOT NULL AND  PLAN_ESTUDIOS_BASE <> ''

)


/*
 PLAN_ESTUDIOS_BASE1
39463
48584
44432
48549
48483
48506
48516
48521
48529
48532
48533
48538
48547
48565
48570
48585
48594
48597
48524
48649
48666
48676
48678
48690
48697
59290
75199
48509
66103
72870
48495
48571
48519
48646
48650
48658
80405
75668
73722
75682
90155
35078
35203
48523
48593
48611
48679
75203
63981
38748
42241
39464
48497
48536
48555
48556
48605
48612
48624
48674
48691
48692
50203
51686
69824
75667
75202
80408
73707
75186
48655
75195
48631
75143
102651
58531
39929
44981
48515
48551
48698
53964
48881
48492
48503
48513
48517
48539
48546
48561
48574
48579
48583
48602
48607
48608
48617
48630
48639
48654
48662
48665
48677
48684
48689
48700
47947
53966
59285
75665
48643
48668
48581
48696
48518
75663
48641
75201
39930
48553
48603
48618
48634
48664
42752
48484
48486
48502
48510
48531
48535
48559
48564
48569
48576
48577
48580
48600
48610
48619
48644
48657
48673
48882
50202
53561
75190
75662
60911
48508
48542
48598
48590
48688
53967
75198
48656
48638
102653
102483
102484
38794
35202
43322
48541
48488
48609
48628
48660
48694
48485
48490
48514
48552
48573
48575
48494
48545
48595
48621
48633
48647
48695
80409
73706
72868
42242
48500
48586
73050
75197
75196
75670
40627
39928
48511
48554
48534
48614
48671
62948
48505
35205
35201
48491
48493
48522
48526
48528
48530
48540
48558
48560
48566
48568
48587
48592
48596
48601
48615
48627
48629
48640
48663
48675
50275
48699
47948
53962
55563
60951
74902
74903
75664
75669
48682
48572
48578
48589
48681
48693
48507
70222
80407
60917
60918
73703
59021
40955
48482
48487
48548
48550
48557
48625
48636
48670
48672
56645
35204
38749
39931
44431
48498
48563
48588
48591
48599
48604
48620
48626
48635
48642
48645
48667
48669
48683
48686
53963
73705
48527
76182
75627
72864
73213
48685
48504
48562
48632
50276
73704
75666
90154
48680
75142
48512
48496
48499
48520
48544
48616
48622
48687
47949
53942
48489
48501
48567
48582
48606
48613
48623
48637
48652
48653
48659
48661
47946
56644
73051
75628
63331
75683
72867
60912
35207
48525
48537
63330
73723
72802
48648
48651
48543
72869
75200

*/ 


with aux_planes_estudio_base  as ( 
    select  distinct VERSIO_ID  as  PLAN_ESTUDIOS_BASE, *  
    from db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247.4K
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion 
        on plan_publicacion.id =  productos_plan_publicacion.versio_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura 
    on  asignatura.id = plan_publicacion.fk_element_formacio_element_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_producte coco_products 
    on  coco_products.id = productos_plan_publicacion.PRODUCTE_ID 
    
    inner join db_uoc_prod.stg_dadesra.autors_periode semestre  
    on semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID
    
    WHERE  1=1
        AND coco_products.id   IS NOT NULL
        AND coco_products.TITOL   IS NOT NULL

) 

select * from aux_planes_estudio_base

where  PLAN_ESTUDIOS_BASE not in (
    select distinct 
 
    CASE 
        WHEN CHARINDEX('-',  PLAN_ESTUDIOS_BASE) > 0 THEN 
            SUBSTRING( PLAN_ESTUDIOS_BASE, 1, CHARINDEX('-',  PLAN_ESTUDIOS_BASE) - 1)
        ELSE  PLAN_ESTUDIOS_BASE
    END AS  PLAN_ESTUDIOS_BASE1

    from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO 
    WHERE  PLAN_ESTUDIOS_BASE IS NOT NULL AND  PLAN_ESTUDIOS_BASE <> ''

)

----###############################################################################################################################################################################


select distinct  coco_products.*   -- 1,319 vs 

FROM db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247,364 
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion 
        on plan_publicacion.id =  productos_plan_publicacion.versio_id

    inner JOIN Db_uoc_prod.stg_dadesra.autors_producte coco_products 
    on  coco_products.id = productos_plan_publicacion.PRODUCTE_ID 
       
where productos_plan_publicacion.versio_id not in (
    select distinct 
 
    CASE 
        WHEN CHARINDEX('-',  PLAN_ESTUDIOS_BASE) > 0 THEN 
            SUBSTRING( PLAN_ESTUDIOS_BASE, 1, CHARINDEX('-',  PLAN_ESTUDIOS_BASE) - 1)
        ELSE  PLAN_ESTUDIOS_BASE
    END AS  PLAN_ESTUDIOS_BASE1

    from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO 
    WHERE  PLAN_ESTUDIOS_BASE IS NOT NULL AND  PLAN_ESTUDIOS_BASE <> ''

)

-- empezar semestre pasado -- 20232 --> no puede anterior 
/*
 PLAN_ESTUDIOS_BASE 

--> cast as int ID_PRODUCTO
*/
select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO --1,9
select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX -- 3,5m
/*

*/


select recursos.id_asignatura, recursos.id_semestre, count(usos.*) 

from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES recursos
left join DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED usos 
    on usos.DIM_ASSIGNATURA_KEY  = recursos.id_asignatura
    AND usos.semester = recursos.id_semestre

    where usos.DIM_ASSIGNATURA_KEY is not null

group by 1,2 
order by 3 asc






select * 

from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED

-- SEMESTRE PARA DIMAX

with aux_cte_table as (

select  

distinct  
    CAST (YEAR(db_uoc_prod.stg_dadesra.dimax_item_dimax.data) AS VARCHAR(4)) ||  
        CASE 
            WHEN MONTH(db_uoc_prod.stg_dadesra.dimax_item_dimax.data) <= 6 
                THEN '1' 
            ELSE '2'
    END AS SEMESTRE
    , 
    titol as titol_test, -- revisar  Root Node:PV20212 --- buscar rootnode 
    db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node as nodes,
    *
FROM db_uoc_prod.stg_dadesra.dimax_resofite_path  --- registros : 17,303,400
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400

        where titol like '%Root Node:PV%'

order by 1 desc 

) 
select * from aux_cte_table -- 3,749,497
WHERE titol_test LIKE '%' || SEMESTRE || '%'; -- 3,272,054


-- limit 100;





 
select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO --1,9






-- Counts de elementos
select asignatura, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1  order by 2 desc -- 16.6K vs 13.0K  -- 3,600 asignaturas sin ningun recurso asignado 

select semestre_id, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO 
where 
group by 1  order by 1 desc -- 84

select codi_producto_coco, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1 order by 2 desc -- 53.5K  --> pocos

select  PLAN_ESTUDIOS_BASE, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1 order by 2 desc -- 42.0K vs 42.3K --> diferencia elementos --> 



select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX_2 -- 5,975,410  vs 
order by 2  desc

where node_cami_recortado like '%3069598%'


-- check values : 
select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX_2 -- 5,975,410  vs 648,699 --> null values
where semestre_nodos is null
order by 2  desc



-- check values : 
select *  
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX_2 -- 5,975,410  vs 648,699 --> null values -->  41,111
where semestre_nodos is null


select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX --5,975,410
where CAMI_NODE like '%;30043;'





---------##################
SELECT 
    db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.id_resource,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami,
    db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs,
    -- db_uoc_prod.stg_dadesra.dimax_resofite_path.ordre,
    db_uoc_prod.stg_dadesra.dimax_item_dimax.titol,
    db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs AS id_recurs2,
    db_uoc_prod.stg_dadesra.dimax_v_recurs.titol AS titol_resource,
    SUBSTR(db_uoc_prod.stg_dadesra.dimax_item_dimax.titol, 0, 6) AS assigntura_codi,

    CAST (YEAR(db_uoc_prod.stg_dadesra.dimax_item_dimax.data) AS VARCHAR(4)) ||  
        CASE 
            WHEN MONTH(db_uoc_prod.stg_dadesra.dimax_item_dimax.data) <= 6 
                THEN '1' 
            ELSE '2'
    END AS SEMESTRE, --- revisar 
    -- SUBSTRING(db_uoc_prod.stg_dadesra.dimax_item_dimax.titol, CHARINDEX(':PV', db_uoc_prod.stg_dadesra.dimax_item_dimax.titol)  + 3) AS semester,

    db_uoc_prod.stg_dadesra.dimax_item_dimax.data, 

    'DIMAX' AS font 
    
    FROM db_uoc_prod.stg_dadesra.dimax_resofite_path  
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400
    
    left join db_uoc_prod.stg_dadesra.dimax_v_recurs 
        on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami = db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs -- 17303400 
    
    left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra 
        on db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs = db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.id_recurs -- 17303400


where node_recurs = 30043
 


--- #################################################
select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX
where cami_node like ';3079833;%'



select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX_2 where semestre is null 


select * from DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA
limit 100 

select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO


select * from DB_UOC_PROD.DD_OD.DIM_SEMESTRE









-- Tables dim usadas: 
select DISTINCT CODI_RECURS
FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE


DB_UOC_PROD.DD_OD.dim_semestre semestre
DB_UOC_PROD.stg_dadesra.autors_element_formacio asignatura

-- tablas fact calculo: 
select * --- DISTINCT enllac
FROM DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES_EVENTS


-- tablas fact auxiliares: 
DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_DIMAX
DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO



select distinct id_resource from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES_EVENTS
where  DIM_SEMESTRE_KEY = 20241
and times_used = 0 -- 48,805
-- AND times_used <> 0 -- 8,934




select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES -- 2,907,484

/* 

semestre 
ano 
asignatrua 
material 
num asignaturas diferentes 
asignatruas sin productos? 
asignaturas con todos 
hasta que no tiene primer plan esta a null --> filtrar ?

*/


with as ( 
 STAGE_DADES_ACADEMIQUES_COCO concat 

 STAGE_DADES_ACADEMIQUES_DIMAX  (    
    asignatura
    , semestre_id
    , codi_producto_coco
    , titulo_prod_coco
    ,  PLAN_ESTUDIOS_BASE
    , flag_dimax --> diferenciar 
    )
 ) 

 STAGE_POST_DADES_ACADEMIQUES 


select
    asignatura
    , semestre_id
    , codi_producto_coco
    , titulo_prod_coco
    ,  PLAN_ESTUDIOS_BASE

from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES -- 2.9M
where 1=1 
-- AND asignatura = 'B0.911' 
and  codi_producto_coco = '201344' -- guia --> 
and codi_producto_coco is not null -- no tienen plan de estudios previo  --  2.9M vs  1.9M

order by semestre_id desc 



-- Counts de elementos
select asignatura, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1  order by 2 desc -- 16.6K vs 13.0K  -- 3,600 asignaturas sin ningun recurso asignado 

select semestre_id, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1  order by 1 desc -- 84

select codi_producto_coco, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1 order by 2 desc -- 53.5K  --> pocos

select  PLAN_ESTUDIOS_BASE, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_DADES_ACADEMIQUES_COCO group by 1 order by 2 desc -- 42.0K vs 42.3K --> diferencia elementos --> 

 
select distinct VERSIO_ID   from db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247.4K vs  42.3K



    select  distinct VERSIO_ID 
    
 
    from db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247.4K
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion 
        on plan_publicacion.id =  productos_plan_publicacion.versio_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura 
    on  asignatura.id = plan_publicacion.fk_element_formacio_element_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_producte coco_products 
    on  coco_products.id = productos_plan_publicacion.PRODUCTE_ID 
    
    inner join db_uoc_prod.stg_dadesra.autors_periode semestre  
    on semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID
    
    WHERE  1=1
        AND coco_products.id   IS NOT NULL
        AND coco_products.TITOL   IS NOT NULL


select asignatura, count(* ) from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES

-- valoraciones: 
select ID_asignatura,* 
--- count(* ) 
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES 
where codi_producto_coco is null 
group by 1  -- 16.6K  --> todas tienen? 




select asignatura as teest , * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES 
where codi_producto_coco is null  -- se generan por el crossjoin ?   -- previos a plan de estudios --> no recursos asociados 




-- ##################################################################################
with aux_planes_estudio_base  as ( 
    select  distinct VERSIO_ID  as  PLAN_ESTUDIOS_BASE 
    from db_uoc_prod.stg_dadesra.autors_productes_versions productos_plan_publicacion  -- 247.4K
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_versio plan_publicacion 
        on plan_publicacion.id =  productos_plan_publicacion.versio_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_element_formacio  asignatura 
    on  asignatura.id = plan_publicacion.fk_element_formacio_element_id
    
    inner JOIN Db_uoc_prod.stg_dadesra.autors_producte coco_products 
    on  coco_products.id = productos_plan_publicacion.PRODUCTE_ID 
    
    inner join db_uoc_prod.stg_dadesra.autors_periode semestre  
    on semestre.id = plan_publicacion.FK_PERIODE_PERIODE_ID
    
    WHERE  1=1
        AND coco_products.id   IS NOT NULL
        AND coco_products.TITOL   IS NOT NULL

) 




--#########################################################################################
-- events: 
--#########################################################################################
with auxiliar as ( 
SELECT 

    dades_academiques.DIM_ASSIGNATURA_KEY
    , dades_academiques.DIM_SEMESTRE_KEY
    , dades_academiques.DIM_RECURSOS_APRENENTATGE_KEY
    , dades_academiques.ID_RESOURCE
    , dades_academiques.TITOL_RESOURCE 
    , dades_academiques. PLAN_ESTUDIOS_BASE
    , dades_academiques.ORIGEN_DADES_ACADEMIQUES

    , coalesce(events.TIMES_USED, 0) as TIMES_USED
    , events.SOURCE

FROM  DB_UOC_PROD.DDP_DOCENCIA.STAGE_POST_DADES_ACADEMIQUES dades_academiques -- 7,888,532

left join DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_TRANSFORMED events   -- 4 ultimos anos : 8,741,384 vs 123,019 --> datos by semestre, asignatura, producto grouped
    on dades_academiques.DIM_ASSIGNATURA_KEY = events.DIM_ASSIGNATURA_KEY -- 114,821,250
    AND dades_academiques.DIM_SEMESTRE_KEY = events.DIM_SEMESTRE_KEY
    AND dades_academiques.ID_RESOURCE = events.ID_RESOURCE -- 43k 


) 

select * from auxiliar
-- order by DIM_SEMESTRE_KEY desc 
where  1=1
-- AND Origen_events is not null
-- AND DIM_ASSIGNATURA_KEY is not null  -- 35,313


-- left join : 7,890,407
-- inner join : 35,313 
-- right join : 1,126,400
-- left join  with not null :  35,313 


--#########################################################################################
-- events: 
--#########################################################################################

-- SELECT * FROM  DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED;  -- 8,741,384
-- drop table DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED


select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED  -- 8,741,384 vs 123,019

select * from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_TRANSFORMED  -- 123,019




--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- check con asignatura 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select  distinct dim_assignatura_key

-- ,  * 
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_TRANSFORMED   -- 22
where dim_assignatura_key  not in (


select distinct dim_assignatura_key from DB_UOC_PROD.DD_OD.DIM_ASSIGNATURA  -- 17,894K -- 2 ASIGANTURAS NO APARECEN

 

)

/*
asignaturas no encontradas en events_flattened_transformed:
99.807 
KK.RRR

*/

select  distinct dim_assignatura_key
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_TRANSFORMED   -- 22
where dim_assignatura_key  not in (

SELECT DISTINCT asignatura.codi_final FROM    db_uoc_prod.stg_dadesra.autors_element_formacio asignatura  -- USANDO TABLA BASE : NO PERDEMOS NINGUAN ASITGANTURA --> PROBLEMAS DIM_ASIGNATURA AL CREAR 

)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- check con RECURSOS 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select  distinct ID_RESOURCE 
-- dim_assignatura_key

-- ,  * 
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_TRANSFORMED   -- 22
where ID_RESOURCE  not in (


select DISTINCT CODI_RECURS from DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_APRENENTATGE  -- 213,106 VS  204,131 ( 9K DUPLIKATES)

)

/*
ID_RESOURCE no encontradas en events_flattened_transformed:
296708
291878
305213
273333
296716
302378
298156
298155
122899
305233
297825
302376
291877

*/
SELECT * 
from DB_UOC_PROD.DDP_DOCENCIA.STAGE_LIVE_EVENTS_FLATENED_TRANSFORMED -- 20 PRODUCTOS NO APARECEN 
where ID_RESOURCE  in (
    -- SON PRODUCTOS MUY NUEVOS 202401 / 2023
'296708',
'291878',
'305213',
'273333',
'296716',
'302378',
'298156',
'298155',
'122899',
'305233',
'297825',
'302376',
'291877'

)
-- CHECKEAMOS TABLA COCO 
SELECT * FROM DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS 

where CODI_RECURS  in (
-- ELEMENTOS DE COOCO --> SOLO 2 --> NIU 
'305213',
'305213', 
-- ANADO EL RESTO : NONE 
'296708',
'291878',
'305213',
'273333',
'296716',
'302378',
'298156',
'298155',
'122899',
'305233',
'297825',
'302376',
'291877'
)

-- VMEMOS TABLAS ORIGEN 
SELECT * 
FROM db_uoc_prod.stg_dadesra.autors_producte  autors_producte
WHERE autors_producte.id  in (
-- ELEMENTOS DE COOCO --> SOLO 2 --> NIU 
'305213',
'305213', 
-- ANADO EL RESTO : NONE 
'296708',
'305213',
'296716',
'302378',
'122899',
'305233',
'302376',


-- APARECEN SOLO  DE NIU : 
'273333',
'298156',
'297825',
'298155',
'291878',
'291877'
)
 

/**

*/



-- VMEMOS TABLAS ORIGEN : INNER JOIN CAT --> ELMINA LOS RECURSOS 
SELECT * 
FROM db_uoc_prod.stg_dadesra.autors_producte  autors_producte

        inner join db_uoc_prod.stg_dadesra.autors_suport_producte_i18n
            on autors_producte.fk_suport_producte_suport_id = autors_suport_producte_i18n.fk_suport_producte_suport_id
            AND autors_suport_producte_i18n.idioma = 'CAT'
WHERE autors_producte.id  in (
-- ELEMENTOS DE COOCO --> SOLO 2 --> NIU 
'305213',
'305213', 
-- ANADO EL RESTO : NONE 
'296708',
'305213',
'296716',
'302378',
'122899',
'305233',
'302376',


-- APARECEN SOLO  DE NIU : 
'273333',
'298156',
'297825',
'298155',
'291878',
'291877'
)
 

/**
CHECKEAMOS CON DIMAX 

*/



-- VMEMOS TABLAS ORIGEN : INNER JOIN CAT --> ELMINA LOS RECURSOS 
SELECT * 
FROM db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax  
WHERE CODI_RECURS  in (
-- ELEMENTOS DE COOCO --> SOLO 2 --> NIU 
'305213',
'305213', 
-- ANADO EL RESTO : NONE 
'296708',
'305213',
'296716',
'302378',
'122899',
'305233',
'302376',


-- APARECEN SOLO  DE NIU --> COCO : 
'273333',
'298156',
'297825',
'298155',
'291878',
'291877'
)


/*
TABLA ORIGEN CREACION : from db_uoc_prod.stg_dadesra.dimax_v_recurs -- ACABA EN :   db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax  
dimax_v_recurs.id_recurs as CODI_RECURS,
*/

-- VMEMNOOS TABLAS ORIGEN : INNER JOIN CAT --> ELMINA LOS RECURSOS 
WITH aux_cte_table AS (
SELECT  dimax_v_recurs.id_recurs as CODI_RECURS, * 
from db_uoc_prod.stg_dadesra.dimax_v_recurs 
)
SELECT DISTINCT CODI_RECURS FROM aux_cte_table  -- -101,871 k --> SE GENERAN DUPLICACIONS? 



SELECT * 
FROM db_uoc_prod.stg_dadesra.dimax_v_recurs -- SOLO APARECE 
WHERE id_recurs  in (
-- ELEMENTOS DE COOCO --> SOLO 2 --> NIU 
'305213',
'305213', 
-- ANADO EL RESTO : NONE 
'296708',
'305213',
'296716',
'302378',
'122899',
'305233',
'302376',

'122899', ---> DIMAX --> PERDEMOS CON LOS WHERES EN LAS TABLAS INTERMEDIAS 
-- APARECEN SOLO  DE NIU --> COCO : 
'273333',
'298156',
'297825',
'298155',
'291878',
'291877'
)














    select   
        db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs,  
        db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami, 
        count(*)
        -- db_uoc_prod.stg_dadesra.dimax_resofite_path.id_resource,
        -- db_uoc_prod.stg_dadesra.dimax_resofite_path.ordre,
    from db_uoc_prod.stg_dadesra.dimax_resofite_path  -- 18,056,913 vs 12,349,852
group by 1,2 
order by 3  desc 