import pandas as pd

# Leer el archivo CSV
file_path = 'table_creation.csv'
df = pd.read_csv(file_path)

# Mostrar las primeras filas
print(df.head())


# Leer el archivo CSV
df = pd.read_csv(file_path)

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Expresión regular para identificar "create or replace TABLE <nombre_de_tabla>("
pattern = r"create or replace TRANSIENT TABLE (\w+) \("

# Transformar la columna 'CEATION'
df['CEATION'] = df['CEATION'].str.replace(
    pattern, 
    lambda match: f"Table {match.group(1)}{{",  # Reemplaza dinámicamente el nombre de la tabla
    regex=True
)

# Expresión regular para identificar "create or replace TABLE <nombre_de_tabla>("
pattern = r"create or replace TRANSIENT(\w+) \("

# Transformar la columna 'CEATION'
df['CEATION'] = df['CEATION'].str.replace(
    pattern, 
    lambda match: f"Table {match.group(1)}{{",  # Reemplaza dinámicamente el nombre de la tabla
    regex=True
)

# Expresión regular para identificar "create or replace TABLE <nombre_de_tabla>("
pattern = r"create or replace TABLE (\w+) \("

# Transformar la columna 'CEATION'
df['CEATION'] = df['CEATION'].str.replace(
    pattern, 
    lambda match: f"Table {match.group(1)}{{",  # Reemplaza dinámicamente el nombre de la tabla
    regex=True
)

# Expresión regular para eliminar todo después de "COMMENT" hasta el salto de línea
df['CEATION'] = df['CEATION'].str.replace(
    r'\)COMMENT=.*?(\n|$)',  # Busca "COMMENT" seguido de cualquier cosa hasta un salto de línea o el final del texto
    '}',                   # Reemplaza con una cadena vacía
    regex=True
)

# Expresión regular para eliminar todo después de "COMMENT" hasta el salto de línea
df['CEATION'] = df['CEATION'].str.replace(
    r'COMMENT.*?(\n|$)',  # Busca "COMMENT" seguido de cualquier cosa hasta un salto de línea o el final del texto
    ',\n',                   # Reemplaza con una cadena vacía
    regex=True
)



# Expresión regular para eliminar todo después de "COMMENT" hasta el salto de línea
df['CEATION'] = df['CEATION'].str.replace(
    r'NOT NULL.*?(\n|$)',  # Busca "COMMENT" seguido de cualquier cosa hasta un salto de línea o el final del texto
    ',\n',                   # Reemplaza con una cadena vacía
    regex=True
)


# Expresión regular para eliminar todo después de "COMMENT" hasta el salto de línea
df['CEATION'] = df['CEATION'].str.replace(
    r',\n',  # Busca "COMMENT" seguido de cualquier cosa hasta un salto de línea o el final del texto
    '\n',                   # Reemplaza con una cadena vacía
    regex=True
)



# Expresión regular para identificar "create or replace TABLE <nombre_de_tabla>("
pattern2 = r"\)\n;"

# Transformar la columna 'CEATION'
df['CEATION'] = df['CEATION'].str.replace(
    pattern2, 
    lambda match: f"\t,ID NUMBER(12,0) \n}};",  # Reemplaza dinámicamente el nombre de la tabla
    regex=True
)



# Expresión regular para identificar "create or replace TABLE <nombre_de_tabla>("
pattern2 = r"\);"

# Transformar la columna 'CEATION'
df['CEATION'] = df['CEATION'].str.replace(
    pattern2, 
    lambda match: f"\tID_AUX NUMBER(12,0) \n}};",  # Reemplaza dinámicamente el nombre de la tabla
    regex=True
)


# Expresión regular para eliminar todo después de "COMMENT" hasta el salto de línea
df['CEATION'] = df['CEATION'].str.replace(
    r';',  # Busca "COMMENT" seguido de cualquier cosa hasta un salto de línea o el final del texto
    '',                   # Reemplaza con una cadena vacía
    regex=True
)


# Guardar el archivo con los cambios
output_path = 'ruta_salida_sin_comment.csv'
df.to_csv(output_path, index=False)

print(f"Archivo actualizado y guardado en: {output_path}")





# Guardar el archivo transformado
output_path = 'ruta_salida.csv'
df.to_csv(output_path, index=False)

print(f"Archivo transformado y guardado en: {output_path}")

print(df.head())




# Crear una nueva columna basada en la presencia de "CODI_RECURS" en 'CEATION'
df['CONTIENE_CODI_RECURS'] = df['CEATION'].apply(lambda x: 'CODI_RECURS' if 'CODI_RECURS' in x else 'NA')


# Crear una nueva columna basada en la presencia de "CODI_RECURS" en 'CEATION'
df['CONTIENE_ASSIGNATURA'] = df['CEATION'].apply(lambda x: 'DIM_ASSIGNATURA_KEY' if 'CODI_RECURS' in x else 'NA')

 
# Guardar el archivo con la nueva columna
output_path = 'ruta_salida_con_columna.csv'
df.to_csv(output_path, index=False)

print(f"Archivo actualizado y guardado en: {output_path}")



