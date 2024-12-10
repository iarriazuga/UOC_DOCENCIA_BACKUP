CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.DIM_PERSONA_LOADS()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS CALLER
AS 'begin
let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz);
let execution_time float;

-- Carga del registre 0
merge into db_uoc_prod.dd_od.dim_persona
using (SELECT 0 AS ID_PERSONA, 0 AS IDP, 0 AS CON_DIRECCIONES, ''ND'' AS TIPO_DOCUMENTO, ''ND'' AS DNI, ''ND'' AS DNI_COMPACTADO, ''ND'' AS NOMBRE, ''ND'' AS APELLIDO1, ''ND'' AS APELLIDO2, ''ND'' AS NUM_SEGUR_SOCIAL, NULL AS FECHA_EXPEDICION_DNI, NULL AS FECHA_INSERCION, NULL AS FECHA_ULT_MODIF, ''ND'' AS PREFIJO_TELEFONO1, ''ND'' AS TELEFONO1, ''ND'' AS PREFIJO_TELEFONO2, ''ND'' AS TELEFONO2, ''ND'' AS PREFIJO_FAX, ''ND'' AS FAX, ''ND'' AS E_MAIL, ''ND'' AS TIPO_PERSONA, ''ND'' AS COD_IDIOMA_COLABORADOR, ''ND'' AS COD_IDIOMA_RELACION, ''ND'' AS ROBINSON, ''ND'' AS IND_SANCIONADO_ECONOMIA, ''ND'' AS VAT_NUMBER, 0 AS EDAT, NULL AS FECHA_NACIM, ''ND'' AS SEXE, ''ND'' AS PAIS_H, ''ND'' AS PAIS, ''ND'' AS NACIONALITAT, ''ND'' AS PAIS_NACIM, 0 AS ROL_ESTUDIANT, 0 AS ROL_PRA, 0 AS ROL_PDC, 0 AS ROL_TUTOR, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS creation_date, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) AS update_date) AS dim_persona_repl
on db_uoc_prod.dd_od.dim_persona.id_persona = dim_persona_repl.id_persona
when matched 
then update set update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched
then insert (ID_PERSONA, IDP, CON_DIRECCIONES, TIPO_DOCUMENTO, DNI, DNI_COMPACTADO, NOMBRE, APELLIDO1, APELLIDO2, NUM_SEGUR_SOCIAL, FECHA_EXPEDICION_DNI, FECHA_INSERCION, FECHA_ULT_MODIF, PREFIJO_TELEFONO1, TELEFONO1, PREFIJO_TELEFONO2, TELEFONO2, PREFIJO_FAX, FAX, E_MAIL, TIPO_PERSONA, COD_IDIOMA_COLABORADOR, COD_IDIOMA_RELACION, ROBINSON, IND_SANCIONADO_ECONOMIA, VAT_NUMBER, EDAT, FECHA_NACIM, SEXE, PAIS, NACIONALITAT, PAIS_NACIM, ROL_ESTUDIANT, ROL_PRA, ROL_PDC, ROL_TUTOR, CREATION_DATE, UPDATE_DATE)
values (0, 0, 0, ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', NULL, NULL, NULL, ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', ''ND'', 0, NULL, ''ND'', ''ND'', ''ND'', ''ND'', 0, 0, 0, 0, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

--Actualizació dades
merge into db_uoc_prod.dd_od.dim_persona
using (SELECT tdp.idp,
       Case when trd.cod_elemento is not null then 1
            else 0 END AS con_direcciones,
       ttd.descripcion AS tipo_documento,
       tdp.dni,
       tdp.dni_compactado,
       tdp.nombre,
       tdp.apellido1,
       tdp.apellido2,
       tdp.num_segur_social,
       tdp.fecha_expedicion_dni,
       tdp.fecha_insercion,
       tdp.fecha_ult_modif,
       tdp.prefijo_telefono1,
       tdp.telefono1,
       tdp.prefijo_telefono2,
       tdp.telefono2,
       tdp.prefijo_fax,
       tdp.fax,
       tdp.e_mail,
       tdp.tipo_persona,
       tdp.cod_idioma_colaborador, 
       tdp.cod_idioma_relacion,
       tdp.robinson,
       tdp.ind_sancionado_economia,
       tdp.vat_number, --hasta aqui: datos persona gestion/comunicacion
       DATEDIFF(year, tdp.fecha_nacim, CURRENT_DATE) - 
       IFF(
       TO_CHAR(CURRENT_DATE, ''MMDD'') < TO_CHAR(tdp.fecha_nacim, ''MMDD''), 
       1, 
       0) AS Edat, -- Edats pendents de netajar
       tdp.fecha_nacim, 
       Case when tdp.sexo = ''M'' then ''Home''
            when tdp.sexo =''F'' then''Dona'' 
            else null end AS sexe, 
       --tp1.descripcion AS pais_h,
       case when dpr.pais is not null then dpr.pais 
            else tp1.descripcion end AS pais ,
       --dpr.poblacio,
       tp3.desc_nacionalidad AS nacionalitat,
       --td.cod_pais AS cod_pais_h,
       tp2.descripcion AS Pais_nacim,
      case when sub.idp is not null then 1
           else 0 end AS rol_estudiant,
      case when sub2.idp is not null then 1
           else 0 end AS rol_pra,
      case when sub3.idp is not null then 1
           else 0 end AS rol_pdc,
      case when sub4.idp_tuTor is not null then 1
           else 0 end AS rol_tutor
FROM DB_UOC_PROD.STG_MAT.TERCERS_DATOS_PERSONAS AS tdp
left join DB_UOC_PROD.STG_MAT.TERCERS_REF_DIRECCIONES  AS trd on tdp.idp= trd.cod_elemento
left join DB_UOC_PROD.STG_MAT.TERCERS_DIRECCIONES  AS td on trd.num_direccion = td.num_direccion
left join DB_UOC_PROD.STG_MAT.TERCERS_PAISES AS tp1 on td.cod_pais= tp1.cod_pais
left join DB_UOC_PROD.STG_MAT.TERCERS_PAISES AS tp2 on tdp.cod_pais_nacim = tp2.cod_pais
left join DB_UOC_PROD.STG_MAT.TERCERS_PAISES AS tp3 on tdp.cod_pais_nacion = tp3.cod_pais
left join db_uoc_prod.dd_od.dim_pais_residencia AS dpr 
on  td.cod_postal = dpr.cod_postal AND td.ind_localizacion = dpr.ind_localitzacio AND tp1.descripcion = dpr.pais
left join (SELECT distinct idp 
          FROM DB_UOC_PROD.STG_MAT.gat_expedientes
          ) AS sub -- Voy a buscar estudiantes
on tdp.idp = sub.idp
left join (SELECT distinct idp
           FROM  DB_UOC_PROD.STG_DADESRA.GAT_PERSONAS_ASIGNATURAS
           ) AS sub2 -- Voy a buscar pras
on tdp.idp = sub2.idp
left join (SELECT distinct idp
          FROM DB_UOC_PROD.STG_DOCENCIA.GAT_AULAS_ASIG_CONSULTORES
          ) AS sub3 --voy a buscar PDC
on tdp.idp = sub3.idp
left join (SELECT distinct idp_tutor
           FROM DB_UOC_PROD.STG_DOCENCIA.GAT_ESTUD_TUTOR_HIST) AS sub4
on tdp.idp = sub4.idp_tutor
left join stg_uneix.tercers_tipo_documentos AS ttd on  tdp.tipo_documento = ttd.codigo) AS ORIGEN -- Query de origen
ON db_uoc_prod.dd_od.dim_persona.idp = origen.idp
when matched
then update set IDP = origen.idp, CON_DIRECCIONES = origen.con_direcciones, TIPO_DOCUMENTO = origen.tipo_documento, DNI = origen.dni, DNI_COMPACTADO= origen.dni_compactado, NOMBRE = origen.nombre, APELLIDO1 =origen.apellido1, APELLIDO2 = origen.apellido2, NUM_SEGUR_SOCIAL = origen.num_segur_social , FECHA_EXPEDICION_DNI = origen.fecha_expedicion_dni, FECHA_INSERCION = origen.fecha_insercion, FECHA_ULT_MODIF = origen. fecha_ult_modif, PREFIJO_TELEFONO1 = origen.prefijo_telefono1, TELEFONO1 = origen.telefono1, PREFIJO_TELEFONO2 = origen.prefijo_telefono2, TELEFONO2 = origen.telefono2, PREFIJO_FAX = origen.prefijo_fax, FAX = origen.fax, E_MAIL = origen.e_mail, TIPO_PERSONA = origen.tipo_persona, COD_IDIOMA_COLABORADOR = origen.cod_idioma_colaborador, COD_IDIOMA_RELACION = origen.cod_idioma_relacion, ROBINSON = origen.robinson, IND_SANCIONADO_ECONOMIA = origen.ind_sancionado_economia, VAT_NUMBER = origen.vat_number,  EDAT = origen.edat, FECHA_NACIM = origen.fecha_nacim, SEXE = origen.sexe, PAIS = origen.pais , NACIONALITAT = origen.nacionalitat, PAIS_NACIM = origen.pais_nacim, ROL_ESTUDIANT = origen.rol_estudiant, ROL_PRA = origen.rol_pra, ROL_PDC = origen.rol_pdc, ROL_TUTOR = origen.rol_tutor,  UPDATE_DATE = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)
when not matched
then insert (ID_PERSONA, IDP, CON_DIRECCIONES, TIPO_DOCUMENTO, DNI, DNI_COMPACTADO, NOMBRE, APELLIDO1, APELLIDO2, NUM_SEGUR_SOCIAL, FECHA_EXPEDICION_DNI, FECHA_INSERCION, FECHA_ULT_MODIF, PREFIJO_TELEFONO1, TELEFONO1, PREFIJO_TELEFONO2, TELEFONO2, PREFIJO_FAX, FAX, E_MAIL, TIPO_PERSONA, COD_IDIOMA_COLABORADOR, COD_IDIOMA_RELACION, ROBINSON, IND_SANCIONADO_ECONOMIA, VAT_NUMBER, EDAT, FECHA_NACIM, SEXE, PAIS, NACIONALITAT, PAIS_NACIM, ROL_ESTUDIANT, ROL_PRA, ROL_PDC, ROL_TUTOR, CREATION_DATE, UPDATE_DATE)
values (db_uoc_prod.dd_od.sequencia_id_dim_persona.nextval, origen.idp, origen.con_direcciones, origen.tipo_documento, origen.dni, origen.dni_compactado, origen.nombre, origen.apellido1,origen.apellido2, origen.num_segur_social , origen.fecha_expedicion_dni, origen.fecha_insercion,  origen. fecha_ult_modif,  origen.prefijo_telefono1,  origen.telefono1,  origen.prefijo_telefono2,  origen.telefono2,  origen.prefijo_fax,  origen.fax,  origen.e_mail,  origen.tipo_persona,  origen.cod_idioma_colaborador,  origen.cod_idioma_relacion,  origen.robinson,  origen.ind_sancionado_economia,  origen.vat_number ,  origen.edat,  origen.fecha_nacim,  origen.sexe,  origen.pais ,  origen.nacionalitat,  origen.pais_nacim,  origen.rol_estudiant,  origen.rol_pra, origen.rol_pdc, origen.rol_tutor,convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));



execution_time := datediff(millisecond, start_time, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));

insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
    values (db_uoc_prod.dd_od.sequencia_id_log.nextval, ''dim_persona_loads'', CURRENT_USER(), :start_time, :execution_time, ''dim_persona_Success'');
    
return ''Update completed successfully'';

end';