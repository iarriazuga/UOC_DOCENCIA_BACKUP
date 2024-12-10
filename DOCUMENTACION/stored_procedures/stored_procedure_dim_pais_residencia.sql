-- Creacio de la sequencia que donara peu a identificador unic de la taula.

CREATE OR REPLACE sequence db_uoc_prod.dd_od.sequencia_id_pais_residencia start 1 increment 1;

-- Creació de la taula dim_residencia amb els atributs definists

CREATE OR REPLACE table db_uoc_prod.dd_od.dim_pais_residencia
(id_pais_residencia number(16) not null comment 'Clau unica i numerica que identifica els registres de la dimensio residencia'
 ,continent varchar(254) not null comment 'Continent al que pertany el pais. Els paisos amb ND son paisos o que no son propiament paisos, no estan reconeguts o ja no existeixen'
,regio varchar(254) not null COMMENT 'regio al que pertany el pais. Els paisos amb ND son paisos o que no son propiament paisos, no estan reconeguts o ja no existeixen'
,cat_esp_resta varchar (15) not null comment 'Residencia clasificada en catalunya, resta espanya y resta mon'
,cat_esp_continent_reg varchar (20) comment 'Residencia clasificada en Catalunya,	Espanya, Europa, Llatinoamèrica, Nordamèrica, Àfrica, Àsia, Oceania'
--cod_pais varchar(3) not null comment 'Codi UOC pais. Segons el país, té un tipus de nomenclatura ISO o un altre.'
,pais varchar(256) not null comment 'Literal del país associat al codi UOC'
,cod_pais_iso varchar (3)  comment 'Codi ISO asociat al pais'
,data_baixa_pais timestamp_ntz comment 'Data on es va donar de baixa el país'
,pais_conveni_haia varchar (2) not null comment 'Identifica si el país pertany al conveni de la Haia'
,pais_espai_sepa varchar (2) not null comment 'Identifica si el país pertany al espai sepa'
,pais_div_territorial number(2)  not null comment 'Divisió territorial a la qual pertany el país'
,comunitat_autonoma varchar (256) comment 'Té informat la comunitat autònoma si el país és Espanya'
--,cod_comunitat number (2) comment 'Te informat el codi de la comunitat autònoma si el país és Espanya'
,provincia varchar (256) comment 'Te informat la provincia si el país és Espanya'
--,cod_provincia number(2) comment 'Te informat el codi de provincia si el país és Espanya'
,comarca varchar (256) comment 'Te informat la comarca si el país és Espanya'
--,cod_comarca number(2) comment 'Te informat el codi de comarca si el país és Espanya'
,poblacio varchar (256) comment 'Te informat la població si el país és Espanya'
--,cod_poblacio number(6) comment 'Te informat el codi de poblacio si el país és Espanya'
,cod_poblacio_mec VARCHAR(8) comment 'Te informat el codi de població mec si el pais es Espanya. Es el codi amb el que treballa el INE'
,cod_postal varchar (5) comment 'Te informat el codi postal si el país es Espanya. Un CP pot pertànyer a diferents poblacions'
,ind_localitzacio number (4) comment 'Te informat el codi localització asociat a un codi postal si el país es espanya. La combinació de CP i ind_localització es unica'
,localizacio varchar (256) comment 'Te informat la localització si el país es Espanya'
,data_baixa_localitzacio timestamp_ntz comment 'Te informat la data  en que una localització es va donar de baixa si el país es Espanya'
,data_modifica_localitzacio timestamp_ntz comment 'Te informat la data en que una localització vaser modificara si el país es Espanya'
,creation_date timestamp_ntz not null comment 'Data de creacio del registre de la informacio'
,update_date timestamp_ntz not null comment 'Data de carrega de la informacio'
) comment='Taula que conte la informacio rellevant de les residencies per a qualsevol equip de disponibilització'
;

SELECT * FROM db_uoc_prod.dd_od.dim_pais_residencia;



--------------------------------
--------------------------------

-- Creacio del procediment de carrega i/o actualització de dades programable

CREATE OR REPLACE procedure db_uoc_prod.dd_od.dim_pais_residencia_loads()
returns varchar(16777216)
language SQL
execute AS caller
as 
begin
let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
let execution_time float;

