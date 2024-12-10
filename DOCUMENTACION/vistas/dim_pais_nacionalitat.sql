CREATE OR REPLACE view DB_UOC_PROD.DD_OD.DIM_PAIS_NACIONALITAT(
	ID_PAIS_NACIONALITAT,
	CONTINENT,
	REGIO,
	NACIONALITAT,
	COD_PAIS_ISO,
	DATA_BAIXA_PAIS,
	PAIS_CONVENI_HAIA,
	PAIS_ESPAI_SEPA,
	PAIS_DIV_TERRITORIAL
) COMMENT='Dimensió nacionalitat. Es tracta d''una vista creada mitjançant la dim país residència i la taula de gat tercers_paisos per tenir la descripció nacionalitat associada al país'
 AS 
SELECT distinct min(id_pais_residencia) AS id_pais_nacionalitat,
                continent, 
                regio, 
                case when tp.desc_nacionalidad is null then 'ND'
                     ELSE tp.desc_nacionalidad END AS Nacionalitat,
                cod_pais_iso,
                data_baixa_pais,
                pais_conveni_haia,
                pais_espai_sepa,
                pais_div_territorial
FROM DB_UOC_PROD.DD_OD.dim_pais_residencia dpr
left join db_uoc_prod.stg_mat.tercers_paises AS tp on dpr.pais = tp.descripcion
group by        continent, 
                regio, 
                nacionalitat,
                cod_pais_iso,
                data_baixa_pais,
                pais_conveni_haia,
                pais_espai_sepa,
                pais_div_territorial;