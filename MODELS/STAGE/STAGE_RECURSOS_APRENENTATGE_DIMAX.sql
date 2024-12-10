-- -- #################################################################################################
-- -- #################################################################################################
-- -- RECURSOS_APRENDIZATJE
-- -- #################################################################################################
-- -- #################################################################################################
-- drop table DB_UOC_PROD.DDP_DOCENCIA.DIM_RECURSOS_COCO_PRODUCT_MODULS  DIM_RECURSOS_APRENENTATGE_DIMAX

 
create or replace table db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax (
    codi_recurs number(20,0)                   comment 'Codi del recurs aprenentatge proporcionat pel cataleg intern. Originalment es proporciona amb la nomenclatura ID_RECURS.',
    titol_recurs varchar(4000)                 comment 'Titol del recurs aprenentatge disponible al sistema.',
    origen_recurs varchar(256)                 comment 'Origen o tipologia del recurs. Indica si el recurs es INTERN o EXTERN com a forma de catalogacio. La forma de catalogar-lo depen de la font de la que extreiem el recurs COCO (intern) o DIMAX (extern).',
    tipus_recurs varchar(256)                  comment 'Tipus de recurs aprenentatge. Aquesta informació ve proporcionada per les bases de dades i catalogada previament al sistema. Indica si un recurs, entre altres, es un document, article, url, etc.',
    llicencia_lpc varchar(4)                   comment 'Indica si aquest recurs esta subjecte a pagament de llicencia per la seva utilització. El llicenciament dels drets es del tipus Llicencia Puntual Cedro (LPC).',
    llicencia_lgc varchar(4)                   comment 'Indica si aquest recurs esta subjecte a pagament de llicencia per la seva utilització. El llicenciament dels drets es del tipus Llicencia General Cedro (LGC).',
    llicencia_altres varchar(4)                comment 'Indica si aquest recurs esta subjecte a pagament de llicencia per la seva utilització. El llicenciament dels drets es per a altres tipus Llicencia.',
    llicencia_biblioteca varchar(4)            comment 'Indica si aquest recurs esta subjecte a pagament de llicencia per la seva utilització. Aquest producte pertany a la categoria de Llicencia per subscripcio.',
    wait_recurs varchar(4)                     comment 'Indica si el recurs es visible o es troba ocult per a la seva utilitzacio. El producte es troba a la base de dades encara que no esta disponible per a la utilitzacio dels docents.',
    idioma_recurs varchar(10)                   comment 'Indica idioma en que es mostra el recurs seleccionat.',
    format_recurs varchar(16)                  comment 'Indica el format_recurs del recurs. El format_recurs digital inclou gran varietat de possibilitats (e.g. PDF, Video, HTML, etc.)',
    data_inici_recurs timestamp_ntz(9)         comment 'Data en que es van obtenir els drets per la utilitzacio del recurs.',
    data_caducitat_recurs timestamp_ntz(9)     comment 'Data en que els drests del recurs aprenentatge deixara de tenir vigencia i no podra tornar a ser utilitzat pels docents i/o estudiants, a no ser que es renovin.', // @francesc crec que està dupliat  data_caducitat - @xavi: eliminat el primer camps!
    cercable_recurs varchar(4)                 comment 'Indica si el recurs es cercable o no.',
    indicador_public_recurs varchar(4)         comment 'Serveix per seleccionar el recurs en funcio de si es public o no.',
    publicat_a_recurs varchar(4000)            comment 'Entitat publicadora del recurs.',
    isbn_issn_recurs varchar(256)              comment 'Número internacional identificació de llibres (ISBN) o revistes (ISSN).',
    pagina_inici_recurs number(20,0)           comment 'Pàgina inicial del recurs esmenta dins la publicació que el conté.',
    pagina_final_recurs number(20,0)           comment 'Pagina final del recurs esmenta dins la publicació que el contél.',
    base_dades_recurs varchar(4000)            comment 'Nom de la Base de dades comercial on accedim al rercurs extern.',
    ellibre_recurs varchar(4000)               comment 'Informació de tiplogia del llibre electònic per control de despesa variable.',
    url_cat_recurs varchar(4000)               comment 'URL (adreça web) del recurs en catala.',
    url_cas_recurs varchar(4000)               comment 'URL (adreça web) del recurs en castella.',
    url_ang_recurs varchar(4000)               comment 'URL (adreça web) del recurs en angles.',
    tipus_gestio_recurs varchar(16)            comment 'Indica el tipus de gestio que es fa del recurs i la seva forma llicenciament.',
    despesa_variable_recurs varchar(4)         comment 'Mostra si el recurs en concret es forma part dels recursos pagats amb despesa variable (S) o no (N).',
    creation_date timestamp_ntz(9) not null    comment 'Data de creacio del registre de la informacio.',
	update_date timestamp_ntz(9) not null      comment 'Data de carrega de la informacio.')
;

