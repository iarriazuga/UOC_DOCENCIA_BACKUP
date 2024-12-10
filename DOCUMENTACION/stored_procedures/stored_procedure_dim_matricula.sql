/* 
 Jesus Llenas Puigdemont 
 jllenasp@uoc.edu

 COMENTARIS:
- Abans s agafaven nomes matricules de GR, MU i FP de GAT, ara he agafat tot i aixi sabrem quin abast real te.
- En les matricules de FP hi havia un parche que filtraba certes matricules d un descompte concret, s ha tret i ara apareixen.
- desc_tipo_matricula hauria d haver un camp a la FACT amb un row_number o una taula de expediente traza. Si una primera matricula esta anul.lada, la seguent que es?
- opcio_acc i via_acc  s agafa del numero de solicitud d acces que esta al expedient, hauria d estar a la Dim_expedient
- GAT_EXP_MATRICULAS.num_matricula no esta a piolin

 PETICIONS:
- GAT/GATIB (Divisio)
*/

-- Creacio de la taula dim_matricula amb els atributs particulars.

CREATE OR REPLACE TABLE db_uoc_prod.DB_UOC_PROD.DD_OD.DIM_MATRICULA_LOADS.dim_matricula (
  id_matricula NUMBER(16) NOT NULL AUTOINCREMENT START 1 INCREMENT 1 COMMENT 'Clau unica i numerica que identifica els registres de la dimensio matricula',
  dim_matricula_key NUMBER(16) NOT NULL COMMENT 'Codi unic de matricula: Piolin -> num_matricula  Gat -> CONCAT(em.num_expediente, em.any_academico, em.num_matricula)',
  origen VARCHAR(6) NOT NULL COMMENT 'GAT/PIOLIN',
  data_matricula TIMESTAMP_NTZ(9) NOT NULL COMMENT 'Data en la que s ha consolidat una matricula. En cas que una matricula s anul.li i es reactivi, la data matricula sera l original',
  data_anulacio TIMESTAMP_NTZ(9) NULL COMMENT 'Data en la que s anul.la una matricula',
  cod_motiu_anulacio VARCHAR(8) NULL COMMENT 'Indica el codi d anul.lacio de la matricula', 
  cod_categoritzacio VARCHAR(64) NULL COMMENT 'Identificador del codi de categoritzacio de la matricula', 
  des_categoritzacio VARCHAR(254) NULL COMMENT 'Descripcio del codi de categoritzacio de la matricula', 
  des_entitat VARCHAR(128) NULL COMMENT '',
  des_distribuidor VARCHAR(128) NULL COMMENT '',
  creation_date TIMESTAMP_NTZ NOT NULL COMMENT 'Data de creacio del registre de la informacio', 
  update_date TIMESTAMP_NTZ NOT NULL COMMENT 'Data de carrega de la informacio'
) 
COMMENT='Taula que conte la informacio rellevant de les matricules per a qualsevol projecte de disponibilitzacio';

-- Creacio del procediment de carrega i/o actualització de dades programable
-- CALL db_uoc_prod.dd_od.dim_matricula_loads();

CREATE OR REPLACE PROCEDURE db_uoc_prod.dd_od.dim_matricula_loads()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 

