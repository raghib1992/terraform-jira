import sys
import logging
import boto3
import pymysql

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    aws_region = event["aws_region"]
    db_host = event["db_host"]
    db_username = event["db_username"]
    db_password = None
    if 'db_password' in event:
        db_password = event["db_password"]
    if 'use_aws_plugin' in event and event['use_aws_plugin']:
        use_aws_plugin = True
        create_password = None
    else:
        use_aws_plugin = False
        create_password = event["create_password"]

    create_username = event["create_username"]
    create_dbs = event["create_dbs"]

    try:
        if not db_password:
            rds_client = boto3.client('rds', region_name=aws_region)
            db_password = rds_client.generate_db_auth_token(db_host, 3306, db_username)
        ssl = {'ca': 'rds-combined-ca-bundle.pem'}
        conn = pymysql.connect(host=db_host, port=3306, user=db_username, password=db_password, ssl=ssl)
    except pymysql.MySQLError as e:
        logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
        logger.error(e)
        sys.exit()
    logger.info("SUCCESS: Connection to RDS MySQL instance succeeded")

    try:
        with conn.cursor() as cur:
            if use_aws_plugin:
                exec_string = "CREATE USER IF NOT EXISTS '{create_username}'@'%'" \
                              " IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS'".format(
                    create_username=create_username
                )
            else:
                exec_string = "CREATE USER IF NOT EXISTS '{create_username}'@'%'" \
                              " IDENTIFIED BY '{create_password}'".format(
                    create_username=create_username,
                    create_password=create_password
                )
            logger.debug(exec_string)
            cur.execute(
                exec_string
            )
            for db in create_dbs:
                exec_string = "CREATE DATABASE IF NOT EXISTS {db}".format(db=db)
                logger.debug(exec_string)
                cur.execute(exec_string)
                exec_string = "GRANT ALL PRIVILEGES ON {db}.* TO '{create_username}'@'%'".format(
                    db=db,
                    create_username=create_username,
                    create_password=create_password
                )
                logger.debug(exec_string)
                cur.execute(exec_string)
                exec_string = (
                    "CREATE TABLE IF NOT EXISTS `{db}`.`schema_version` ("
                    "`installed_rank` int(11) NOT NULL,"
                    "`version` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,"
                    "`description` varchar(200) COLLATE utf8_unicode_ci NOT NULL,"
                    "`type` varchar(20) COLLATE utf8_unicode_ci NOT NULL,"
                    "`script` varchar(1000) COLLATE utf8_unicode_ci NOT NULL,"
                    "`checksum` int(11) DEFAULT NULL,"
                    "`installed_by` varchar(100) COLLATE utf8_unicode_ci NOT NULL,"
                    "`installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                    "`execution_time` int(11) NOT NULL,"
                    "`success` tinyint(1) NOT NULL,"
                    "PRIMARY KEY (`installed_rank`),"
                    "KEY `schema_version_s_idx` (`success`)"
                    ")"
                ).format(db=db)
                logger.debug(exec_string)
                cur.execute(exec_string)
        conn.commit()
    except Exception as e:
        logger.error(e)
        return {"result": "Failed."}

    return {"result": "Success."}
