CREATE OR REPLACE PROCEDURE DB_UOC_PROD.DD_OD.CREA_DIM("IN_SELECT" VARCHAR(16777216), "IN_NOM_TAULA_DIM" VARCHAR(16777216), "IN_CAMPS_IDENTIFICADOR_UNIC" ARRAY, "IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES" ARRAY, "IN_NOM_TAULA_POST" VARCHAR(16777216), "IN_PREFIX_DIMENSIO" VARCHAR(16777216), "IN_BOOL_DEBUG" BOOLEAN DEFAULT 0)
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS '
    /**DECLARACIONS*/
    let strRetorn = "";
    //asumim que totes les taules DIM tindran aquest prefix. En cas contrari prendre per parametre
    const prefixDimensio = IN_PREFIX_DIMENSIO + "_";
    //No he trobat millor manera de formatar la sortida. Ideal que sigui \\r\\n (CRLF)
    const placeHolderNovaLinia = "#NL#";
    //No he trobat millor manera de formatar la sortida. Ideal que sigui \\t (CRLF)
    const placeHolderTab = "#T#";
    const nomTaulaSensePrefix = IN_NOM_TAULA_DIM.substring(IN_NOM_TAULA_DIM.indexOf(prefixDimensio), IN_NOM_TAULA_DIM.length);
    if (IN_BOOL_DEBUG){
        strRetorn+= "--Valor de nomTaulaSensePrefix: " + nomTaulaSensePrefix;
    }
    const nomTaulaAlias = "ALIAS_QUERY_IN";
    const nomProcedure = nomTaulaSensePrefix.toUpperCase() + "_LOADS()";
    let columnNames = [];
    let columnTypes = [];
    let columnValorDummy = [];
    let type;
    let declaracioColumnaAutoincremental = "";
    let nomColumnaAutoincremental = "ID_DIM_" + IN_NOM_TAULA_DIM.substring(IN_NOM_TAULA_DIM.indexOf(prefixDimensio) + prefixDimensio.length, IN_NOM_TAULA_DIM.length);
    if (IN_BOOL_DEBUG){
        strRetorn+= "--Valor de nomColumnaAutoincremental: " + nomColumnaAutoincremental;
    }
    declaracioColumnaAutoincremental += nomColumnaAutoincremental;
    declaracioColumnaAutoincremental += " number(20,0) autoincrement start 1 increment 1 comment ''clau subrogada que identifica de forma unica els registres de la taula.'', ";
    let comparacioClauUnicaSTGDim = "";
    /**COMPOSICIO DE LA COMPARACIO DE CLAU UNICA ENTRE STG I DIM*/
    for (let i = 0 ; i < IN_CAMPS_IDENTIFICADOR_UNIC.length ; i++){
        comparacioClauUnicaSTGDim += placeHolderNovaLinia;
        comparacioClauUnicaSTGDim += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        comparacioClauUnicaSTGDim += nomTaulaAlias + "." + IN_CAMPS_IDENTIFICADOR_UNIC[i] + " = " +
            nomTaulaSensePrefix + "." + IN_CAMPS_IDENTIFICADOR_UNIC[i];
        if (i < IN_CAMPS_IDENTIFICADOR_UNIC.length -1 || (IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES && IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES.length > 0)){
            comparacioClauUnicaSTGDim += " AND ";
        }
    }
    for (let i = 0 ; i < IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES.length ; i++){
        comparacioClauUnicaSTGDim += placeHolderNovaLinia;
        comparacioClauUnicaSTGDim += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        comparacioClauUnicaSTGDim += "(";
        comparacioClauUnicaSTGDim += nomTaulaAlias + "." + IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES[i] + " = " +
            nomTaulaSensePrefix + "." + IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES[i];
        comparacioClauUnicaSTGDim += placeHolderNovaLinia;
        comparacioClauUnicaSTGDim += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        comparacioClauUnicaSTGDim += " OR ";
        comparacioClauUnicaSTGDim += nomTaulaAlias + "." + IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES[i] + " IS NULL";
        comparacioClauUnicaSTGDim += ")";
        if (i < IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES.length -1){
            comparacioClauUnicaSTGDim += " AND ";
        }
    }
    comparacioClauUnicaSTGDim += placeHolderNovaLinia;
    comparacioClauUnicaSTGDim += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    /**REGEX*/
    // let regexTrobaTaulaDelFrom = "from (.*)[^a-zA-Z0-9\\\\._]?";
    // let taulaSTG = IN_SELECT.match(regexTrobaTaulaDelFrom)[1];
    // let regexTrobaCampsEnMatchGroup2 = "(^(?!.*select)(?!.*from)(.*),?)";
    // let campsSTG = /*Cal iterar*/ IN_SELECT.match(regexTrobaCampsEnMatchGroup2)[2];

    /**DECLARACIO I EXECUCIO DE QUERYS*/
        //Cal executar la query per poder-ne inferir els tipus de columna
    let stmtQueryIn = snowflake.createStatement({sqlText: IN_SELECT});
    let resultSetQueryIn = stmtQueryIn.execute();
    let stmtDescResultatQueryIn = snowflake.createStatement({sqlText: "DESC RESULT LAST_QUERY_ID();"});
    let resultSetDescResultatQueryIn = stmtDescResultatQueryIn.execute();
    let columnCount = resultSetDescResultatQueryIn.getRowCount();
    if (IN_BOOL_DEBUG){
        strRetorn += placeHolderNovaLinia;
        strRetorn += "--DEBUG columnCount = " + columnCount;
        strRetorn += placeHolderNovaLinia;
    }


    //Recopilacio valors necessaris per generar el CREATE TABLE
    for (let i = 1; i <= columnCount ; i++){
        resultSetDescResultatQueryIn.next();
        columnNames[i] = resultSetDescResultatQueryIn.getColumnValueAsString("name");
        columnTypes[i] = resultSetDescResultatQueryIn.getColumnValueAsString("type");
        //Els varchar de 1 no poden contenir el valor dummy proposat "ND", l''ampliem a 2
        if (columnTypes[i] == "VARCHAR(1)"){
            columnTypes[i] = "VARCHAR(2)"
        }
        type = resultSetQueryIn.getColumnSqlType(i);
        switch (type) {
            case "TEXT":
                columnValorDummy[i] = "''ND''";
                break
            case "TIMESTAMP_NTZ":
                columnValorDummy[i] = "null";
                break
            case "FIXED":
                columnValorDummy[i] = "0";
                break
        }
    }

    /**INICI STATEMENT CREATE TABLE*/
    strRetorn += "CREATE OR REPLACE TABLE ";
    strRetorn += IN_NOM_TAULA_DIM;
    strRetorn += " ( ";
    strRetorn += placeHolderNovaLinia;
    //Afegim camp ID autoincremental
    strRetorn += placeHolderTab;
    strRetorn += declaracioColumnaAutoincremental;
    strRetorn += placeHolderNovaLinia;
    //Recuperem noms de camps i tipus
    for (let i = 1; i <= columnCount ; i++){
        strRetorn += placeHolderTab;
        strRetorn += columnNames[i] + " " + columnTypes[i] + ", ";
        strRetorn += placeHolderNovaLinia;
    }
    strRetorn += placeHolderTab;
    strRetorn += "CREATION_DATE TIMESTAMP_NTZ(9) NOT NULL COMMENT ''data de creacio del registre de la informacio.'',"
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab;
    strRetorn += "UPDATE_DATE TIMESTAMP_NTZ(9) NOT NULL COMMENT ''data de carrega de la informacio.''"
    strRetorn += placeHolderNovaLinia;
    strRetorn += ");"
    strRetorn += placeHolderNovaLinia;
    /**FI STATEMENT CREATE TABLE*/
    /**INICI STATEMENT CREATE PROCEDURE*/
    strRetorn += "create or replace procedure ";
    strRetorn += nomProcedure;
    strRetorn += " returns varchar(16777216) language sql execute as caller as ";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab;
    strRetorn += "begin ";
    /**INICI DECLARACIONS PROCEDURE*/
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "--Declaracions variables";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "let start_time timestamp_ntz := convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz); "
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "let execution_time float; "
    /**FI DECLARACIONS PROCEDURE*/
    /**INICI MERGE 1 (registre dummy)*/
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "--merge 1: registre dummy";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "merge into " + IN_NOM_TAULA_DIM;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "using (";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "select";
    //valors dummy amb alias de columna
    for (let i = 1; i <= columnCount ; i++){
        strRetorn += placeHolderNovaLinia;
        strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        strRetorn += columnValorDummy[i] + " as " + columnNames[i] + ",";
    }
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) as creation_date,";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz) as update_date";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += ") as ";
    strRetorn += nomTaulaAlias;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "ON (";
    strRetorn += comparacioClauUnicaSTGDim;
    strRetorn += ")";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "when not matched";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "then insert (";
    for (let i = 1; i <= columnCount ; i++){
        strRetorn += columnNames[i] + ",";
    }
    strRetorn += "creation_date,update_date)";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "values (";
    for (let i = 1; i <= columnCount ; i++){
        strRetorn += columnValorDummy[i] + ","
    }
    strRetorn += "convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz), convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));"
    /**FI MERGE 1*/
    /**INICI MERGE 2 (volcat de dades desde STG)*/
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "-- MERGE 2: volcat de registres";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "merge into " + IN_NOM_TAULA_DIM;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "using (";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += IN_SELECT;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += ") as " + nomTaulaAlias;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += " ON (";
    strRetorn += comparacioClauUnicaSTGDim;
    strRetorn += ")";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "when matched AND (";
    //Busquem quines columnes son les que hem de comparar per buscar canvis. Excloem les que formen part de les indicades com identificador unic
    let columnesComparar = []
    for (let i = 1 ; i <= columnCount ; i ++){
        if (IN_BOOL_DEBUG){
            strRetorn += placeHolderNovaLinia;
            strRetorn +="-- DEBUG I= " + i + "COLUMNA = " + columnNames[i];
            strRetorn += placeHolderNovaLinia;
        }
        if (!IN_CAMPS_IDENTIFICADOR_UNIC.some(e => e.toUpperCase() == columnNames[i].toUpperCase()) && !IN_CAMPS_IDENTIFICADOR_UNIC_NULLABLES.some(e => e.toUpperCase() == columnNames[i].toUpperCase())){
            columnesComparar[columnesComparar.length] = columnNames[i];
        }
    }
    for (let i = 0 ; i < columnesComparar.length ; i ++){
        strRetorn += placeHolderNovaLinia;
        strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        strRetorn += nomTaulaAlias + "." + columnesComparar[i] + " <> " + nomTaulaSensePrefix + "." + columnesComparar[i];
        if (i < columnesComparar.length -1) {
            strRetorn += placeHolderNovaLinia;
            strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
            strRetorn += "OR"
        }
    }
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += ") then";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "update set";
    for (let i = 0 ; i < columnesComparar.length ; i ++){
        strRetorn += placeHolderNovaLinia;
        strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        strRetorn += columnesComparar[i] + " = " + nomTaulaAlias + "." + columnesComparar[i];
        strRetorn += ",";
    }
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "update_date = convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz)";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "when not matched";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "then insert (";
    for (let i = 1 ; i <= columnCount ; i ++){
        strRetorn += placeHolderNovaLinia;
        strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        strRetorn += columnNames[i] + ",";
    }
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "creation_date, update_date"
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += ") values (";
    for (let i = 1 ; i <= columnCount ; i ++){
        strRetorn += placeHolderNovaLinia;
        strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
        strRetorn += nomTaulaAlias + "." + columnNames[i] + ",";
    }
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ),";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += "convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', CURRENT_TIMESTAMP()::TIMESTAMP_NTZ)";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab + placeHolderTab + placeHolderTab;
    strRetorn += ");";
    /**FI MERGE 2*/
    /**INICI LOGS*/
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "--LOGS";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "execution_time := datediff(millisecond, start_time, convert_timezone(''America/Los_Angeles'',''Europe/Madrid'', current_timestamp()::timestamp_ntz));";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "insert into db_uoc_prod.dd_od.procedures_log (id_log, procedure_name, executed_by, execution_date, execution_time, remarks)";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "values (db_uoc_prod.dd_od.sequencia_id_log.nextval, ''" + nomTaulaSensePrefix + "'', current_user(), :start_time, :execution_time, ''" + nomTaulaSensePrefix + " Success'');";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "return ''Update completed successfully'';";
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab;
    strRetorn += "end;";
    /**FI LOGS*/
    /**FI STATEMENT CREATE PROCEDURE*/
    /**MISCELANIS/UTILS*/
    strRetorn += placeHolderNovaLinia;
    strRetorn += "select max(update_date) from " + IN_NOM_TAULA_DIM + ";";
    strRetorn += placeHolderNovaLinia;
    strRetorn += "select count(*) from " + IN_NOM_TAULA_DIM + ";";
    strRetorn += placeHolderNovaLinia;
    strRetorn += "select * from " + IN_NOM_TAULA_DIM + " limit 10;";
    strRetorn += placeHolderNovaLinia;
    strRetorn += "truncate table " + IN_NOM_TAULA_DIM + ";";
    strRetorn += placeHolderNovaLinia;
    strRetorn += "-- Comanda per executar el procediment enmagatzemat al entorn."
    strRetorn += placeHolderNovaLinia;
    strRetorn += "call " + nomProcedure + ";";
    strRetorn += placeHolderNovaLinia;
    strRetorn += "-- Afegir aquesta declaracio de columna a taula POST i FACT"
    strRetorn += placeHolderNovaLinia;
    strRetorn += declaracioColumnaAutoincremental.replace(" autoincrement start 1 increment 1 comment ''clau subrogada que identifica de forma unica els registres de la taula.''",
        " comment ''Camp que importem de la dimensio " + IN_NOM_TAULA_DIM + " per tal de fer de vincle entre els objectes.''");
    strRetorn += placeHolderNovaLinia;
    strRetorn += "-- Afegir aquesta sentencia UPDATE a la seccio updates del procediment que alimenta la taula POST"
    strRetorn += placeHolderNovaLinia;
    strRetorn +="UPDATE " + IN_NOM_TAULA_POST + " set "+ nomColumnaAutoincremental + " = " + IN_NOM_TAULA_DIM + "." + nomColumnaAutoincremental;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab;
    strRetorn += "FROM " + IN_NOM_TAULA_DIM;
    strRetorn += placeHolderNovaLinia;
    strRetorn += placeHolderTab + placeHolderTab;
    strRetorn += "WHERE " + comparacioClauUnicaSTGDim.replaceAll(nomTaulaAlias, IN_NOM_TAULA_POST) + ";";
    return strRetorn;
';