import pandas as pd

def generar_drawio_xml(nombre_archivo_entrada, nombre_archivo_salida):
    # Leer los datos desde el archivo Excel
    data = pd.read_excel(nombre_archivo_entrada)
    
    # Plantilla básica para el archivo XML de draw.io
    plantilla_xml = """<mxfile>
  <diagram name="Grafo">
    <mxGraphModel dx="1044" dy="819" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        {cells}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>"""

    # Crear nodos y aristas
    nodos = {}
    cells = []
    id_counter = 2  # Los IDs empiezan en 2 porque 0 y 1 están ocupados

    # Generar los nodos
    for _, row in data.iterrows():
        hijo, padre = row['hijo'], row['padre']

        # Crear nodos únicos para hijo y padre
        for tabla in [hijo, padre]:
            if tabla not in nodos:
                nodos[tabla] = id_counter
                cells.append(
                    f'<mxCell id="{id_counter}" value="{tabla}" style="rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;" vertex="1" parent="1">'
                    f'<mxGeometry x="{id_counter * 100}" y="100" width="150" height="50" as="geometry" />'
                    f'</mxCell>'
                )
                id_counter += 1

        # Crear arista (relación)
        cells.append(
            f'<mxCell id="{id_counter}" value="" style="edgeStyle=orthogonalEdgeStyle;" edge="1" parent="1" source="{nodos[padre]}" target="{nodos[hijo]}">'
            f'<mxGeometry relative="1" as="geometry" />'
            f'</mxCell>'
        )
        id_counter += 1

    # Rellenar la plantilla con los nodos y aristas
    xml_content = plantilla_xml.format(cells="\n        ".join(cells))

    # Guardar el archivo XML
    with open(nombre_archivo_salida, 'w', encoding='utf-8') as archivo_salida:
        archivo_salida.write(xml_content)

    print(f"Archivo generado: {nombre_archivo_salida}")

# Ejecutar la función para generar el archivo draw.io
nombre_archivo_entrada = 'graph_excel.xlsx'
nombre_archivo_salida = 'graph_drawio.xml'

generar_drawio_xml(nombre_archivo_entrada, nombre_archivo_salida)
