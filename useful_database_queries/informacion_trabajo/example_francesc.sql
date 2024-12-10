select 
db_uoc_prod.stg_dadesra.dimax_item_dimax.cami_node,
db_uoc_prod.stg_dadesra.dimax_resofite_path.id_resource,
db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami,
db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs,
db_uoc_prod.stg_dadesra.dimax_resofite_path.ordre,
db_uoc_prod.stg_dadesra.dimax_item_dimax.titol,
db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs,
db_uoc_prod.stg_dadesra.dimax_v_recurs.titol,
SUBSTR(db_uoc_prod.stg_dadesra.dimax_item_dimax.titol, 0, 6) AS assigntarua_codi,
db_uoc_prod.stg_dadesra.dimax_v_recurs.tipus_recurs,
db_uoc_prod.stg_dadesra.dimax_v_recurs.data_caducitat,
// db_uoc_prod.stg_dadesra.dimax_v_recurs.asignatura, -> camp buit
db_uoc_prod.stg_dadesra.dimax_v_recurs.lpc,
db_uoc_prod.stg_dadesra.dimax_v_recurs.lgc,
db_uoc_prod.stg_dadesra.dimax_v_recurs.altres,
db_uoc_prod.stg_dadesra.dimax_v_recurs.biblioteca,
db_uoc_prod.stg_dadesra.dimax_v_recurs.wait,
db_uoc_prod.stg_dadesra.dimax_v_recurs.idioma_recurs,
db_uoc_prod.stg_dadesra.dimax_v_recurs.format,
db_uoc_prod.stg_dadesra.dimax_v_recurs.data_inici,
db_uoc_prod.stg_dadesra.dimax_v_recurs.data_caducitat,
db_uoc_prod.stg_dadesra.dimax_v_recurs.cercable,
db_uoc_prod.stg_dadesra.dimax_v_recurs.ind_public,
db_uoc_prod.stg_dadesra.dimax_v_recurs.publicat_a,
db_uoc_prod.stg_dadesra.dimax_v_recurs.isbn_issn,
db_uoc_prod.stg_dadesra.dimax_v_recurs.pagina_inici,
db_uoc_prod.stg_dadesra.dimax_v_recurs.pagina_final,
db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.base_dades,
db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.ellibre,
db_uoc_prod.stg_dadesra.dimax_v_recurs.url,
db_uoc_prod.stg_dadesra.dimax_v_recurs.url_cas,
db_uoc_prod.stg_dadesra.dimax_v_recurs.url_ang,
'EXTERN' AS font,  // Afegueixo que és extern perquè ve de DIMAX
case  // Marco els que son de Drets i Subcripció 
    when db_uoc_prod.stg_dadesra.dimax_v_recurs.lpc = 'S' 
        or db_uoc_prod.stg_dadesra.dimax_v_recurs.lgc = 'S'
        or db_uoc_prod.stg_dadesra.dimax_v_recurs.altres = 'S' then 'DRETS'
    when db_uoc_prod.stg_dadesra.dimax_v_recurs.biblioteca = 'S' then 'SUBS'    
    else ''
end as tipus_gestio,
case // Marco el que és Despesa Variable
    when db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.ellibre like 'seta%' 
    or db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.ellibre like 'SETA%' then 'Y'
    else 'N'
end as despesa_variable
from db_uoc_prod.stg_dadesra.dimax_resofite_path 
left join db_uoc_prod.stg_dadesra.dimax_item_dimax on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_recurs = db_uoc_prod.stg_dadesra.dimax_item_dimax.id 
left join db_uoc_prod.stg_dadesra.dimax_v_recurs on db_uoc_prod.stg_dadesra.dimax_resofite_path.node_cami = db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs
left join db_uoc_prod.stg_dadesra.dimax_recurs_info_extra on db_uoc_prod.stg_dadesra.dimax_v_recurs.id_recurs = db_uoc_prod.stg_dadesra.dimax_recurs_info_extra.id_recurs
where db_uoc_prod.stg_dadesra.dimax_item_dimax.titol like '20.819%'and cami_node
like '%3281320%';

