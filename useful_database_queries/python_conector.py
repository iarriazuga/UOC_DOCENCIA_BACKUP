import snowflake.connector

# Connect to Snowflake using external browser authentication
conn = snowflake.connector.connect(
    user='iarriazuga@uoc.edu',
    account='WALWZWZ',
    warehouse='WH_DD_OD',
    database='DB_UOC_PROD',
    schema='DD_OD',
    authenticator='externalbrowser'
)

# Test the connection
cursor = conn.cursor()
cursor.execute("SELECT CURRENT_USER(), CURRENT_ACCOUNT(), CURRENT_REGION()")
print(cursor.fetchall())

print("Tables in the schema:")
print("Tables in the schema:")

# Close the connection
cursor.close()
conn.close()
 

# Get the list of tables in the schema
cursor.execute("""
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 'DD_OD'
""")



tables = cursor.fetchall()

# Iterate over each table AND get its DDL
for table in tables:
    table_name = table[0]
    cursor.execute(f"SELECT GET_DDL('TABLE', 'DB_UOC_PROD.DD_OD.{table_name}')")
    ddl = cursor.fetchone()[0]
    print(f"-- DDL for table {table_name} --")
    print(ddl)
    print("\n")

# Close the cursor AND connection
cursor.close()
conn.close()

