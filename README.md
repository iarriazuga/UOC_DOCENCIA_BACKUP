# UOC Docencia

Files used to transform the data insisde snwoflake 

 DB_UOC_PROD.DDP_DOCENCIA.DIM_RESPOSTA




```plaintext

    UOC_Docencia
    ├── .gitignore
    ├── AUX_MODEL_DOCENCIA
    │   ├── LOOKUP_TABLES.sql
    │   └── Stored_procedures
    │       ├── stored_procedure_DIM_AULA.sql
    │       ├── stored_procedure_f_fitxer_29.sql
    │       ├── stored_procedure_f_fitxer_29_enriquida.sql
    │       └── stored_procedure_f_fitxer_29_final.sql
    ├── DOCUMENTACION
    │   ├── stored_procedures
    │   │   ├── no_convalidadas.sql
    │   │   ├── prompt.txt
    │   │   ├── stored_procedrue_fact_docencia.sql
    │   │   ├── stored_procedure_dim_expedient.sql
    │   │   ├── stored_procedure_dim_matricula.sql
    │   │   ├── stored_procedure_dim_pais_nacim.sql
    │   │   ├── stored_procedure_dim_pais_nacionalitat.sql
    │   │   ├── stored_procedure_dim_pais_residencia.sql
    │   │   ├── stored_procedure_dim_persona.sql
    │   │   ├── stored_procedure_dim_portafoli_pa.sql
    │   │   ├── stored_procedure_dim_qualificacio.sql
    │   │   ├── stored_procedure_dim_qualificacio_continuada.sql
    │   │   ├── stored_procedure_dim_semestre.sql
    │   │   ├── stored_procedure_stage_docencia.sql
    │   │   ├── stored_procedure_stage_docencia_post.sql
    │   │   ├── stored_procedured_dim_acceso.sql
    │   │   └── stored_procedured_dim_assignatura.sql
    │   ├── text.sql
    │   └── vistas
    │       ├── dim_pais_nacimiento.sql
    │       ├── dim_pais_nacionalitat.sql
    │       ├── dim_persona_estudiant.sql
    │       └── explanation.md
    ├── README.md
    ├── Transform
    │   ├── Models
    │   │   ├── Dimensions
    │   │   │   ├── DIM_RECURSOS_APRENENTATGE.sql
    │   │   │   ├── DIM_RECURSOS_COCO_PRODUCT_MODULS.sql
    │   │   │   ├── DIM_RECURSOS_APRENENTATGE_validaciones.sql
    │   │   │   ├── francesc_base_dades_academitques_coco.sql
    │   │   │   └── validacion_11_11_2024.sql
    │   │   ├── STAGE_POST_DADES_ACADEMIQUES.sql
    │   │   ├── STAGE_DADES_ACADEMIQUES_COCO.sql
    │   │   ├── STAGE_DADES_ACADEMIQUES_DIMAX.sql
    │   │   ├── STAGE_LIVE_EVENTS_FLATENED.sql
    │   │   └── informacion_trabajo
    │   │       └── valoracion_productos_coco.sql
    │   └── test_procedures
    ├── generate_hierarchy.py
    └── useful_database_queries
        ├── aux_search.sql
        ├── fix_procedure_assignatura.sql
        ├── get_procedures_and_link.sql
        ├── get_tables_and_link.sql
        └── python_conector.py


```