-- EXPLOTACION COCO: importante 

--ASSIGANTURES -- ELEMENT FORMACIO -- Trobar l'Assignatura i el seu id intern
-- CODI_FINAL = Codi Assignatura
SELECT * FROM db_uoc_prod.stg_dadesra.autors_element_formacio limit 10;
-- Trobar l'assignatura en base a un codi B0.911 -> id assignatura a coco 4542
SELECT * FROM db_uoc_prod.stg_dadesra.autors_element_formacio where codi_final='B0.911' limit 10;
-- assignatura amb productes assciats M2.988 -> 54605
SELECT * FROM db_uoc_prod.stg_dadesra.autors_element_formacio where codi_final='M2.988' limit 10;

-- PRODUCTES = Materials 
-- Llista de materials existens (Ex. Producte 149299 de la B0.911)
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte limit 10;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where id = 149299;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where id = 153678;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where id = 259395;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where id = 265006;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where id = 233201;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where PARAULA_CLAU is not NULL limit 50;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where CODI_RECURS_origen is not NULL limit 50;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where CODI_RECURS_origen is not NULL limit 50;

-- MÒDULS_PRODUCTES = Relació entre producte i mòdul relacionat
SELECT * FROM db_uoc_prod.stg_dadesra.autors_moduls_productes where producte_id = 259395;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_moduls_productes where modul_id = 259397;


-- MÒDULS = Part components d'alguns Produtes
SELECT * FROM db_uoc_prod.stg_dadesra.autors_modul where id = 259397;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_modul where obra_id is not null;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_modul where codi_migracio is not null;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_modul where obra_id is not null;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_modul limit 100;


// TO-DO per Xavi: Cal relacionar via 

--  VERSIONS DEL PRODUCTE -- Relaciona el pla de publicació amb el producte
SELECT * FROM db_uoc_prod.stg_dadesra.autors_productes_versions limit 10;
-- Busco les vesrions del producte 149299
SELECT * FROM db_uoc_prod.stg_dadesra.autors_productes_versions where producte_id = 149299 limit 10;
-- Busco les vesrions del producte 153678 <- Declació de Barcelonoa
SELECT * FROM db_uoc_prod.stg_dadesra.autors_productes_versions where producte_id = 153678 limit 10;
-- Productes d'un pla de publicació de la B0.911 que té la Declació de Barcelona - Semestre 20211
SELECT * FROM db_uoc_prod.stg_dadesra.autors_productes_versions where versio_id = 94420;
-- Tots els productes de l'assignatura B0.911
SELECT * FROM db_uoc_prod.stg_dadesra.autors_productes_versions where versio_id IN (94420,45763,42122,38629);
-- Productes d'un pla de publicació de la M2.988 amb productes associats
SELECT * FROM db_uoc_prod.stg_dadesra.autors_productes_versions where versio_id = 127754;

-- PLANS DE PUBLICACIÓ
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio limit 10;
-- ******  busco plans de publicació del producte 149299 
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio where fk_element_formacio_element_id = 4542;
-- assignatura amb productes assciats M2.988 -> pla publ 127754
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio where fk_element_formacio_element_id = 54605;
;
-- busco el pla de publicació de la B0.911 amb codi 38608
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio where fk_periode_periode_id = 38608;
-- busco el id de versió 38629 que està associat al producte 153678 Declaració de Barcelona
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio where id = 38629;
-- busco el pla de publicació 886681 de la B0.911 -> agafa només un procte i n'hi ha 15 -> id resulant 94420 a buscar a verions
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio where fk_encarrec_encarrec_id = 88681;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_versio where fk_encarrec_encarrec_id = 42022;

SELECT count(1) FROM db_uoc_prod.stg_dadesra.autors_productes_versions; --241043
SELECT count(1) FROM db_uoc_prod.stg_dadesra.autors_producte; --54875
SELECT count(1) FROM db_uoc_prod.stg_dadesra.autors_element_formacio; --33584
SELECT count(1) FROM db_uoc_prod.stg_dadesra.autors_versio; --44747
SELECT * FROM db_uoc_prod.stg_dadesra.autors_encarrec limit 100;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_suport_producte_i18n limit 100;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_tipus_tramesa_i18n limit 100;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte where titol like '%Mòdul 3.%';

SELECT *
FROM db_uoc_prod.stg_dadesra.autors_productes_versions
inner join db_uoc_prod.stg_dadesra.autors_producte
on db_uoc_prod.stg_dadesra.autors_productes_versions.producte_id = db_uoc_prod.stg_dadesra.autors_producte.id
inner join db_uoc_prod.stg_dadesra.autors_versio
on db_uoc_prod.stg_dadesra.autors_productes_versions.versio_id = db_uoc_prod.stg_dadesra.autors_versio.id
inner join db_uoc_prod.stg_dadesra.autors_element_formacio
on db_uoc_prod.stg_dadesra.autors_versio.fk_element_formacio_element_id = db_uoc_prod.stg_dadesra.autors_element_formacio.id
inner join db_uoc_prod.stg_dadesra.autors_periode
on db_uoc_prod.stg_dadesra.autors_versio.fk_periode_periode_id = db_uoc_prod.stg_dadesra.autors_periode.id
where autors_element_formacio.codi_final = 'M8.020'
-- where db_uoc_prod.stg_dadesra.autors_productes_versions.producte_id = '248075'
-- AND db_uoc_prod.stg_dadesra.autors_versio.id = '259397'
-- where db_uoc_prod.stg_dadesra.autors_element_formacio.ind_last = 1
limit 100;

-- Dimensions: PRODUCTE (autors_producte), PLA_PUBLICACIO (autors_versio [versio]), ELEMENTS_FORMACIO (autors_element_formacio [assignatures])

