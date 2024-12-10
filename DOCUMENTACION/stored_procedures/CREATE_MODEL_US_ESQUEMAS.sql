CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.CREATE_MODEL_US_ESQUEMAS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin

-------------------CREAMOS UNA VISTA PARA TRABAJAR TABLA DE HECHOS Y DIMENSIONES----------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


create or replace view db_uoc_prod.dd_od.v_dims_fact_usos_disc as (
select ''DISC'' as ESQUEMA,
       ID, -- id
       QS_ID,  -- id
       upper (QS_DOC_OWNER) as D1_qs_doc_owner_u,-- DIM 1
       QS_CREATED_BY as D1_QS_CREATED_BY, -- DIM 1
       QS_DOC_NAME AS D2_QS_DOC_NAME, --DIM 2
       QS_DOC_DETAILS AS D2_QS_DOC_DETAILS, --Dim 2
       DOC_CREATED_BY AS D3_DOC_CREATED_BY, -- dim 3
       DOC_UPDATED_BY AS D3_DOC_UPDATED_BY, --di, 3
       QS_ACT_ELAP_TIME, -- f
       QS_EST_ELAP_TIME,  --f
       QS_NUM_ROWS, --f
       QS_CREATED_DATE,-- f
       DOC_CREATED_DATE, --f
       DOC_UPDATED_DATE,--f
       DOC_EU_ID, -- id
       DOC_FOLDER_ID, -- id
       from db_uoc_prod.dd_od.informes_disc
UNION ALL
select ''DISC10'' as ESQUEMA,
       ID, -- id
       QS_ID,  -- id
       upper (QS_DOC_OWNER) as D1_qs_doc_owner_u,-- DIM 1
       QS_CREATED_BY as D1_QS_CREATED_BY, -- DIM 1
       QS_DOC_NAME AS D2_QS_DOC_NAME, --DIM 2
       QS_DOC_DETAILS AS D2_QS_DOC_DETAILS, --Dim 2
       DOC_CREATED_BY AS D3_DOC_CREATED_BY, -- dim 3
       DOC_UPDATED_BY AS D3_DOC_UPDATED_BY, --di, 3
       QS_ACT_ELAP_TIME, -- f
       QS_EST_ELAP_TIME,  --f
       QS_NUM_ROWS, --f
       QS_CREATED_DATE,-- f
       DOC_CREATED_DATE, --f
       DOC_UPDATED_DATE,--f
       DOC_EU_ID, -- id
       DOC_FOLDER_ID, -- id from db_uoc_prod.dd_od.informes_disc10;
from db_uoc_prod.dd_od.informes_disc10     
UNION ALL
select ''DAU'' as ESQUEMA,
       ID, -- id
       QS_ID,  -- id
       upper (QS_DOC_OWNER) as D1_qs_doc_owner_u,-- DIM 1
       QS_CREATED_BY as D1_QS_CREATED_BY, -- DIM 1
       QS_DOC_NAME AS D2_QS_DOC_NAME, --DIM 2
       QS_DOC_DETAILS AS D2_QS_DOC_DETAILS, --Dim 2
       DOC_CREATED_BY AS D3_DOC_CREATED_BY, -- dim 3
       DOC_UPDATED_BY AS D3_DOC_UPDATED_BY, --di, 3
       QS_ACT_ELAP_TIME, -- f
       QS_EST_ELAP_TIME,  --f
       QS_NUM_ROWS, --f
       QS_CREATED_DATE,-- f
       DOC_CREATED_DATE, --f
       DOC_UPDATED_DATE,--f
       DOC_EU_ID, -- id
       DOC_FOLDER_ID, -- id from db_uoc_prod.dd_od.informes_disc10;
from db_uoc_prod.dd_od.informes_DAU);  


-----------------CREAMOS LAS DIMENSIONES------------------------
----------------------------------------------------------------
----------------------------------------------------------------

----------------------------CREATE DIM_ESQUEMA-------------------------------
-- 1. Creamos la tabla
CREATE OR REPLACE TABLE db_uoc_prod.dd_od.DIM_ESQUEMA AS (
WITH D0 as (
select distinct ESQUEMA
FROM db_uoc_prod.dd_od.v_dims_fact_usos_disc)
select row_number() over (order by ESQUEMA) as id,
       *
from D0
);

------------------CREATE DIM_QS_DOC_OWNER_OR_CREATED ---------------------
--1. Creamos la tabla 
CREATE OR REPLACE TABLE  db_uoc_prod.dd_od.DIM_QS_DOC_OWNER AS ( 
with D1 as (
select distinct D1_qs_doc_owner_u 
from db_uoc_prod.dd_od.v_dims_fact_usos_disc
UNION
select distinct D1_QS_CREATED_BY
from db_uoc_prod.dd_od.v_dims_fact_usos_disc)
select ROW_NUMBER() OVER (ORDER BY D1_qs_doc_owner_u) AS id, 
       D1_qs_doc_owner_u  as qs_doc_owner
FROM D1
WHERE qs_doc_owner IS NOT NULL
);
--2. Insertamos el valor 0
INSERT INTO db_uoc_prod.dd_od.DIM_QS_DOC_OWNER (ID, QS_DOC_OWNER)
VALUES (0, ''ND'');
--3. Creamos la vista

create or replace view db_uoc_prod.dd_od.V_DIM_QS_DOC_CREATED AS (
select ID,
       qs_doc_owner AS QS_CREATED_BY 
from db_uoc_prod.dd_od.DIM_QS_DOC_OWNER
);