-- Creacio del procediment que carrega la informacio de DIMAX a la taula stage_recursos_aprenentatge_dimax.
-- Aquest procediment actualitzará tots els registres si es carrega repetit (amb el que mantindra la darrera versio del recurs) o insertara els registres en cas de que no existeixi una correspondencia en el codi del recurs.

create or replace procedure db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax_loads()
returns varchar(16777216)
language SQL
execute as caller
as 
begin
let start_time timestamp_ntz := convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz);
let execution_time float;

-- Sentencia que importa la informacio de les dades en brut (RAW) de DIMAX i que valida la existencia en les taules STAGE. Es un procediment, el MERGE, de UPDATE o INSERT.

merge into db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax
using (
    select distinct
        dimax_v_recurs.id_recurs as codi_recurs,
        dimax_v_recurs.titol as titol_recurs,
        -- Establim manualment el tipus de recurs com a EXTERN ja que importem les dades unicament de DIMAX, que conte aquest tipus de recurs.
        'EXTERN' as origen_recurs,
        dimax_v_recurs.tipus_recurs,
        dimax_v_recurs.lpc as llicencia_lpc,
        dimax_v_recurs.lgc as llicencia_lgc,
        dimax_v_recurs.altres as llicencia_altres,
        dimax_v_recurs.biblioteca as llicencia_biblioteca,
        dimax_v_recurs.wait as wait_recurs,
        lk.DESC_IDIOMA AS idioma_recurs,  -- dimax_v_recurs.idioma_recurs, -- estandarizado francesc
        dimax_v_recurs.format as format_recurs,
        dimax_v_recurs.data_inici as data_inici_recurs,
        dimax_v_recurs.data_caducitat as data_caducitat_recurs,
        dimax_v_recurs.cercable as cercable_recurs,
        dimax_v_recurs.ind_public as indicador_public_recurs,
        dimax_v_recurs.publicat_a as publicat_a_recurs,
        dimax_v_recurs.isbn_issn as isbn_issn_recurs,
        dimax_v_recurs.pagina_inici as pagina_inici_recurs,
        dimax_v_recurs.pagina_final as pagina_final_recurs,
        dimax_recurs_info_extra.base_dades as base_dades_recurs,
        dimax_recurs_info_extra.ellibre as ellibre_recurs,
        dimax_v_recurs.url as url_cat_recurs,
        dimax_v_recurs.url_cas as url_cas_recurs,
        dimax_v_recurs.url_ang as url_ang_recurs,
            
        iff (
            dimax_v_recurs.lpc = 'S','DRETS'
                ,iff (
                        dimax_v_recurs.lgc = 'S'
                        , 'DRETS'
                        , iff (

                            dimax_v_recurs.altres = 'S'
                            ,'DRETS'
                            , iff(
                                    dimax_v_recurs.biblioteca = 'S'
                                    ,'SUBS'
                                    , 'ND'
                            )
                        )
                )
        ) as tipus_gestio_recurs,
        
        iff(lower(dimax_recurs_info_extra.ellibre) like 'seta%','Y','N') as despesa_variable_recurs

    from db_uoc_prod.stg_dadesra.dimax_v_recurs
    
    left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra
        on dimax_v_recurs.id_recurs = dimax_recurs_info_extra.id_recurs
    
    left join DB_UOC_PROD.DDP_DOCENCIA.LK_IDIOMA_2 lk
        on lk.desc_idioma_acronim_2_letras = dimax_v_recurs.idioma_recurs

) as load_recursos_aprenentatge_dimax
-- Hem carregat tota la informacio i hem establert un alies a la taula resultant per tal que les equivalencies entre camps siguin directes.
on db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax.codi_recurs = load_recursos_aprenentatge_dimax.codi_recurs
when matched then
update set
    codi_recurs = load_recursos_aprenentatge_dimax.codi_recurs,
    titol_recurs = load_recursos_aprenentatge_dimax.titol_recurs,
    origen_recurs = load_recursos_aprenentatge_dimax.origen_recurs,
    tipus_recurs = load_recursos_aprenentatge_dimax.tipus_recurs,
    llicencia_lpc = load_recursos_aprenentatge_dimax.llicencia_lpc,
    llicencia_lgc = load_recursos_aprenentatge_dimax.llicencia_lgc,
    llicencia_altres = load_recursos_aprenentatge_dimax.llicencia_altres,
    llicencia_biblioteca = load_recursos_aprenentatge_dimax.llicencia_biblioteca,
    wait_recurs = load_recursos_aprenentatge_dimax.wait_recurs,
    idioma_recurs = load_recursos_aprenentatge_dimax.idioma_recurs,
    format_recurs = load_recursos_aprenentatge_dimax.format_recurs,
    data_inici_recurs = load_recursos_aprenentatge_dimax.data_inici_recurs,
    data_caducitat_recurs = load_recursos_aprenentatge_dimax.data_caducitat_recurs,
    cercable_recurs = load_recursos_aprenentatge_dimax.cercable_recurs,
    indicador_public_recurs = load_recursos_aprenentatge_dimax.indicador_public_recurs,
    publicat_a_recurs = load_recursos_aprenentatge_dimax.publicat_a_recurs,
    isbn_issn_recurs = load_recursos_aprenentatge_dimax.isbn_issn_recurs,
    pagina_inici_recurs = load_recursos_aprenentatge_dimax.pagina_inici_recurs,
    pagina_final_recurs = load_recursos_aprenentatge_dimax.pagina_final_recurs,
    base_dades_recurs = load_recursos_aprenentatge_dimax.base_dades_recurs,
    ellibre_recurs = load_recursos_aprenentatge_dimax.ellibre_recurs,
    url_cat_recurs = load_recursos_aprenentatge_dimax.url_cat_recurs,
    url_cas_recurs = load_recursos_aprenentatge_dimax.url_cas_recurs,
    url_ang_recurs = load_recursos_aprenentatge_dimax.url_ang_recurs,
    tipus_gestio_recurs = load_recursos_aprenentatge_dimax.tipus_gestio_recurs,
    despesa_variable_recurs = load_recursos_aprenentatge_dimax.despesa_variable_recurs,
    update_date = convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
