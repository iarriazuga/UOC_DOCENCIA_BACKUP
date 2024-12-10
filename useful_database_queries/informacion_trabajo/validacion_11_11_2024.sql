--############################################################################################################################
--############################################################################################################################
        , '' AS TIPUS_RECURS -- added: TFG, Exams, Articles (100+ elements)
        , '' AS LLICENCIA_LPC
        , '' AS LLICENCIA_LGC
        , '' AS LLICENCIA_ALTRES
        , '' AS LLICENCIA_BIBLIOTECA
        -- not filled in DIMAX 
        , null AS DATA_INICI_RECURS
        , null AS DATA_CADUCITAT_RECURS
        , '' AS CERCABLE_RECURS -- Options dimax: S / N
        , '' AS INDICADOR_PUBLIC_RECURS -- Options dimax: S / N
        , '' AS PUBLICAT_A_RECURS -- Options dimax: option of magazine of publication
        , '' AS ISBN_ISSN_RECURS
        , 0  AS PAGINA_INICI_RECURS
        , 0  AS PAGINA_FINAL_RECURS
        , '' AS BASE_DADES_RECURS
        , '' AS ELLIBRE_RECURS
        , '' AS URL_CAT_RECURS
        , '' AS URL_CAS_RECURS
        , '' AS URL_ANG_RECURS
        , 'ND' AS TIPUS_GESTIO_RECURS
        , '' AS DESPESA_VARIABLE_RECURS
        , null AS UPDATE_DATE





--############################################################################################################################
--############################################################################################################################



    FROM db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax   
    -- dimax_v_recurs  -- original que viene de la aplicacion 
    -- SELECT * FROM db_uoc_prod.stg_dadesra.dimax_v_recurs
 
    
    He visto hay casos que no hay ningún tipo de licencia y necessitaria que el campo tipus_gesió_recurs tenga un ND si no hay datos. Pongo el sql relacionado
iff(dimax_v_recurs.lpc = 'S','DRETS',
    iff(dimax_v_recurs.lgc = 'S','DRETS',
        iff(dimax_v_recurs.altres = 'S','DRETS',
            iff(dimax_v_recurs.biblioteca = 'S','SUBS', '')))) AS tipus_gestio_recurs 


FROM db_uoc_prod.stg_dadesra.dimax_resofite_path  --- registros : 17,303,400
    
    left join db_uoc_prod.stg_dadesra.dimax_item_dimax on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id -- 17303400
    left join db_uoc_prod.stg_dadesra.dimax_v_recurs on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami = db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs -- 17303400 
    left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra on db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs = db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.id_recurs -- 17303400



--- DIMAX_V_RECURS
SELECT 
    
   table_schema,  table_name, column_name, data_type
FROM 
    db_uoc_prod.INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
    AND TABLE_NAME = 'DIMAX_V_RECURS'
    AND TABLE_SCHEMA = 'STG_DADESRA'
    -- AND TABLE_NAME LIKE'STAGE_REC%'
    -- AND TABLE_SCHEMA = 'DD_OD'
 
ORDER BY 
    COLUMN_NAME ASC;


---------------
SELECT 
    COLUMN_NAME
FROM 
    <NOMBRE_BASE_DATOS>.INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = '<NOMBRE_TABLA>'
    AND TABLE_SCHEMA = '<NOMBRE_ESQUEMA>'
ORDER BY 
    COLUMN_NAME ASC;








