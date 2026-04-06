import oracledb

def get_connection():

    connection = oracledb.connect(
        user="STD_DB",
        password="1234",
        dsn="localhost/XEPDB1"
    )

    return connection