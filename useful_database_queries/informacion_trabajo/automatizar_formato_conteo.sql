select count(*) from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_DIMAX--5975410
select count(*) from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_COCO --1913122
select count(*) from DB_UOC_PROD.DDP_DOCENCIA.F_LIVE_EVENTS_FLATENED--8741384
select count(*) from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES--7888532
select count(*) from DB_UOC_PROD.DDP_DOCENCIA.F_LIVE_EVENTS_FLATENED_TRANSFORMED--123019
select count(*) from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_EVENTS--7890407

--CON ESTAS QUERIES VEO QUE F_DADES_ACADEMIQUES_EVENTS TIENE MÁS REGISTROS QUE F_DADES_ACADEMIQUES LO QUE IMPLICA QUE TENEMOS DUPLICADOOOS

select * from DB_UOC_PROD.DDP_DOCENCIA.F_LIVE_EVENTS_FLATENED_TRANSFORMED
select DIM_SEMESTRE_KEY, COUNT(*) from DB_UOC_PROD.DDP_DOCENCIA.F_LIVE_EVENTS_FLATENED_TRANSFORMED
GROUP BY DIM_SEMESTRE_KEY
ORDER BY 1 DESC
/*
DIM_SEMESTRE_KEY    COUNT(*)
            20241    47504
            20232    59678
            20231    14790
            20222    678
            20221    242
            20212    92
            20211    23
            20202    12
*/
 
select * from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES
select DIM_SEMESTRE_KEY, COUNT(*) from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES
GROUP BY DIM_SEMESTRE_KEY
ORDER BY 1 DESC

/*
DIM_SEMESTRE_KEY    COUNT(*)
NULL     1632 --NO DIJIMOS DE FILTRAR ESTOS REGISTROS??
20251    72701
20243    72663
20242    343165
20241    350099
20233    69871 -POR QUE DISMINUYE EL NUMERO DE REGISTROS??
20232    350626
20231    340727
20222    332350
20221    325880
20212    324013
20211    303134
20202    282655
20201    266078
20193    47731
20192    245749
20191    230240
20183    44644
20182    215915
20181    205100
20173    41199
20172    204788
20171    501991
20163    37246
20162    203685
20161    194002
...HAY MAS REGISTROS QUE NO COPIO
*/

/*Si comparamos F_DADES_ACADEMIQUES vs F_LIVE_EVENTS_FLATENED_TRANSFORMED

DIM_SEMESTRE_KEY    COUNT F_LIVE_EVENTS_FLATENED_TRANSFORMED/ F_DADES_ACADEMIQUES
            20241    47504                      350099     
            20232    59678                   350626
            20231    14790                   340727
            20222    678                     332350
            20221    242                     325880
            20212    92                      324013
            20211    23                      303134
            20202    12                      282655
*/



select * from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_DIMAX--5975410
LIMIT 100
select DISTINCT ID_RESOURCE from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_DIMAX;--637,403 ROWS
select DISTINCT DIM_ASSIGNATURA_KEY from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_DIMAX;--14,095 ROWS
select DISTINCT DIM_SEMESTRE_KEY from DB_UOC_PROD.DDP_DOCENCIA.F_DADES_ACADEMIQUES_DIMAX;--35 ROWS