SELECT * FROM db_uoc_prod.stg_dadesra.autors_periode limit 100; 

SELECT * FROM db_uoc_prod.stg_dadesra.t_saa_accessos_ra limit 100;

SELECT * FROM db_uoc_prod.stg_dadesra.live_events_caliper_dummy limit 100;

-- Un pla de publcació en blanc
SELECT * FROM db_uoc_prod.stg_dadesra.autors_encarrec where id = 123156;
SELECT count(*) FROM db_uoc_prod.stg_dadesra.autors_encarrec;










-- Creacio de la dimensio de materials de Recursos d Aprenentatge
SELECT
CODI_RECURS,
autors_producte_id,
titol,
'Propi' AS recurs,
suport_producte
FROM
(
-- Conjunt de materials que disposen de modul existent
SELECT 
ifnull(autors_modul.id,autors_producte.id) AS CODI_RECURS,
autors_producte.id AS autors_producte_id,
ifnull(autors_modul.descripcio,autors_producte.titol) AS titol,
ifnull(autors_producte.fk_suport_producte_suport_id,0) AS suport_producte
FROM db_uoc_prod.stg_dadesra.autors_producte
left join db_uoc_prod.stg_dadesra.autors_moduls_productes
on autors_producte.id = autors_moduls_productes.producte_id
left join db_uoc_prod.stg_dadesra.autors_modul
on autors_moduls_productes.modul_id = autors_modul.id
-- where autors_producte.id = '214824'
-- where autors_producte.id = '259395'
-- limit 100
union all
-- Unio per identificar tots els registres que contenen moduls pero que tambe han d estar presents
SELECT distinct
autors_producte.id AS CODI_RECURS,
autors_producte.id AS autors_producte_id,
autors_producte.titol,
ifnull(autors_producte.fk_suport_producte_suport_id,0) AS suport_producte
FROM db_uoc_prod.stg_dadesra.autors_producte
left join db_uoc_prod.stg_dadesra.autors_moduls_productes
on autors_producte.id = autors_moduls_productes.producte_id
-- inner join db_uoc_prod.stg_dadesra.autors_modul
-- on autors_moduls_productes.modul_id = autors_modul.id
-- where autors_producte.id = '214824'
where ifnull(autors_moduls_productes.producte_id,0) != 0
-- AND autors_producte.id = '259395'
-- limit 100
) AS moduls_producte;

/*
Generacio de la dimensio:
- pla_publicacio
    - assignatura
        - material
        - aula
*/

SELECT 
moduls_producte.*,
autors_productes_versions.producte_id,
autors_versio.id,
autors_versio.ordre,
-- autors_versio.fk_encarrec_encarrec_id, -- docent que fa l encarrec
autors_periode.codi_extern,
autors_periode.data_inici,
autors_periode.data_fi,
autors_periode.data_publicacio,
autors_element_formacio.codi_final -- codi_assignatura
FROM db_uoc_prod.stg_dadesra.autors_versio
left join db_uoc_prod.stg_dadesra.autors_periode
on autors_versio.fk_periode_periode_id = autors_periode.id
left join db_uoc_prod.stg_dadesra.autors_element_formacio
on autors_versio.fk_element_formacio_element_id = autors_element_formacio.id
left join db_uoc_prod.stg_dadesra.autors_productes_versions
on autors_productes_versions.versio_id = autors_versio.id
inner join
(SELECT
CODI_RECURS,
autors_producte_id,
titol,
'Propi' AS recurs,
suport_producte
FROM
(
-- Conjunt de materials que disposen de modul existent
SELECT 
ifnull(autors_modul.id,autors_producte.id) AS CODI_RECURS,
autors_producte.id AS autors_producte_id,
ifnull(autors_modul.descripcio,autors_producte.titol) AS titol,
ifnull(autors_producte.fk_suport_producte_suport_id,0) AS suport_producte
FROM db_uoc_prod.stg_dadesra.autors_producte
left join db_uoc_prod.stg_dadesra.autors_moduls_productes
on autors_producte.id = autors_moduls_productes.producte_id
left join db_uoc_prod.stg_dadesra.autors_modul
on autors_moduls_productes.modul_id = autors_modul.id
-- where autors_producte.id = '214824'
-- where autors_producte.id = '259395'
-- limit 100
union all
-- Unio per identificar tots els registres que contenen moduls pero que tambe han d estar presents
SELECT distinct
autors_producte.id AS CODI_RECURS,
autors_producte.id AS autors_producte_id,
autors_producte.titol,
ifnull(autors_producte.fk_suport_producte_suport_id,0) AS suport_producte
FROM db_uoc_prod.stg_dadesra.autors_producte
left join db_uoc_prod.stg_dadesra.autors_moduls_productes
on autors_producte.id = autors_moduls_productes.producte_id
-- inner join db_uoc_prod.stg_dadesra.autors_modul
-- on autors_moduls_productes.modul_id = autors_modul.id
-- where autors_producte.id = '214824'
where ifnull(autors_moduls_productes.producte_id,0) != 0
-- AND autors_producte.id = '259395'
-- limit 100
)) AS moduls_producte
on moduls_producte.autors_producte_id = autors_productes_versions.producte_id
where codi_final = 'M8.020'
order by ordre
limit 100
;

SELECT 1;


SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte limit 10;




SELECT * FROM db_uoc_prod.stg_dadesra.dim_material_ra where recurs = 'PROPI' limit 100;

SELECT * FROM db_uoc_prod.stg_dadesra.autors_modul;
SELECT * FROM db_uoc_prod.stg_dadesra.autors_producte;













