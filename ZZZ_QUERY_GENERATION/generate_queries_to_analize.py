import os
import re

# Configuración
carpeta_raiz = 'MODELS'  # Cambia esto por la ruta de la carpeta raíz
archivo_salida = 'filtrado_resultado.txt'

# Crear o limpiar el archivo de salida
with open(archivo_salida, 'w') as salida:
    salida.write('')  # Vaciar el archivo

# Recorrer las subcarpetas y archivos
for ruta_carpeta, subcarpetas, archivos in os.walk(carpeta_raiz):
    for archivo in archivos:
        ruta_completa = os.path.join(ruta_carpeta, archivo)
        # Abrir y procesar solo archivos de texto
        with open(archivo_salida, 'a', encoding='utf-8') as salida:
            salida.write('\n\n\n\n-- ARCHIVO: '+os.path.join(ruta_carpeta, archivo)+ '\n')
        try:
            with open(ruta_completa, 'r', encoding='utf-8') as file:
                for linea in file:
                    linea = linea.split('--')[0].strip() + '\n'
                    if any(keyword in linea.upper() for keyword in ['CREATE OR REPLACE', 'FROM', 'JOIN']):
                        # Guardar la línea en el archivo de salida
                        with open(archivo_salida, 'a', encoding='utf-8') as salida:
                            salida.write(linea)
        except Exception as e:
            print(f"No se pudo procesar el archivo {ruta_completa}: {e}")

print(f"Proceso completado. Las líneas filtradas están en '{archivo_salida}'.")


def remove_characters_before_join(input_file, output_file):
    with open(input_file, 'r') as file:
        lines = file.readlines() 

    updated_lines = []
 
    for line in lines:
        # Find the index of the word 'JOIN' AND slice the line
        line = line.upper()
        join_index = line.find('JOIN')
        if join_index != -1:
            updated_lines.append(line[join_index:])  # Keep only from 'JOIN' onward
        else:
            updated_lines.append(line)  # If 'JOIN' not found, keep the line as is

    # Write the updated lines to the output file
    with open(output_file, 'w') as file:
        file.writelines(updated_lines)

# Usage
input_file = 'filtrado_resultado.txt'
output_file = 'archivo_salida.txt'
remove_characters_before_join(input_file, output_file)