BEGIN
  LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ);
  LET execution_time FLOAT;
 
  -- Proces que incorpora el registre 0 a la dimensio.
  MERGE INTO db_uoc_prod.dd_od.dim_matricula AS target
  USING (SELECT 0 AS id_matricula, 
                0 AS dim_matricula_key, 
                'ND' AS origen, 
                '1900-01-01 00:00:00.000'::TIMESTAMP_NTZ AS data_matricula, 
                '1900-01-01 00:00:00.000'::TIMESTAMP_NTZ AS data_anulacio, 
                '-' AS cod_motiu_anulacio, 
                'ND' AS cod_categoritzacio, 
                'ND' AS des_categoritzacio, 
                'ND' AS des_entitat, 
                'ND' AS des_distribuidor, 
                CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ) AS creation_date,
                CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ) AS update_date) AS source
  ON target.id_matricula = source.id_matricula
  WHEN MATCHED THEN 
    UPDATE SET update_date = CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
  WHEN NOT MATCHED THEN 
    INSERT (id_matricula, dim_matricula_key, origen, data_matricula, data_anulacio, cod_motiu_anulacio, cod_categoritzacio, des_categoritzacio, des_entitat, des_distribuidor, creation_date, update_date)
    VALUES (source.id_matricula, source.dim_matricula_key, source.origen, source.data_matricula, source.data_anulacio, source.cod_motiu_anulacio, source.cod_categoritzacio, source.des_categoritzacio, source.des_entitat, source.des_distribuidor, source.creation_date, source.update_date);

  -- Merge de les matricules de GAT i PIOLIN
  MERGE INTO db_uoc_prod.dd_od.dim_matricula AS target
  USING (
    SELECT 
      CONCAT(TO_VARCHAR(em.num_expediente), TO_VARCHAR(em.any_academico), TO_VARCHAR(em.num_matricula)) AS dim_matricula_key,
      'GAT' AS origen, 
      em.fecha_matricula AS data_matricula,
      em.fecha_anulacion AS data_anulacio,
      CASE WHEN em.fecha_anulacion IS NOT NULL THEN sam.cod_moti_anulacion ELSE NULL END AS cod_motiu_anulacio, 
      exc.codigo_categoriza AS cod_categoritzacio,
      exc.descripcion AS des_categoritzacio,
      exc.nombre_entidad AS des_entitat,
      distr.descripcio AS des_distribuidor
    FROM STG_MAT.GAT_EXP_MATRICULAS em
    LEFT JOIN STG_MAT.gat_exp_matriculas_categmat exc ON em.num_expediente = exc.num_expediente AND em.any_academico = exc.any_academico AND em.num_matricula = exc.num_matricula
    LEFT JOIN (
      SELECT cod_moti_anulacion, num_expediente, any_academico, num_matricula, 
             ROW_NUMBER() OVER (PARTITION BY num_expediente, any_academico, num_matricula ORDER BY fecha_solicitud DESC) AS n_anul
      FROM STG_MAT.GAT_SOL_ANULA_MAT
    ) sam ON em.num_expediente = sam.num_expediente AND em.fecha_anulacion IS NOT NULL AND em.any_academico = sam.any_academico AND em.num_matricula = sam.num_matricula AND sam.n_anul = 1
    LEFT JOIN (
      SELECT cat.codi_categoritzacio, distr0.descripcio
      FROM STG_MAT.gat_categoritzacions cat
      LEFT JOIN STG_MAT.gat_distribuidors distr0 ON distr0.seq_distribuidor = cat.seq_distribuidor AND distr0.seq_distribuidor NOT IN (1,4,3,8)
    ) distr ON distr.codi_categoritzacio = exc.codigo_categoriza

/*  UNION ALL 
    
    SELECT 
      TO_VARCHAR(ma.num_matricula) AS dim_matricula_key,
      'PIOLIN' AS origen, 
      ma.fecha_matricula AS data_matricula,
      ma.fecha_anulacion AS data_anulacio,
      CASE WHEN em.fecha_anulacion IS NOT NULL THEN sam.cod_motiu_anulacion ELSE NULL END AS cod_motiu_anulacio,
      mc.codigo_categoriza AS cod_categoritzacio,
      mc.descripcion AS des_categoritzacio,
      mc.nombre_entidad AS des_entitat,
      distr.descripcio AS des_distribuidor
    FROM STG_MAT.epiolini_matriculas ma
    LEFT JOIN STG_MAT.epiolini_matriculas_categoriza mc ON ma.num_matricula = mc.num_matricula
    LEFT JOIN (
      SELECT cat.codi_categoritzacio, distr0.descripcio
      FROM STG_MAT.gat_categoritzacions cat
      LEFT JOIN STG_MAT.gat_distribuidors distr0 ON distr0.seq_distribuidor = cat.seq_distribuidor AND distr0.seq_distribuidor NOT IN (1,4,3,8)
    ) distr ON distr.codi_categoritzacio = mc.codigo_categoriza
    LEFT JOIN (
      SELECT rs.IDENTIFICADOR_SERVICIO, rs.IDP, csce.MOTIVO_ANUL
      FROM STG_MAT.epiolini_registro_servicios rs
      LEFT JOIN STG_MAT.epiolini_concepto_servicios csce ON csce.cod_cliente != rs.idp AND csce.any_servicio = rs.any_servicio AND csce.num_reg_servicio = rs.num_reg_servicio AND csce.num_concepto = rs.ult_reg_concepto
    ) serv ON serv.idp = ma.idp AND serv.identificador_servicio = ma.num_matricula
*/  ) AS source
  ON target.dim_matricula_key = source.dim_matricula_key
  WHEN MATCHED THEN 
    UPDATE SET dim_matricula_key = source.dim_matricula_key, origen = source.origen, data_matricula = source.data_matricula, data_anulacio = source.data_anulacio, cod_motiu_anulacio = source.cod_motiu_anulacio, cod_categoritzacio = source.cod_categoritzacio, des_categoritzacio = source.des_categoritzacio, des_entitat = source.des_entitat, des_distribuidor =  source.des_distribuidor, update_date = CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
  WHEN NOT MATCHED THEN 
    INSERT (dim_matricula_key, origen, data_matricula, data_anulacio, cod_motiu_anulacio, cod_categoritzacio, des_categoritzacio, des_entitat, des_distribuidor, creation_date, update_date)
    VALUES (source.dim_matricula_key, source.origen, source.data_matricula, source.data_anulacio, source.cod_motiu_anulacio, source.cod_categoritzacio, source.des_categoritzacio, source.des_entitat, source.des_distribuidor, 
            CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ), 
            CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));

  execution_time := DATEDIFF(MILLISECOND, start_time, CONVERT_TIMEZONE('America/Los_Angeles', 'Europe/Madrid', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));

  INSERT INTO db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
  VALUES (db_uoc_prod.dd_od.sequencia_id_log.NEXTVAL, 'dim_matricula_loads', CURRENT_USER(), :start_time, :execution_time, 'dim_matricula Success');

  RETURN 'Update completed successfully';

END;


SELECT distinct DATA_MATRICULA
FROM db_uoc_prod.dd_od.dim_matricula order by 1;

SELECT *
FROM db_uoc_prod.dd_od.dim_matricula limit 100;