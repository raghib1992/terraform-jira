import os
import subprocess
import logging
import tempfile
import time

import boto3

logger = logging.getLogger()
logger.setLevel(os.environ.get('LOGLEVEL', 'INFO').upper())


def lambda_handler(event, context):

    """
    :param event: a dictionary containing a 'pubkey' field with PEM-formatted public RSA key as value.
    :param context:
    :return:
    """

    if 'pubkey' not in event:
        error_message = "Missing 'pubkey' field in event."
        logger.error(error_message)
        raise Exception(error_message)

    public_rsa_key = event['pubkey']

    db_host = os.getenv('DB_HOST')

    if not db_host:
        error_message = "Required environment variable DB_HOST not found."
        logger.error(error_message)
        raise Exception(error_message)

    db_username = os.getenv('DB_USERNAME')

    if not db_username:
        error_message = "Required environment varilable DB_USERNAME not found."
        logger.error(error_message)
        raise Exception(error_message)

    s3_destination_bucket = os.getenv('S3_DESTINATION_BUCKET')

    if not s3_destination_bucket or len(s3_destination_bucket) == 0:
        error_message = "Required environment varilable S3_DESTINATION_BUCKET not found."
        logger.error(error_message)
        raise Exception(error_message)

    s3_destination_prefix = os.getenv('S3_DESTINATION_PREFIX')

    if not s3_destination_prefix:
        error_message = "Required environment varilable S3_DESTINATION_PREFIX not found."
        logger.error(error_message)
        raise Exception(error_message)

    s3_destination_prefix = s3_destination_prefix.rstrip('/') + '/'

    try:
        logger.info("Getting credentials for %s@%s", db_host, db_username)
        rds_client = boto3.client('rds')
        token = rds_client.generate_db_auth_token(db_host, 3306, db_username)
    except Exception as e:
        logger.error("Unable to get credentials for %s@%s.", db_username, db_host, exc_info=e)
        raise e

    dump_file_name, key_file_name, public_key_file_name = None, None, None

    try:
        logger.debug("Creating temporary files for shell commands.")
        dump_file, dump_file_name = tempfile.mkstemp()
        os.close(dump_file)
        key_file, key_file_name = tempfile.mkstemp()
        os.close(key_file)
        public_key_file, public_key_file_name = tempfile.mkstemp()
    except Exception as e:
        logger.error("Unable to create temporary files for dump, symmetric key, and/or public RSA key.", exc_info=e)
        cleanup(dump_file_name, key_file_name, public_key_file_name)
        raise e

    try:
        logger.debug("Writing public key to temporary file.")
        os.write(public_key_file, public_rsa_key.encode())
        os.close(public_key_file)
    except Exception as e:
        logger.error("Unable to write public RSA key to file.", exc_info=e)
        raise e

    shell_command_response = None
    try:
        shell_command = 'export RANDFILE=/tmp/.rnd && '\
                        'openssl rand -base64 32 -out {key_file_name} && '\
                        'openssl rsautl -encrypt '\
                        '-inkey {public_key_file_name} -pubin -in {key_file_name} -out {key_file_name}.enc && '\
                        './mysqldump '\
                            '--plugin-dir=./ '\
                            '--ssl-ca="rds-combined-ca-bundle.pem" -u {db_username} '\
                            '--password="{token}" '\
                            '-h {db_host} --databases System Tracker Spare Share Runtime | '\
                        'gzip -9 | '\
                        'openssl enc -aes-256-cbc -salt -out {dump_file_name} -pass file:{key_file_name} &&' \
                        'mv {key_file_name}.enc {key_file_name}'.format(
                            key_file_name=key_file_name,
                            public_key_file_name=public_key_file_name,
                            db_username=db_username,
                            token=token,
                            db_host=db_host,
                            dump_file_name=dump_file_name
                        )
        logger.debug("Running mysqldump.")
        logger.debug("===Command===\n%s", shell_command)
        shell_command_response = subprocess.run(
            shell_command,
            shell=True,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        logger.info("mysqldump complete.")
    except Exception as e:
        logger.error("Unable to dump and encrypt database.", exc_info=e)
        cleanup(dump_file_name, key_file_name, public_key_file_name)
        raise e
    finally:
        if shell_command_response:
            logger.debug("===Begin command response===\n%s\n===End command response===", shell_command_response.stdout)

    try:
        s3_client = boto3.client('s3')
        destination_file_name = str(time.time_ns()) + '.sql.gz'
        for (file_name, key) in [
            (key_file_name, s3_destination_prefix + destination_file_name + '.key'),
            (dump_file_name, s3_destination_prefix + destination_file_name)
        ]:
            logger.info("Uploading %s", 's3://' + s3_destination_bucket + '/' + key)
            s3_client.upload_file(file_name, s3_destination_bucket, key, ExtraArgs={'ACL': 'bucket-owner-full-control'})
    except Exception as e:
        logger.error("Unable to PUT object to S3.", exc_info=e)
        raise e
    finally:
        cleanup(dump_file_name, key_file_name, public_key_file_name)

    response = {
        'key': 's3://' + s3_destination_bucket + s3_destination_prefix + destination_file_name + '.key',
        'out': 's3://' + s3_destination_bucket + s3_destination_prefix + destination_file_name
    }

    logger.info("Successfully uploaded %s and %s", response['key'], response['out'])
    return response


def cleanup(*args):
    for file_name in args:
        if file_name:
            try:
                logging.debug("Removing %s.", file_name)
                os.remove(file_name)
            except Exception as e:
                logger.warning("Unable to remove file %s.", file_name, exc_info=e)
