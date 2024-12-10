import re
import csv

# Input CSV file path
input_csv = "archivo_salida6.csv"
output_csv = "archivo_salida6output.csv"

# Read AND process the CSV
with open(input_csv, 'r') as infile, open(output_csv, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    
    # Write header
    header = next(reader)
    writer.writerow(header)
    
    # Process each row
    for row in reader:
        if row:  # Ensure row is not empty
            col1, col2 = row
            # Extract table names using regex
            table1 = re.search(r'\.(\w+)$', col1.strip()).group(1)
            table2 = re.search(r'\.(\w+)$', col2.strip()).group(1)
            # Write formatted output
            writer.writerow([f"Ref: {table1}.ID_AUX > {table2}.ID_AUX"])

print(f"Processed CSV saved to {output_csv}")



 