-- Carga del registre 0
merge into db_uoc_prod.dd_od.dim_pais_residencia
using (SELECT  0 AS id_pais_residencia,'ND' AS continent, 'ND' AS regio,  'ND' AS cat_esp_resta, 'ND' AS cat_esp_continent_reg, 'ND' AS pais, 'ND' AS cod_pais_iso ,NULL AS data_baixa_pais, 'ND' AS pais_conveni_haia, 'ND' AS pais_espai_sepa, 0 AS pais_div_territorial, 'ND' AS comunitat_autonoma, 'ND' AS provincia,'ND' AS comarca, 'ND' AS poblacio, 0 AS cod_poblacio_mec, 0 AS cod_postal, 0 AS ind_localitzacio, 'ND' AS localitzacio, NULL AS data_baixa_localitzacio, NULL AS data_modifica_localitzacio, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date) AS dim_residencia_repl
on db_uoc_prod.dd_od.dim_pais_residencia.id_pais_residencia = dim_residencia_repl.id_pais_residencia -- No entiendo lo que hace aqui
when matched 
then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched
then insert (ID_PAIS_RESIDENCIA, CONTINENT, REGIO, CAT_ESP_RESTA,CAT_ESP_CONTINENT_REG, PAIS,COD_PAIS_ISO, DATA_BAIXA_PAIS, PAIS_CONVENI_HAIA, PAIS_ESPAI_SEPA, PAIS_DIV_TERRITORIAL, COMUNITAT_AUTONOMA, PROVINCIA, COMARCA, POBLACIO, COD_POBLACIO_MEC, COD_POSTAL, IND_LOCALITZACIO, LOCALIZACIO, DATA_BAIXA_LOCALITZACIO, DATA_MODIFICA_LOCALITZACIO, CREATION_DATE, UPDATE_DATE)
values (0 , 'ND', 'ND','ND', 'ND','ND' , 'ND' ,NULL , 'ND', 'ND' , 0 , 'ND' , 'ND' ,'ND' , 'ND' , 0 , 0 , 0 , 'ND' , NULL , NULL , convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz),  convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

