import boto3
from botocore.exceptions import ClientError
import pandas as pd
import psycopg2
import logging
from psycopg2 import sql


def lambda_handler(event, context):
    # Set the CloudWatch logger
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    # Secrets Manager settings
    secret_name = "db_credentials"
    region_name = "ap-southeast-2"

    # RDS database settings
    host = "terraform-20230509135541811400000001.cz9iamvdbbik.ap-southeast-2.rds.amazonaws.com"
    user = "gundalai"
    password = get_secret(region_name, secret_name, logger)
    database = "data_store"
    connect_timeout = 5

    s3_client = boto3.client('s3')

    df = get_dataframe(event, s3_client, logger)

    table_name, primary_key, values, attr_names, attr_names_dtypes = process_dataframe_for_sql(event, df)

    conn = connect_database(host, user, password, database, connect_timeout, logger)

    create_table(conn, table_name, attr_names_dtypes, primary_key, logger)

    add_values_to_table(conn, table_name, values, attr_names, logger)

    check_table_values(conn, table_name, logger)

    drop_table(conn, table_name, logger)

    conn.close()


def get_dataframe(event, s3_client, logger):
    """
    Create a dataframe from a csv file stored in a S3 bucket using the trigger event
    """

    try:
        # Get the object from the bucket
        bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
        file_name = event["Records"][0]["s3"]["object"]["key"]
        resp = s3_client.get_object(Bucket=bucket_name, Key=file_name)

        # Create a dataframe from the csv file
        df = pd.read_csv(resp['Body'], sep=',')

        logger.info("Created a dataframe from the stored file with the following head lines: ")
        print(df.head())

    except Exception as e:
        logger.error(f"Error retrieving file from S3: {str(e)}")
        return "Error"

    return df


def get_secret(region_name, secret_name, logger):
    """
    Get a secret stored in Secrets Manager
    """

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)

        # Decrypts the secret string using the associated KMS key.
        secret = get_secret_value_response['SecretString']
        logger.info("Secret retrieved")

    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        logger.error("Error occurred:", e)
        logger.error(e)
        return "Error"

    return secret


def connect_database(host, user, password, database, connect_timeout, logger):
    """
    Establish the database connection
    """

    try:
        conn = psycopg2.connect(host=host, user=user, password=password, database=database,
                                connect_timeout=connect_timeout)
        logger.info("Successfully connected to PostgreSQL instance")
    except psycopg2.DatabaseError as e:
        logger.error("ERROR: Unexpected error: Could not connect to PostgreSQL instance.")
        logger.error(e)
        return "Error"

    return conn


def process_dataframe_for_sql(event, df):
    """
    This function takes a DataFrame and prepares it for a SQL query.
    """

    # Define the table name based on the csv file's name
    table_name = event["Records"][0]["s3"]["object"]["key"].split('/')[-1].split('.')[0]

    # Define the first column of the dataframe as the primary key of the table
    primary_key = df.columns[0]

    # Define attribute's names/types based on the DataFrame's columns
    attr_dict = {col: "TEXT" if dtype == "object" else "INTEGER" for col, dtype in df.dtypes.items()}

    # Update the primary key
    for k, v in attr_dict.items():
        if k == primary_key:
            v += ' PRIMARY KEY'
            continue

    attr_names_dtypes = ', '.join(f"{k} {v}" for k, v in attr_dict.items())

    attr_names = list(attr_dict.keys())

    # Convert the DataFrame to a list of tuples
    values = [tuple(row) for row in df.to_numpy()]

    return table_name, primary_key, values, attr_names, attr_names_dtypes


def create_table(conn, table_name, attr_names_dtypes, primary_key, logger):
    """
    Create a table in the database if not already exists
    """

    with conn.cursor() as cursor:
        try:
            cursor.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({attr_names_dtypes})")
            conn.commit()
            print(f"Succesfully created the table: {table_name}")
        except (Exception, psycopg2.DatabaseError) as e:
            logger.error(e)
            return "Error"

        cursor.close()


def add_values_to_table(conn, table_name, values, attr_names, logger):
    """
    Add values to the table in the database
    """

    # Generate placeholders string. The placeholder represent one tuple of values.
    placeholders = sql.SQL(', ').join(sql.Placeholder() * len(values[0]))

    query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
        sql.Identifier(table_name),
        sql.SQL(', ').join(map(sql.Identifier, attr_names)),
        placeholders
    )

    with conn.cursor() as cursor:
        try:
            cursor.executemany(query, values)
            conn.commit()
            logger.info("executemany() done")
        except (Exception, psycopg2.DatabaseError) as e:
            logger.error(e)
            return "Error"

        cursor.close()


def check_table_values(conn, table_name, logger):
    """
    Check values in the table of the database
    """
    item_count = 0

    with conn.cursor() as cursor:
        try:
            cursor.execute(f"SELECT * FROM {table_name}")
            logger.info("The following items have been added to the database:")
            for row in cursor:
                item_count += 1
                logger.info(row)
            conn.commit()
            logger.info("Added %d items to rds PostgreSQL table" % (item_count))
        except (Exception, psycopg2.DatabaseError) as e:
            logger.error(e)
            return "Error"

        cursor.close()


def drop_table(conn, table_name, logger):
    """
    Drop values in the table of the database
    """

    with conn.cursor() as cursor:
        try:
            cursor.execute(f"DROP TABLE {table_name}")
            conn.commit()
            logger.info("The table is dropped from the database")
        except (Exception, psycopg2.DatabaseError) as e:
            logger.error(e)
            return "Error"

        cursor.close()