when not matched then
insert
(
    codi_recurs,
    titol_recurs,
    origen_recurs,
    tipus_recurs,
    llicencia_lpc,
    llicencia_lgc,
    llicencia_altres,
    llicencia_biblioteca,
    wait_recurs,
    idioma_recurs,
    format_recurs,
    data_inici_recurs,
    data_caducitat_recurs,
    cercable_recurs,
    indicador_public_recurs,
    publicat_a_recurs,
    isbn_issn_recurs,
    pagina_inici_recurs,
    pagina_final_recurs,
    base_dades_recurs,
    ellibre_recurs,
    url_cat_recurs,
    url_cas_recurs,
    url_ang_recurs,
    tipus_gestio_recurs,
    despesa_variable_recurs,
    creation_date,
    update_date
)
values
(
    load_recursos_aprenentatge_dimax.codi_recurs,
    load_recursos_aprenentatge_dimax.titol_recurs,
    load_recursos_aprenentatge_dimax.origen_recurs,
    load_recursos_aprenentatge_dimax.tipus_recurs,
    load_recursos_aprenentatge_dimax.llicencia_lpc,
    load_recursos_aprenentatge_dimax.llicencia_lgc,
    load_recursos_aprenentatge_dimax.llicencia_altres,
    load_recursos_aprenentatge_dimax.llicencia_biblioteca,
    load_recursos_aprenentatge_dimax.wait_recurs,
    load_recursos_aprenentatge_dimax.idioma_recurs,
    load_recursos_aprenentatge_dimax.format_recurs,
    load_recursos_aprenentatge_dimax.data_inici_recurs,
    load_recursos_aprenentatge_dimax.data_caducitat_recurs,
    load_recursos_aprenentatge_dimax.cercable_recurs,
    load_recursos_aprenentatge_dimax.indicador_public_recurs,
    load_recursos_aprenentatge_dimax.publicat_a_recurs,
    load_recursos_aprenentatge_dimax.isbn_issn_recurs,
    load_recursos_aprenentatge_dimax.pagina_inici_recurs,
    load_recursos_aprenentatge_dimax.pagina_final_recurs,
    load_recursos_aprenentatge_dimax.base_dades_recurs,
    load_recursos_aprenentatge_dimax.ellibre_recurs,
    load_recursos_aprenentatge_dimax.url_cat_recurs,
    load_recursos_aprenentatge_dimax.url_cas_recurs,
    load_recursos_aprenentatge_dimax.url_ang_recurs,
    load_recursos_aprenentatge_dimax.tipus_gestio_recurs,
    load_recursos_aprenentatge_dimax.despesa_variable_recurs,
    convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz),
    convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz)
)
;

execution_time := datediff(millisecond, start_time, convert_timezone('America/Los_Angeles','Europe/Madrid', current_timestamp()::timestamp_ntz));

-- insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)
--     values (db_uoc_prod.dd_od.sequencia_id_log.nextval, 'stage_recursos_aprenentatge_dimax_loads', CURRENT_USER(), :start_time, :execution_time, 'stage_recursos_aprenentatge_dimax Success');
    
return 'Update completed successfully';

end
;

-- Comanda per executar el procediment enmagatzemat al entorn.
call db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax_loads();




/**
comparacion con tabla original

select * from db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax2 -- 101,985
select * from db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax -- 101,985

call db_uoc_prod.dd_od.STAGE_RECURSOS_APRENENTATGE_DIMAX_LOADS2();
call db_uoc_prod.dd_od.stage_recursos_aprenentatge_dimax_loads();
 

*/






