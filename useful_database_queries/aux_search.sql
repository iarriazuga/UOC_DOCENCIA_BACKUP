begin
 let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
 let execution_time float;
 
 -- Carga del registro 0
 merge into DB_UOC_PROD.DD_OD.dim_acces
 using (SELECT 0 AS id_acces, 'ND' AS dim_acces_key, 'ND' AS tipo_docencia, 'ND' AS acces_titol_propi, 'ND' AS via_acces, 'ND' AS opcio_acces,'ND' AS tipo_acces, 'ND' AS acces_sue, 'ND' AS via_siiu, 'ND' via_oficina,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS creation_date,convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz) AS update_date) AS dim_residencia_repl
 on DB_UOC_PROD.DD_OD.dim_acces.id_acces = dim_residencia_repl.id_acces
 when matched 
 then update set update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
 when not matched 
 then insert (id_acces, dim_acces_key, tipo_docencia, acces_titol_propi, via_acces, opcio_acces, tipo_acces, acces_sue, via_siiu, via_oficina, creation_date, update_date)
 values (0,'ND', 'ND' , 'ND', 'ND' ,'ND', 'ND', 'ND', 'ND', 'ND', convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));
 
 -- Cargar/actualizar datos
 
 merge into DB_UOC_PROD.DD_OD.dim_acces
 using (SELECT distinct
  tipo_docencia_detalle AS tipo_docencia, --CP
  gpd.ind_titulaciones_propias AS acces_titol_propi, -- CP
  pac.Via_acces AS Via_acc, --CP
  pac.DESCRIPCION AS opcio_acc, -- CP
  CONCAT(tipo_docencia,acces_titol_propi,Via_acc,opcio_acc) AS dim_acces_key,
  case when tipo_docencia_detalle = 'GR' AND ind_titulaciones_propias ='N' then 'Accès Graus oficials'
  else 'Altres' end AS tipo_acces,
  case when evue.acces_sue is null AND tipo_acces = 'Accès Graus oficials' then 'ND' -- Pendiente de clasificar
  when evue.acces_sue is null AND tipo_acces <> 'Accès Graus oficials' then 'NA'
  else evue.acces_sue end AS acces_sue,
  case when evue.via_siiu is null AND tipo_acces = 'Accès Graus oficials' then 'ND' -- Pendiente de clasificar
  when evue.via_siiu is null AND tipo_acces <> 'Accès Graus oficials' then 'NA'
  else evue.via_siiu end AS via_siiu,
  case when via_oficina is null AND tipo_acces = 'Accès Graus oficials' then 'ND' -- Pendiente de clasificar
  when via_oficina is null AND tipo_acces <> 'Accès Graus oficials' then 'NA'
  else via_oficina end AS via_oficina
  FROM
  STG_MAT.GAT_CAB_SOLICITUD_ACC csa
  LEFT JOIN (SELECT pa.cod_opc_Acc, pa.DESCRIPCION ,pa.COD_PLAN,pa.COD_CENTRO, va.DESCRIPCION AS Via_acces
  FROM STG_MAT.gat_plan_accesos pa
  LEFT JOIN STG_MAT.gat_vias_acc va ON pa.cod_via_acc = va.cod_via_acc
  ) pac ON pac.cod_opc_Acc = csa.cod_opc_acc AND pac.COD_CENTRO = csa.COD_CENTRO AND pac.COD_PLAN = csa.COD_PLAN
  left join stg_mat.gat_plan_datos AS gpd on csa.cod_plan= gpd.cod_plan
  left join stg_mat.gat_estudios AS ges on gpd.cod_estudios = ges.cod_estudios
  left join DB_UOC_PROD.DD_OD.equivalencias_viasopcs_uoc_externas AS evue on pac.Via_acces = evue.via_acces AND 
  pac.descripcion = evue.opcio_acces AND tipo_acces = 'Accès Graus oficials') AS origen
 on origen.dim_acces_key = DB_UOC_PROD.DD_OD.dim_acces.dim_acces_key 
 when matched 
 then update set dim_acces_key = origen.dim_acces_key, tipo_docencia = origen.tipo_docencia, tipo_acces = origen.tipo_acces, via_acces = origen.Via_acc, opcio_acces= origen.opcio_acc, acces_sue = origen.acces_sue, via_siiu = origen.via_siiu, via_oficina = origen.via_oficina, update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
 when not matched
 then insert (id_acces, dim_acces_key, tipo_docencia, acces_titol_propi, via_acces, opcio_acces, tipo_acces, acces_sue, via_siiu, via_oficina, creation_date, update_date)
 values (DB_UOC_PROD.DD_OD.sequencia_via_opc_acces.nextval, origen.dim_acces_key, origen.tipo_docencia, origen.acces_titol_propi , origen.Via_acc, origen.opcio_acc, origen.tipo_acces, origen.acces_sue, origen.via_siiu, origen.via_oficina, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz), convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));
 
 execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));
 
 insert into DB_UOC_PROD.DD_OD.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
  values (DB_UOC_PROD.DD_OD.sequencia_id_log.nextval, 'dim__loads_dim_vias_opc_acces', CURRENT_USER(), :start_time, :execution_time, 'dim_vias_acces Success');
  
 return 'Update completed successfully';
 
 end