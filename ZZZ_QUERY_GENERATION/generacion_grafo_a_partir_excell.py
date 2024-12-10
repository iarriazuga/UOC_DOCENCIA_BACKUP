import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt

def generar_grafo_desde_excel(nombre_archivo):
    # Leer los datos desde el archivo Excel
    data = pd.read_excel(nombre_archivo)

    # Crear un grafo dirigido
    G = nx.DiGraph()

    # Agregar las relaciones hijo -> padre al grafo
    for _, row in data.iterrows():
        G.add_edge(row['padre'], row['hijo'])

    # Crear posiciones jerárquicas (padre a la derecha)
    layer = {}
    for edge in G.edges:
        padre, hijo = edge
        layer[hijo] = layer.get(hijo, 0)  # Mantener el nivel del hijo
        layer[padre] = max(layer.get(padre, 0), layer[hijo] + 1)  # Padres a la derecha

    pos = {node: (layer[node], -i) for i, node in enumerate(layer.keys())}

    # Dibujar el grafo
    plt.figure(figsize=(15, 10))
    nx.draw(
        G,
        pos,
        with_labels=True,
        node_size=3000,
        font_size=8,
        arrowsize=10,
        node_color="lightblue",
    )
    plt.title("Grafo jerárquico (Hijo a Padre)", fontsize=14)
    plt.show()

# Nombre del archivo Excel
nombre_archivo = 'graph_excel.xlsx'

# Generar el grafo
generar_grafo_desde_excel(nombre_archivo)
