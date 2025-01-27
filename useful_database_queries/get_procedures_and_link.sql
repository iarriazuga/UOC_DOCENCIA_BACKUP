SELECT 

    PROCEDURE_CATALOG || '.'||  PROCEDURE_SCHEMA || '.' ||  PROCEDURE_NAME AS PROCEDURE_FULL_PATH
    , 'https://app.snowflake.com/walwzwz/uocbi/#/data/databases/' ||  PROCEDURE_CATALOG ||  '/schemas/' ||  PROCEDURE_SCHEMA ||  '/procedure/' ||  PROCEDURE_NAME || '()'  AS PROCEDURE_LINK
    , PROCEDURE_SCHEMA
    , PROCEDURE_NAME
    , ARGUMENT_SIGNATURE
    , PROCEDURE_DEFINITION

FROM INFORMATION_SCHEMA.PROCEDURES
WHERE 1=1 
-- AND PROCEDURE_TYPE = 'PROCEDURE'
-- AND procedure_name like '%FACT_ENQUESTA_LOADS%'

ORDER BY PROCEDURE_SCHEMA, PROCEDURE_NAME;