/*

ID_RESOURCE	NODE_CAMI	NODE_RECURS	ORDRE	TITOL	ID_RECURS	TITOL_2	ASSIGNTARUA_CODI	TIPUS_RECURS	DATA_CADUCITAT	LPC	LGC	ALTRES	BIBLIOTECA	WAIT	IDIOMA_RECURS	FORMAT	DATA_INICI	DATA_CADUCITAT_2	CERCABLE	IND_PUBLIC	PUBLICAT_A	ISBN_ISSN	PAGINA_INICI	PAGINA_FINAL	BASE_DADES	ELLIBRE	URL	URL_CAS	URL_ANG	FONT	TIPUS_GESTIO	DESPESA_VARIABLE
3427094	87807	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	87807	Biblioteca UOC. Plagi acadèmic [en línia]. Disponible a: http://biblioteca.uoc.edu/ca/biblioguies/biblioguia/Plagi-academic/	20.819	Recull de recursos de Biblioteca	null	N	N	N	S	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	http://biblioteca.uoc.edu/ca/biblioguies/biblioguia/Plagi-academic/	https://biblioteca.uoc.edu/es/biblioguias/biblioguia/Plagio-academico/	https://biblioteca.uoc.edu/en/biblioguides/biblioguide/Academic-plagiarism/	EXTERN	SUBS	N
3427094	111033	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	111033	Pràctica basada en l'evidència	20.819	Recull de recursos de Biblioteca	null	N	N	N	S	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	https://biblioteca.uoc.edu/ca/biblioguies/biblioguia/La-Logopedia/?tab=11	https://biblioteca.uoc.edu/es/biblioguias/biblioguia/La-Logopedia/	https://biblioteca.uoc.edu/en/biblioguides/biblioguide/Speech-Therapy/	EXTERN	SUBS	N
3427095	60730	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	60730	Com citar [en línia]. Disponible a: https://biblioteca.uoc.edu/ca/continguts/Com-citar/index.html	20.819	Recull de recursos de Biblioteca	null	N	N	N	S	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	https://biblioteca.uoc.edu/ca/continguts/Com-citar/index.html	https://biblioteca.uoc.edu/es/contenidos/Como-citar/index.html	https://biblioteca.uoc.edu/en/contents/how-to-quote/index.html	EXTERN	SUBS	N
3427094	81120	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	81120	Servei Lingüístic de la UOC. El Servei Lingüístic	20.819	Webs	null	N	N	N	N	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	https://www.uoc.edu/portal/ca/servei-linguistic/index.html	https://www.uoc.edu/portal/es/servei-linguistic/index.html	https://www.uoc.edu/portal/en/servei-linguistic/index.html	EXTERN		N
3427094	65503	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	65503	Búsqueda de recursos de salud [en línia]. Disponible a: https://biblioteca.uoc.edu/ca/Colleccio-digital-per-arees-destudi/?cat-area=area%2Fciencies-salut%2F&q=	20.819	Recull de recursos de Biblioteca	null	N	N	N	S	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	https://biblioteca.uoc.edu/ca/Colleccio-digital-per-arees-destudi/?cat-area=area%2Fciencies-salut%2F&q=	https://biblioteca.uoc.edu/es/Coleccion-digital-por-areas-de-estudio/index.html?cat-area=area%2Fciencies-salut%2F&q=	https://biblioteca.uoc.edu/en/search-the-digital-collection-by-field/index.html?cat-area=area%2Fciencies-salut%2F&q=	EXTERN	SUBS	N
3427094	60730	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	60730	Com citar [en línia]. Disponible a: https://biblioteca.uoc.edu/ca/continguts/Com-citar/index.html	20.819	Recull de recursos de Biblioteca	null	N	N	N	S	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	https://biblioteca.uoc.edu/ca/continguts/Com-citar/index.html	https://biblioteca.uoc.edu/es/contenidos/Como-citar/index.html	https://biblioteca.uoc.edu/en/contents/how-to-quote/index.html	EXTERN	SUBS	N
3427094	87995	3427092	2	20.819 Bases para la investigació en Ciències de la Salut	87995	Biblioguia UOC: La Logopèdia	20.819	Recull de recursos de Biblioteca	null	N	N	N	S	N	ca	HTML	null	null	S	S	null	null	0	0	null	null	https://biblioteca.uoc.edu/ca/biblioguies/biblioguia/La-Logopedia/	https://biblioteca.uoc.edu/es/biblioguias/biblioguia/La-Logopedia/	https://biblioteca.uoc.edu/en/biblioguides/biblioguide/Speech-Therapy/	EXTERN	SUBS	N


*/

/*

DIMAX-111033	20232	20.819	3281320	;3427092;3417142;3281320;	111033
DIMAX-60730	    20232	20.819	3281320	;3427092;3417142;3281320;	60730
DIMAX-81120	    20232	20.819	3281320	;3427092;3417142;3281320;	81120
DIMAX-65503	    20232	20.819	3281320	;3427092;3417142;3281320;	65503
DIMAX-87995	    20232	20.819	3281320	;3427092;3417142;3281320;	87995
DIMAX-87807	    20232	20.819	3281320	;3427092;3417142;3281320;	87807


*/


65503
111033
87807

60730
60730

87995
81120