--Actualizació dades
merge into db_uoc_prod.dd_od.dim_pais_residencia
using (SELECT case when EPC.CONTINENT is not null then EPC.CONTINENT 
            when EPC.CONTINENT is null then 'ND' END AS CONTINENT,
       case when  EPC.REGIO is not null then  EPC.REGIO 
            when EPC.REGIO is null then 'ND' END AS REGIO,
       case when  ccaa = 'Catalunya' then 'Catalunya'
            when ccaa <> 'Catalunya' AND tp.descripcion = 'Espanya' then 'Resta Espanya'
            ELSE 'Resta mon' end AS CAT_ESP_RESTA,
        CASE
    -- Primera condición: Si es Europa y Catalunya
        WHEN CONTINENT = 'Europa' AND CAT_ESP_RESTA = 'Catalunya' THEN 'Catalunya'
    -- Segunda condición: Si es Europa y Resta Espanya
        WHEN CONTINENT = 'Europa' AND CAT_ESP_RESTA = 'Resta Espanya' THEN 'Espanya'
    -- Tercera condición: Si es Europa pero no Catalunya ni Resta Espanya
        WHEN CONTINENT = 'Europa' AND CAT_ESP_RESTA <> 'Catalunya' AND CAT_ESP_RESTA <> 'Resta Espanya' THEN 'Europa'
    -- Condiciones para otros continentes
        WHEN CONTINENT = 'Àfrica' THEN 'Àfrica'
        WHEN CONTINENT = 'Àsia' THEN 'Àsia'
        WHEN CONTINENT = 'Oceania' THEN 'Oceania'
    -- Condición para América del Norte
        WHEN CONTINENT = 'Amèrica' AND REGIO = 'Amèrica del nord' THEN 'Nordamèrica'
    -- Condición para Latinoamérica
        WHEN CONTINENT = 'Amèrica' AND REGIO <> 'Amèrica del nord' THEN 'Llatinoamèrica'
    -- Valor por defecto si no se cumple ninguna condición
        ELSE 'Desconegut' END AS CAT_ESP_CONTINENT_REG,
       tp.descripcion AS pais,
       tp.cod_pais,
       tp.cod_pais_iso_3166_a3 AS ISO,
       tp.fecha_baja AS baja_pais,
       tp.ind_convenio_la_haya AS pais_convenio_haya,
       tp.ind_espacio_sepa AS pais_espacio_sepa,
       tp.cod_div_territorial AS pais_div_territorial,
       geografia_espanya.cod_pais,
       geografia_espanya.ccaa,
       geografia_espanya.provincia,
       geografia_espanya.comarca,
       geografia_espanya.poblacio,
       geografia_espanya.cod_mec,
       case when geografia_espanya.cod_postal is null then '99999'
            else geografia_espanya.cod_postal end AS cod_postal,
       case when geografia_espanya.ind_localitzacio is null then 0
            else geografia_espanya.ind_localitzacio end AS ind_localitzacio,
       case when geografia_espanya.localitzacio is null then 'ND'
            else geografia_espanya.localitzacio end AS localitzacio,
       geografia_espanya.baja_localitzacio,
       geografia_espanya.modifica_localitzacio,
FROM DB_UOC_PROD.STG_MAT.TERCERS_PAISES AS tp
left join (SELECT 'E' AS cod_pais,
       tc.descripcion AS ccaa,
       tpr.descripcion AS provincia,
       tco.descripcion AS comarca,
       tp.desc_poblacion AS poblacio, 
       LPAD(tp.cod_poblacion_mec, 5, 0) AS cod_mec,
       tcp.cod_postal,
       tcp.ind_localizacion AS ind_localitzacio,
       tcp.desc_localizacion AS localitzacio,
       tcp.fecha_baja AS baja_localitzacio,
       tcp.fecha_modificacion AS modifica_localitzacio
FROM DB_UOC_PROD.STG_DOCENCIA.TERCERS_CODIGOS_POSTALES AS tcp
INNER JOIN DB_UOC_PROD.STG_DOCENCIA.TERCERS_POBLACIONES AS tp on tcp.cod_poblacion = tp.cod_poblacion 
inner join DB_UOC_PROD.STG_DOCENCIA.TERCERS_PROVINCIAS AS tpr on tp.cod_provincia = tpr.cod_provincia
inner join DB_UOC_PROD.STG_DOCENCIA.TERCERS_COMUNIDADES AS tc on tp.cod_comunidad = tc.cod_comunidad
inner join DB_UOC_PROD.STG_UNEIX.TERCERS_COMARCAS AS tco on tp.cod_comarca = tco.cod_comarca AND tp.cod_comunidad = tco.cod_comunidad where cod_postal = '99999'
) AS geografia_espanya
on geografia_espanya.cod_pais = tp.cod_pais
LEFT JOIN DB_UOC_PROD.DD_OD.EQUIVALENCIES_PAISOS_CONTINENTS AS epc
on tp.cod_pais_iso_3166_a3 = epc.CODI_ISO OR tp.descripcion = epc.pais) AS origen -- hasta aqui la query origen que llenara la dim
on ifnull(origen.cod_postal, '') = ifnull(db_uoc_prod.dd_od.dim_pais_residencia.cod_postal,'') AND 
   ifnull(origen.ind_localitzacio, '0') = ifnull(db_uoc_prod.dd_od.dim_pais_residencia.ind_localitzacio, '0') AND --es 0 y no '' por que es un campo numerico
   origen.pais = db_uoc_prod.dd_od.dim_pais_residencia.pais
when matched
then update set CONTINENT =origen.continent, REGIO = origen.regio, CAT_ESP_RESTA = origen.cat_esp_resta, CAT_ESP_CONTINENT_REG =origen.cat_esp_continent_reg, PAIS = origen.pais, COD_PAIS_ISO = origen.iso, DATA_BAIXA_PAIS = origen.baja_pais, PAIS_CONVENI_HAIA = origen.pais_convenio_haya , PAIS_ESPAI_SEPA = origen.pais_espacio_sepa, PAIS_DIV_TERRITORIAL = origen.pais_div_territorial, COMUNITAT_AUTONOMA =origen.ccaa, PROVINCIA = origen.provincia, COMARCA = origen.comarca, POBLACIO = origen.poblacio, COD_POBLACIO_MEC = origen.cod_mec, COD_POSTAL = origen.cod_postal, IND_LOCALITZACIO = origen.ind_localitzacio, LOCALIZACIO =  origen.localitzacio, DATA_BAIXA_LOCALITZACIO = origen.baja_localitzacio, DATA_MODIFICA_LOCALITZACIO = origen.modifica_localitzacio,  UPDATE_DATE = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)                
when not matched
then insert (ID_pais_RESIDENCIA,CONTINENT, REGIO, CAT_ESP_RESTA, CAT_ESP_CONTINENT_REG,  PAIS, COD_PAIS_ISO, DATA_BAIXA_PAIS, PAIS_CONVENI_HAIA, PAIS_ESPAI_SEPA, PAIS_DIV_TERRITORIAL, COMUNITAT_AUTONOMA, PROVINCIA, COMARCA, POBLACIO, COD_POBLACIO_MEC, COD_POSTAL, IND_LOCALITZACIO, LOCALIZACIO, DATA_BAIXA_LOCALITZACIO, DATA_MODIFICA_LOCALITZACIO, CREATION_DATE, UPDATE_DATE)
values(db_uoc_prod.dd_od.sequencia_id_pais_residencia.nextval, origen.continent, origen.regio,origen.cat_esp_resta,origen.cat_esp_continent_reg, origen.pais,origen.iso, origen.baja_pais, origen.pais_convenio_haya, origen.pais_espacio_sepa, origen.pais_div_territorial, origen.ccaa, origen.provincia, origen.comarca, origen.poblacio, origen.cod_mec, origen.cod_postal, origen.ind_localitzacio, origen.localitzacio, origen.baja_localitzacio, origen.modifica_localitzacio, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz),  convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));