def procesar_archivo(input_file, output_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    output_lines = []
    table_name = None


    for line in lines:
        
        source_tables = ''

        if line.startswith('-- ARCHIVO:'):
            # Capturamos el nombre del archivo y lo añadimos al output
            output_lines.append('\n\n' + line.strip())
        elif line.startswith('CREATE OR REPLACE TABLE'):
            # Capturamos el nombre de la tabla principal
            match = re.search(r'TABLE\s+([\w.]+)', line)
            if match:
                source_tables = match.group(1)
            output_lines.append(
                f"SELECT '{source_tables}' as table_name , count(*) from {source_tables} Union all"
            )
        elif line.startswith('FROM'):
            # Capturamos las tablas de origen
            match = re.search(r'FROM\s+([\w.]+)', line)
            if match:
                source_tables = match.group(1)
            output_lines.append(
                f"SELECT '{source_tables}' as table_name , count(*) from {source_tables} Union all"
            )
        elif any(keyword in line.upper() for keyword in [ 'JOIN']):
            # Capturamos las tablas de origen
            match = re.search(r'JOIN\s+([\w.]+)', line)
            print(match)
            if match:
                source_tables = match.group(1)
            output_lines.append(
                f"SELECT '{source_tables}' as table_name , count(*),  from {source_tables} Union all"
            )

 
        # output_lines[-1] = output_lines[-1].replace(' Union all', '')

    # Guardamos el resultado en un archivo de salida
    with open(output_file, 'w') as file:
        file.write('\n'.join(output_lines))

# Uso del script
input_file = 'archivo_salida.txt'
output_file = 'archivo_salida2.txt'
procesar_archivo(input_file, output_file)


# Nombre del archivo de entrada y salida
input_file = "archivo_salida2.txt"
output_file = "archivo_salida3.txt"

# Leer y procesar el archivo
with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        # Buscar la palabra FROM en la línea
        line = line.upper()
        if "FROM" in line:
            # Obtener la parte después de "FROM"
            after_from = line.split("FROM", 1)[1].strip()
            # Si contiene un punto, escribir la línea en el archivo de salida
            if "." in after_from:
                outfile.write(line)
        else:
            # Si no contiene FROM, escribir la línea en el archivo de salida
            outfile.write(line)




def eliminar_antes_de_from_en_archivo(archivo_entrada, archivo_salida):
    with open(archivo_entrada, 'r') as entrada, open(archivo_salida, 'w') as salida:
        for linea in entrada:
            # Si "FROM" está en la línea, elimina lo que viene antes
            if "FROM" in linea:
                nueva_linea = linea.split("FROM", 1)[1]
                salida.write(nueva_linea)
            else:
                # Si no contiene "FROM", escribe la línea tal cual
                salida.write(linea)

# Nombres de los archivos
archivo_entrada = "archivo_salida3.txt"
archivo_salida = "archivo_salida4.txt"

# Llamar a la función
eliminar_antes_de_from_en_archivo(archivo_entrada, archivo_salida)

print(f"Archivo procesado. Revisa el archivo '{archivo_salida}'.")



import pandas as pd

# Ruta del archivo de texto
file_path = 'archivo_salida4.txt'

# Leer el archivo de texto
with open(file_path, 'r') as file:
    content = file.read()

# Dividir el contenido por secciones de archivos
sections = content.split('-- ARCHIVO:')
sections = [section.strip() for section in sections if section.strip()]

# Preparar la lista de datos para la tabla
table_data = []

for section in sections:
    # Dividir líneas dentro de cada sección
    lines = section.split('\n')
    
    # La primera línea es la referencia
    reference = lines[0].strip()
    
    # El resto son las fuentes
    sources = [line.strip() for line in lines[1:] if line.strip()]
    
    # Generar las filas de la tabla
    for Origen_events in sources:
        table_data.append([source, reference])

# Crear el DataFrame
df = pd.DataFrame(table_data, columns=['Source', 'Reference'])

# Guardar el resultado en un archivo CSV o mostrarlo
output_path = 'output_table.csv'
df.to_csv(output_path, index=False)

print(f"Tabla generada y guardada en '{output_path}'.")



def procesar_archivo_multiples_tablas(archivo_entrada, archivo_salida):
    with open(archivo_entrada, 'r') as entrada:
        lineas = [linea.strip() for linea in entrada if linea.strip()]  # Leer y limpiar líneas

    resultado = []
    bloque_actual = []  # Para almacenar las líneas de un bloque

    for linea in lineas:
        if linea.startswith("-- ARCHIVO:"):  # Detectar inicio de un nuevo bloque
            if bloque_actual:
                # Procesar el bloque anterior
                resultado.extend(procesar_bloque(bloque_actual))
            bloque_actual = [linea]  # Reiniciar el bloque actual
        else:
            bloque_actual.append(linea)

    # Procesar el último bloque si existe
    if bloque_actual:
        resultado.extend(procesar_bloque(bloque_actual))

    # Guardar el resultado en el archivo de salida
    with open(archivo_salida, 'w') as salida:
        salida.write("\n".join(resultado))

    print(f"Archivo procesado. Resultado guardado en: {archivo_salida}")


def procesar_bloque(bloque):
    if len(bloque) < 2:
        return []  # Si el bloque tiene menos de dos líneas, no hay nada que procesar

    columna_referencia = bloque[1]  # Segunda línea como columna de referencia
    tablas_restantes = bloque[2:]  # Resto de las líneas a procesar

    # Generar combinaciones para el bloque
    return [
        f"{tabla} , {columna_referencia}" for tabla in tablas_restantes
    ]



# Ejecución del script
archivo_entrada = 'archivo_salida4.txt'
archivo_salida = 'archivo_salida5.txt'

procesar_archivo_multiples_tablas(archivo_entrada, archivo_salida)




# Ejecución del script
archivo_entrada = 'archivo_salida5.txt'
archivo_salida = 'archivo_salida6.csv'
# Read the file
with open(archivo_entrada, "r") as file:
    content = file.read()

# Remove "UNION ALL"
content = content.replace(" UNION ALL", "")


# Procesar las filas
rows = [line.split(" , ") for line in content.splitlines()]

# Crear un DataFrame con columnas col1 y col2
df = pd.DataFrame(rows, columns=['reference', 'table_name'])

# Guardar el DataFrame en un archivo CSV
df.to_csv(archivo_salida, index=False)

print(f"Archivo guardado como '{archivo_salida}'.")



import pandas as pd

# Leer el archivo CSV
# Asegúrate de que 'tu_archivo.csv' sea el nombre correcto del archivo
# y que la columna relevante se llame 'table_name'
csv_path = 'archivo_salida6.csv'
df = pd.read_csv(csv_path)

# Supongamos que la columna con los nombres de las tablas se llama 'table_name'
if 'table_name' in df.columns:
    # Generar las referencias
    df['reference'] = df['table_name'].apply(
        lambda table: f"Ref: {table}.ID_AUX> {table}.ID_AUX // many-to-one"
    )

    # Guardar las referencias en un nuevo archivo CSV
    output_path = "referencias_generadas.csv"
    df[['reference']].to_csv(output_path, index=False)

    print(f"Referencias generadas y guardadas en '{output_path}'.")
else:
    print("El archivo CSV no contiene la columna 'table_name'.")
