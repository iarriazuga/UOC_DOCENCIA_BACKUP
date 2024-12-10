import os

def generate_project_structure(base_path, output_file="README.md", exclude_dirs=None):
    """
    Genera una estructura de proyecto con formato de jerarquía para un README.

    Args:
        base_path (str): Ruta del directorio principal.
        output_file (str): Nombre del archivo donde se generará el README.
        exclude_dirs (list): Lista de carpetas a excluir de la estructura.
    """
    if exclude_dirs is None:
        exclude_dirs = []

    def generate_tree(path, prefix=""):
        """
        Genera la jerarquía del directorio en un formato tipo árbol.

        Args:
            path (str): Ruta actual del directorio.
            prefix (str): Prefijo para mantener la estructura de jerarquía.
        """
        entries = sorted(os.listdir(path))  # Ordenar por nombre
        entries = [e for e in entries if e not in exclude_dirs]  # Excluir carpetas

        for index, entry in enumerate(entries):
            entry_path = os.path.join(path, entry)
            connector = "├── " if index < len(entries) - 1 else "└── "
            output.append(f"{prefix}{connector}{entry}")
            
            if os.path.isdir(entry_path):
                sub_prefix = "│   " if index < len(entries) - 1 else "    "
                generate_tree(entry_path, prefix + sub_prefix)

    output = ["# Estructura del Proyecto", ""]
    generate_tree(base_path)
    with open(output_file, "w", encoding="utf-8") as readme:
        readme.write("\n".join(output))

if __name__ == "__main__":
    # Cambia "." por la ruta de tu directorio si es necesario
    generate_project_structure(base_path=".", output_file="UOC_Docencia\README_HIERARCHY.md", exclude_dirs=[".git"])
 