CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.DIM_PORTAFOLI_PA_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'BEGIN
  LET start_time TIMESTAMP_NTZ := CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ);
  LET execution_time FLOAT;
 
  -- Proces que incorpora el registre 0 a la dimensio.
  MERGE INTO db_uoc_prod.dd_od.dim_portafoli_pa AS target
  USING (SELECT 
                0 AS id_portafoli_pa, 
                ''ND'' AS dim_portafoli_pa_key, 
                null AS num_creditos_teoricos,
                null AS num_creditos_practicos,
                null AS min_creditos_clase_tm,
                null AS min_creditos_clase_of,
                null AS min_creditos_clase_pi,
                null AS min_creditos_clase_la,
                null AS min_creditos_clase_c,
                ''ND'' AS ind_titulaciones_propias,
                ''ND'' AS estado_plan,
                null AS num_version_plan,
                ''ND'' AS descripcion,
                null AS cod_estudios,
                ''1900-01-01 00:00:00.000''::TIMESTAMP_NTZ AS fecha_publica_oficial,
                ''ND'' AS desc_publica_oficial,
                null AS ciclo_plan,
                ''ND'' AS ind_creditos_asignaturas,
                null AS min_creditos_asignaturas,
                null AS max_creditos_asignaturas,
                null AS conta_elementos,
                ''ND'' AS observaciones,
                null AS num_control,
                ''ND'' AS cod_estudios_mec,
                ''ND'' AS ind_valida_inicio_exp,
                null AS min_creditos_mec,
                ''ND'' AS cod_area,
                null AS num_edicion,
                ''ND'' AS descripcion_cer,
                null AS num_creditos_ciclo2,
                ''ND'' AS es_ciclo_12,
                ''ND'' AS tipo_educacion,
                ''ND'' AS ind_visible_egia,
                ''ND'' AS ind_consecucion_parcial,
                null AS ratio_conversio,
                null AS ratio_fideliza,
                null AS max_estud_tutor,
                null AS id_prog_bof,
                ''ND'' AS ind_interuniversitario,
                ''ND'' AS idioma_docencia,
                ''ND'' AS ind_migracion_gatib,
                0 AS id_bof_tr,
                ''ND'' AS des_denominacio_ca_tr,
                ''ND'' AS des_unitat_organica_ca_tr,
                ''ND'' AS des_tipologia_ca_tr,
                ''ND'' AS des_iniciativa_ca_tr,
                0 AS id_bof, 
                ''ND'' AS des_denominacio_ca, 
                ''ND'' AS des_estat_ca, 
                ''ND'' AS des_vicegerencia_ca, 
                ''ND'' AS des_tipologia_ca, 
                ''ND'' AS des_totp, 
                ''ND'' AS des_iniciativa_ca, 
                ''ND'' AS des_unitat_organica_ca, 
                ''ND'' AS des_nivell_academic_ca, 
                ''ND'' AS des_nivell_meces_ca, 
                ''ND'' AS des_legislacio_ca, 
                0 AS ects_a_superar, 
                ''ND''::VARIANT AS ects_desglossat_per_tipologia, 
                0 AS ects_a_desplegar, 
                ''ND''::VARIANT AS des_director_de_programa, 
                ''ND'' AS des_responsable_academic_ca, 
                ''ND''::VARIANT AS des_manager_de_programa, 
                ''ND'' AS des_coordinadora_ca, 
                ''ND'' AS des_arrel_programa, 
                ''ND'' AS des_estat_prim_reg, 
                ''ND'' AS des_estat_solicitud, 
                ''ND'' AS des_estat_programa_disseny_titulacions_inici, 
                ''ND'' AS des_estat_resultat_informe_final_verificacio_aqu, 
                ''ND'' AS des_estat_programa_disseny_titulacions_fi, 
                ''1900-01-01 00:00:00.000''::TIMESTAMP_NTZ AS data_verificacio, 
                ''ND'' AS des_estat_disseny_titulacions, 
                0 AS data_previsio_implantacio_mes, 
                0 AS data_previsio_implantacio_any, 
                0 AS data_implantacio_real_mes, 
                0 AS data_implantacio_real_any, 
                ''1900-01-01 00:00:00.000''::TIMESTAMP_NTZ AS data_de_linforme_final_modificacio_aqu, 
                ''ND'' AS des_estat_programa_acreditar_titulacions, 
                ''ND'' AS des_estat_solicitud_extincio_cicle_vida, 
                ''1900-01-01 00:00:00.000''::TIMESTAMP_NTZ AS data_inici_extincio, 
                ''1900-01-01 00:00:00.000''::TIMESTAMP_NTZ AS data_extincio, 
                CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ) AS creation_date,
                CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ) AS update_date) AS source
  ON target.id_portafoli_pa = source.id_portafoli_pa
  WHEN MATCHED THEN 
    UPDATE SET update_date = CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
  WHEN NOT MATCHED THEN 
    INSERT (id_portafoli_pa, dim_portafoli_pa_key, num_creditos_teoricos, num_creditos_practicos, min_creditos_clase_tm, min_creditos_clase_of, min_creditos_clase_pi, min_creditos_clase_la, min_creditos_clase_c, ind_titulaciones_propias, estado_plan, num_version_plan, descripcion, cod_estudios, fecha_publica_oficial, desc_publica_oficial, ciclo_plan, ind_creditos_asignaturas, min_creditos_asignaturas, max_creditos_asignaturas, conta_elementos, observaciones, num_control, cod_estudios_mec, ind_valida_inicio_exp, min_creditos_mec, cod_area, num_edicion, descripcion_cer, num_creditos_ciclo2, es_ciclo_12, tipo_educacion, ind_visible_egia, ind_consecucion_parcial, ratio_conversio, ratio_fideliza, max_estud_tutor, id_prog_bof, ind_interuniversitario, idioma_docencia, ind_migracion_gatib,
    id_bof_tr, des_denominacio_ca_tr, des_unitat_organica_ca_tr, des_tipologia_ca_tr, des_iniciativa_ca_tr, id_bof, des_denominacio_ca, des_estat_ca, des_vicegerencia_ca, des_tipologia_ca, des_totp, des_iniciativa_ca, des_unitat_organica_ca, des_nivell_academic_ca, des_nivell_meces_ca, des_legislacio_ca, ects_a_superar, ects_desglossat_per_tipologia, ects_a_desplegar, des_director_de_programa, des_responsable_academic_ca, des_manager_de_programa, des_coordinadora_ca, des_arrel_programa, des_estat_prim_reg, des_estat_solicitud, des_estat_programa_disseny_titulacions_inici, des_estat_resultat_informe_final_verificacio_aqu, des_estat_programa_disseny_titulacions_fi, data_verificacio, des_estat_disseny_titulacions, data_previsio_implantacio_mes, data_previsio_implantacio_any, data_implantacio_real_mes, data_implantacio_real_any, data_de_linforme_final_modificacio_aqu, des_estat_programa_acreditar_titulacions, des_estat_solicitud_extincio_cicle_vida, data_inici_extincio, data_extincio, 
    creation_date, update_date)
    VALUES (source.id_portafoli_pa, source.dim_portafoli_pa_key, source.num_creditos_teoricos, source.num_creditos_practicos, source.min_creditos_clase_tm, source.min_creditos_clase_of, source.min_creditos_clase_pi, source.min_creditos_clase_la, source.min_creditos_clase_c, source.ind_titulaciones_propias, source.estado_plan, source.num_version_plan, source.descripcion, source.cod_estudios, source.fecha_publica_oficial, source.desc_publica_oficial, source.ciclo_plan, source.ind_creditos_asignaturas, source.min_creditos_asignaturas, source.max_creditos_asignaturas, source.conta_elementos, source.observaciones, source.num_control, source.cod_estudios_mec, source.ind_valida_inicio_exp, source.min_creditos_mec, source.cod_area, source.num_edicion, source.descripcion_cer, source.num_creditos_ciclo2, source.es_ciclo_12, source.tipo_educacion, source.ind_visible_egia, source.ind_consecucion_parcial, source.ratio_conversio, source.ratio_fideliza, source.max_estud_tutor, source.id_prog_bof, source.ind_interuniversitario, source.idioma_docencia, source.ind_migracion_gatib, 
    source.id_bof_tr, source.des_denominacio_ca_tr, source.des_unitat_organica_ca_tr, source.des_tipologia_ca_tr, source.des_iniciativa_ca_tr, source.id_bof, source.des_denominacio_ca, source.des_estat_ca, source.des_vicegerencia_ca, source.des_tipologia_ca, source.des_totp, source.des_iniciativa_ca, source.des_unitat_organica_ca, source.des_nivell_academic_ca, source.des_nivell_meces_ca, source.des_legislacio_ca, source.ects_a_superar, source.ects_desglossat_per_tipologia, source.ects_a_desplegar, source.des_director_de_programa, source.des_responsable_academic_ca, source.des_manager_de_programa, source.des_coordinadora_ca, source.des_arrel_programa, source.des_estat_prim_reg, source.des_estat_solicitud, source.des_estat_programa_disseny_titulacions_inici, source.des_estat_resultat_informe_final_verificacio_aqu, source.des_estat_programa_disseny_titulacions_fi, source.data_verificacio, source.des_estat_disseny_titulacions, source.data_previsio_implantacio_mes, source.data_previsio_implantacio_any, source.data_implantacio_real_mes, source.data_implantacio_real_any, source.data_de_linforme_final_modificacio_aqu, source.des_estat_programa_acreditar_titulacions, source.des_estat_solicitud_extincio_cicle_vida, source.data_inici_extincio, source.data_extincio, 
source.creation_date, source.update_date

);

  
  MERGE INTO db_uoc_prod.dd_od.dim_portafoli_pa AS target
  USING (
  WITH RECURSIVE Relationship_CTE AS (
    -- Caso base: Seleccionamos todas las filas de la tabla original
    SELECT id_bof, id_bof_rel
    FROM MDD_PROGRAM.PROGRAM_RELACIONES
    WHERE
        des_relacion_ca IN (''Adaptació'', ''Evolució'') 
        AND (
            CASE 
                WHEN des_relacion:mes IS NOT NULL AND des_relacion:any IS NOT NULL THEN 
                TO_DATE(CONCAT(des_relacion:any::STRING, ''-'', des_relacion:mes::STRING, ''-01''), ''YYYY-MM-DD'')
            ELSE NULL
            END < CURRENT_DATE
            OR des_relacion:any::STRING IS NULL
            OR des_relacion:mes::STRING IS NULL
        )

    UNION ALL

    -- Caso recursivo: Encontramos la siguiente relación en la cadena
    SELECT r.id_bof, t.id_bof_rel
    FROM Relationship_CTE r
    JOIN MDD_PROGRAM.PROGRAM_RELACIONES t
    ON r.id_bof_rel = t.id_bof
    WHERE
        t.des_relacion_ca IN (''Adaptació'', ''Evolució'') 
        AND (
            CASE 
                WHEN t.des_relacion:mes IS NOT NULL AND t.des_relacion:any IS NOT NULL THEN 
                TO_DATE(CONCAT(t.des_relacion:any::STRING, ''-'', t.des_relacion:mes::STRING, ''-01''), ''YYYY-MM-DD'')
            ELSE NULL
            END < CURRENT_DATE
            OR t.des_relacion:any::STRING IS NULL
            OR t.des_relacion:mes::STRING IS NULL
        )
    ),

    Final_Relationships AS (
        -- Seleccionamos la última relación para cada id_bof
        SELECT id_bof, MAX(cte.id_bof_rel) AS id_bof_tr
        FROM Relationship_CTE cte
        GROUP BY id_bof
    ),
    bof_tr AS (
        SELECT bt.* , 
            PROGRAM.des_denominacio_ca AS des_denominacio_ca_tr, 
            PROGRAM.des_tipologia_ca AS des_tipologia_ca_tr, 
            PROGRAM.des_unitat_organica_ca AS des_unitat_organica_ca_tr,
            PROGRAM.des_iniciativa[0]:descripcion:ca::STRING AS des_iniciativa_ca_tr
        FROM (SELECT COALESCE(fr.id_bof_tr, PROGRAM.id_bof) AS id_bof_tr, PROGRAM.*
            FROM MDD_PROGRAM.PROGRAM 
            LEFT JOIN Final_Relationships fr ON fr.id_bof = PROGRAM.id_bof) bt
        LEFT JOIN MDD_PROGRAM.PROGRAM ON bt.id_bof_tr = PROGRAM.id_bof
    )
    SELECT 
        pd.cod_plan AS dim_portafoli_pa_key, 
        pd.num_creditos_teoricos, 
        pd.num_creditos_practicos, 
        pd.min_creditos_clase_tm, 
        pd.min_creditos_clase_of, 
        pd.min_creditos_clase_pi, 
        pd.min_creditos_clase_la, 
        pd.min_creditos_clase_c, 
        pd.ind_titulaciones_propias, 
        pd.estado_plan, 
        pd.num_version_plan, 
        pd.descripcion, 
        pd.cod_estudios, 
        pd.fecha_publica_oficial, 
        pd.desc_publica_oficial, 
        pd.ciclo_plan, 
        pd.ind_creditos_asignaturas, 
        pd.min_creditos_asignaturas, 
        pd.max_creditos_asignaturas, 
        pd.conta_elementos, 
        pd.observaciones, 
        pd.num_control, 
        pd.cod_estudios_mec, 
        pd.ind_valida_inicio_exp, 
        pd.min_creditos_mec, 
        pd.cod_area, 
        pd.num_edicion, 
        pd.descripcion_cer, 
        pd.num_creditos_ciclo2, 
        pd.es_ciclo_12, 
        pd.tipo_educacion, 
        pd.ind_visible_egia, 
        pd.ind_consecucion_parcial, 
        pd.ratio_conversio, 
        pd.ratio_fideliza, 
        pd.max_estud_tutor, 
        pd.id_prog_bof, 
        pd.ind_interuniversitario, 
        pd.idioma_docencia, 
        pd.ind_migracion_gatib,
        pa.id_bof_tr,
        pa.des_denominacio_ca_tr, 
        pa.des_unitat_organica_ca_tr,
        pa.des_tipologia_ca_tr, 
        pa.des_iniciativa_ca_tr,
        pa.id_bof, 
        pa.des_denominacio_ca, 
        pa.des_estat_ca, 
        pa.des_vicegerencia_ca, 
        pa.des_tipologia_ca, 
        pa.des_totp, 
        pa.des_iniciativa[0]:descripcion:ca::STRING AS des_iniciativa_ca, 
        pa.des_unitat_organica_ca, 
        pa.des_nivell_academic_ca, 
        pa.des_nivell_meces_ca,
        pa.des_legislacio_ca, 
        pa.ects_a_superar, 
        pa.ects_desglossat_per_tipologia, 
        pa.ects_a_desplegar, 
        pa.des_director_de_programa, 
        pa.des_responsable_academic_ca,  
        pa.des_manager_de_programa, 
        pa.des_coordinadora_ca, 
        pa.des_arrel_programa, 
        pa.des_estat_prim_reg, 
        pa.des_estat_solicitud, 
        pa.des_estat_programa_disseny_titulacions_inici, 
        pa.des_estat_resultat_informe_final_verificacio_aqu, 
        pa.des_estat_programa_disseny_titulacions_fi, 
        pa.data_verificacio, 
        pa.des_estat_disseny_titulacions, 
        pa.data_previsio_implantacio_mes, 
        pa.data_previsio_implantacio_any, 
        pa.data_implantacio_real_mes, 
        pa.data_implantacio_real_any, 
        pa.data_de_linforme_final_modificacio_aqu, 
        pa.des_estat_programa_acreditar_titulacions, 
        pa.des_estat_solicitud_extincio_cicle_vida, 
        pa.data_inici_extincio, 
        pa.data_extincio
    FROM STG_MAT.GAT_PLAN_DATOS pd
    LEFT JOIN bof_tr pa ON pd.id_prog_bof=pa.id_bof
    ) AS source
    ON target.dim_portafoli_pa_key = source.dim_portafoli_pa_key
  WHEN MATCHED THEN 
    UPDATE SET update_date = CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)
  WHEN NOT MATCHED THEN 
    INSERT (dim_portafoli_pa_key, num_creditos_teoricos, num_creditos_practicos, min_creditos_clase_tm, min_creditos_clase_of, min_creditos_clase_pi, min_creditos_clase_la, min_creditos_clase_c, ind_titulaciones_propias, estado_plan, num_version_plan, descripcion, cod_estudios, fecha_publica_oficial, desc_publica_oficial, ciclo_plan, ind_creditos_asignaturas, min_creditos_asignaturas, max_creditos_asignaturas, conta_elementos, observaciones, num_control, cod_estudios_mec, ind_valida_inicio_exp, min_creditos_mec, cod_area, num_edicion, descripcion_cer, num_creditos_ciclo2, es_ciclo_12, tipo_educacion, ind_visible_egia, ind_consecucion_parcial, ratio_conversio, ratio_fideliza, max_estud_tutor, id_prog_bof, ind_interuniversitario, idioma_docencia, ind_migracion_gatib, 
    id_bof_tr, des_denominacio_ca_tr, des_unitat_organica_ca_tr, des_tipologia_ca_tr, des_iniciativa_ca_tr,id_bof, des_denominacio_ca, des_estat_ca, des_vicegerencia_ca, des_tipologia_ca, des_totp, des_iniciativa_ca, des_unitat_organica_ca, des_nivell_academic_ca, des_nivell_meces_ca, des_legislacio_ca, ects_a_superar, ects_desglossat_per_tipologia, ects_a_desplegar, des_director_de_programa, des_responsable_academic_ca, des_manager_de_programa, des_coordinadora_ca, des_arrel_programa, des_estat_prim_reg, des_estat_solicitud, des_estat_programa_disseny_titulacions_inici, des_estat_resultat_informe_final_verificacio_aqu, des_estat_programa_disseny_titulacions_fi, data_verificacio, des_estat_disseny_titulacions, data_previsio_implantacio_mes, data_previsio_implantacio_any, data_implantacio_real_mes, data_implantacio_real_any, data_de_linforme_final_modificacio_aqu, des_estat_programa_acreditar_titulacions, des_estat_solicitud_extincio_cicle_vida, data_inici_extincio, data_extincio, 
    creation_date, update_date)
    VALUES (source.dim_portafoli_pa_key, source.num_creditos_teoricos, source.num_creditos_practicos, source.min_creditos_clase_tm, source.min_creditos_clase_of, source.min_creditos_clase_pi, source.min_creditos_clase_la, source.min_creditos_clase_c, source.ind_titulaciones_propias, source.estado_plan, source.num_version_plan, source.descripcion, source.cod_estudios, source.fecha_publica_oficial, source.desc_publica_oficial, source.ciclo_plan, source.ind_creditos_asignaturas, source.min_creditos_asignaturas, source.max_creditos_asignaturas, source.conta_elementos, source.observaciones, source.num_control, source.cod_estudios_mec, source.ind_valida_inicio_exp, source.min_creditos_mec, source.cod_area, source.num_edicion, source.descripcion_cer, source.num_creditos_ciclo2, source.es_ciclo_12, source.tipo_educacion, source.ind_visible_egia, source.ind_consecucion_parcial, source.ratio_conversio, source.ratio_fideliza, source.max_estud_tutor, source.id_prog_bof, source.ind_interuniversitario, source.idioma_docencia, source.ind_migracion_gatib, 
    source.id_bof_tr, source.des_denominacio_ca_tr, source.des_unitat_organica_ca_tr, source.des_tipologia_ca_tr, source.des_iniciativa_ca_tr, source.id_bof, source.des_denominacio_ca, source.des_estat_ca, source.des_vicegerencia_ca, source.des_tipologia_ca, source.des_totp, source.des_iniciativa_ca, source.des_unitat_organica_ca, source.des_nivell_academic_ca, source.des_nivell_meces_ca, source.des_legislacio_ca, source.ects_a_superar, source.ects_desglossat_per_tipologia, source.ects_a_desplegar, source.des_director_de_programa, source.des_responsable_academic_ca, source.des_manager_de_programa, source.des_coordinadora_ca, source.des_arrel_programa, source.des_estat_prim_reg, source.des_estat_solicitud, source.des_estat_programa_disseny_titulacions_inici, source.des_estat_resultat_informe_final_verificacio_aqu, source.des_estat_programa_disseny_titulacions_fi, source.data_verificacio, source.des_estat_disseny_titulacions, source.data_previsio_implantacio_mes, source.data_previsio_implantacio_any, source.data_implantacio_real_mes, source.data_implantacio_real_any, source.data_de_linforme_final_modificacio_aqu, source.des_estat_programa_acreditar_titulacions, source.des_estat_solicitud_extincio_cicle_vida, source.data_inici_extincio, source.data_extincio,
            CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ), 
            CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));

  execution_time := DATEDIFF(MILLISECOND, start_time, CONVERT_TIMEZONE(''America/Los_Angeles'', ''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ));

  INSERT INTO db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
  VALUES (db_uoc_prod.dd_od.sequencia_id_log.NEXTVAL, ''dim_portafoli_pa_loads'', CURRENT_USER(), :start_time, :execution_time, ''dim_portafoli_pa Success'');

  RETURN ''Update completed successfully'';

END';