--------------------------CREATE DIM_INFORMES ---------------------------
--1. Creamos la tabla 
CREATE OR REPLACE TABLE db_uoc_prod.dd_od.DIM_INFORMES AS (
with D2 as (
select distinct 
                D2_QS_DOC_NAME AS  QS_DOC_NAME,
                D2_QS_DOC_DETAILS AS QS_DOC_DETAILS  
FROM db_uoc_prod.dd_od.v_dims_fact_usos_disc) 
select ROW_NUMBER () over (order by QS_DOC_NAME) as id,
       * from D2
where qs_doc_name is not null AND QS_DOC_DETAILS  is not null );
--2.Insertamos el valor 0
INSERT INTO db_uoc_prod.dd_od.DIM_INFORMES
VALUES (0, ''ND'', ''ND'');

------------------CREATE DIM_DOC_CREATED_UPDATED_BY ---------------------
--1. Creamos la tabla       
CREATE OR REPLACE TABLE db_uoc_prod.dd_od.DIM_DOC_CREATED_BY AS (
WITH D3 as (
SELECT DISTINCT D3_DOC_CREATED_BY
FROM db_uoc_prod.dd_od.v_dims_fact_usos_disc
UNION
SELECT DISTINCT D3_DOC_UPDATED_BY 
FROM db_uoc_prod.dd_od.v_dims_fact_usos_disc)
select ROW_NUMBER() OVER (ORDER BY D3_DOC_CREATED_BY) as id,
        D3_DOC_CREATED_BY AS DOC_CREATED_BY
from D3
WHERE DOC_CREATED_BY IS NOT NULL
);

--2. Insertamos el valor 0
INSERT INTO db_uoc_prod.dd_od.DIM_DOC_CREATED_BY
VALUES (0,''ND'');

--3. Creamos la vista

create or replace view db_uoc_prod.dd_od.V_DIM_DOC_UPDATED_BY as (
select ID,
       DOC_CREATED_BY AS DOC_UPDATED_BY
from db_uoc_prod.dd_od.DIM_DOC_CREATED_BY 
);

--------------------CREAMOS LA TABLA DE HECHOS-----------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
create or replace table db_uoc_prod.dd_od.fact_uso_informes as (
with base_consulta as (
SELECT row_number() over (order by dfud.esquema) as id_fact,
       --dfud.id as id_rows_tabla, -- es el id row de cada tabla
      -- dfud.qs_id as id_qs_tabla, -- es el id_qs de cada tabla
       concat(de.id,''-'', dfud.qs_id) as id_esquema_id_qs, -- al añadir esquema, evitas que los qs_id de las tablas (dau,disc) que tienen mismo numero sean identificados como el mismo
       de.id as id_esquema,
       case when dqsdo.id  is not null then dqsdo.id 
            else 0 end as id_qs_doc_owner,
       case when vdqsdo.id  is not null then vdqsdo.id 
            else 0 end as id_qs_created_by, 
       case when di.id is not null then di.id
            else 0 end as id_informes,
       case when ddc.id is not null then ddc.id
            else 0 end as id_doc_created_by,
       case when vddc.id is not null then vddc.id
            else 0 end as id_doc_updated_by,
       case when dd.id_data is not null then dd.id_data
       else 0 end as id_data,
       qs_act_elap_time,
       qs_est_elap_time,
       qs_num_rows,
       qs_created_date,
       doc_created_date,
       DOC_UPDATED_DATE,
       d2_qs_doc_name as doc_name
FROM db_uoc_prod.dd_od.v_dims_fact_usos_disc as dfud
INNER JOIN db_uoc_prod.dd_od.DIM_ESQUEMA as de ON  dfud.esquema = de.esquema 
left join db_uoc_prod.dd_od.DIM_QS_DOC_OWNER as dqsdo on  dfud.d1_qs_doc_owner_u = dqsdo.qs_doc_owner
left join db_uoc_prod.dd_od.V_DIM_QS_DOC_CREATED as vdqsdo on  dfud.d1_qs_created_by = vdqsdo.qs_created_by 
left join db_uoc_prod.dd_od.DIM_INFORMES as di on dfud.d2_qs_doc_name = di.qs_doc_name AND dfud.d2_qs_doc_details = di.qs_doc_details
left join db_uoc_prod.dd_od.DIM_DOC_CREATED_BY as ddc on dfud.d3_doc_created_by = ddc.doc_created_by
left join db_uoc_prod.dd_od.V_DIM_DOC_UPDATED_BY as vddc on dfud.d3_doc_updated_by = vddc.doc_updated_by
left join db_uoc_prod.dd_od.dim_data as dd on to_date (dfud.qs_created_date) = to_date(dd.dim_data_key) -- );
)
select id_fact,
       id_esquema_id_qs,
       id_esquema,
       id_qs_doc_owner,
       id_qs_created_by,
       id_informes,
       id_doc_created_by,
       id_doc_updated_by,
       id_data,
       qs_est_elap_time,
       qs_created_date,
       doc_created_date,
       doc_updated_date,
        dense_rank() over (order by (select count (distinct ID_ESQUEMA_ID_QS)
        from base_consulta as  bc_sub
        where base_consulta.doc_name = bc_sub.doc_name) desc) as rank_informes
from base_consulta);



--------------------BORRAMOS LA VISTA--------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------


Drop view db_uoc_prod.dd_od.v_dims_fact_usos_disc;
return ''Created successfully'';

end';