/*delete FROM db_uoc_prod.dd_od.dim_pais_residencia
where cod_postal = '99999' AND IND_LOCALITZACIO = '0' AND Pais = 'Espanya'*/;

execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'dim_pais_residencia_loads', CURRENT_USER(), :start_time, :execution_time, 'dim_pais_residencia Success');
    
return 'Update completed successfully';

end
;

-- Comanda per executar el procediment enmagatzemat al entorn.
 call db_uoc_prod.dd_od.dim_pais_residencia_loads();



/*
-- Paises de lso que dispongo de info, pero no estan reconocidos por la onu como paises

SELECT case when EPC.CONTINENT is not null then EPC.CONTINENT 
            when EPC.CONTINENT is null then 'ND' END AS CONTINENT,
       case when  EPC.REGIO is not null then  EPC.REGIO 
            when EPC.REGIO is null then 'ND' END AS REGIO,
       case when  ccaa = 'Catalunya' then 'Catalunya'
            when ccaa <> 'Catalunya' AND tp.descripcion = 'Espanya' then 'Resta Espanya'
            ELSE 'Resta mon' end AS CAT_ESP_RESTA,
       tp.descripcion AS pais,
       tp.cod_pais,
       tp.cod_pais_iso_3166_a3 AS ISO,
       tp.fecha_baja AS baja_pais,
       tp.ind_convenio_la_haya AS pais_convenio_haya,
       tp.ind_espacio_sepa AS pais_espacio_sepa,
       tp.cod_div_territorial AS pais_div_territorial,
       geografia_espanya.*
FROM DB_UOC_PROD.STG_MAT.TERCERS_PAISES AS tp
left join (SELECT 'E' AS cod_pais,
       tc.descripcion AS ccaa,
       tpr.descripcion AS provincia,
       tco.descripcion AS comarca,
       tp.desc_poblacion AS poblacion, 
       tp.cod_poblacion_mec,
       tcp.cod_postal,
       tcp.ind_localizacion,
       tcp.desc_localizacion AS localizacion,
       tcp.fecha_baja AS baja_localizacion,
       tcp.fecha_modificacion AS modifica_localizacion
FROM DB_UOC_PROD.STG_DOCENCIA.TERCERS_CODIGOS_POSTALES AS tcp
INNER JOIN DB_UOC_PROD.STG_DOCENCIA.TERCERS_POBLACIONES AS tp on tcp.cod_poblacion = tp.cod_poblacion 
inner join DB_UOC_PROD.STG_DOCENCIA.TERCERS_PROVINCIAS AS tpr on tp.cod_provincia = tpr.cod_provincia
inner join DB_UOC_PROD.STG_DOCENCIA.TERCERS_COMUNIDADES AS tc on tp.cod_comunidad = tc.cod_comunidad
inner join DB_UOC_PROD.STG_UNEIX.TERCERS_COMARCAS AS tco on tp.cod_comarca = tco.cod_comarca AND tp.cod_comunidad = tco.cod_comunidad
) AS geografia_espanya
on geografia_espanya.cod_pais = tp.cod_pais
LEFT JOIN DB_UOC_PROD.DD_OD.EQUIVALENCIES_PAISOS_CONTINENTS AS epc
on tp.cod_pais_iso_3166_a3 = epc.CODI_ISO OR tp.descripcion = epc.pais
WHERE EPC.CONTINENT is null AND tp.cod_pais  in (
SELECT cod_pais
FROM DB_UOC_PROD.stg_mat.tercers_direcciones
)
;
*/

---






