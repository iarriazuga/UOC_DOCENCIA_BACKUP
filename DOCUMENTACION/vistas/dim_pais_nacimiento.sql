CREATE OR REPLACE view DB_UOC_PROD.DD_OD.DIM_PAIS_NACIM(
	ID_PAIS_NAIXEMENT,
	CONTINENT,
	REGIO,
	PAIS,
	CODI_PAIS_ISO,
	DATA_BAIXA_PAIS,
	PAIS_CONVENI_HAIA,
	PAIS_ESPAI_SEPA,
	PAIS_DIV_TERRITORIAL
) COMMENT='Dimensió pais naixement es tracta d''una vista de la dim_pais_residencia'
 as
SELECT distinct min(id_pais_residencia) AS id_pais_naixement,
                continent, 
                regio, 
                pais,
                cod_pais_iso,
                data_baixa_pais,
                pais_conveni_haia,
                pais_espai_sepa,
                pais_div_territorial
FROM DB_UOC_PROD.DD_OD.dim_pais_residencia
group by        continent, 
                regio, 
                pais,
                cod_pais_iso,
                data_baixa_pais,
                pais_conveni_haia,
                pais_espai_sepa,
                pais_div_territorial;