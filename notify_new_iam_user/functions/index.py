# (c) 2020 Amazon Web Services, Inc. or its affiliates. All Rights Reserved. This AWS Content is provided subject to the terms of the AWS Customer
# Agreement available at  or other written agreement between Customer and Amazon Web Services, Inc.
######
# Checks for compliance on activities that could generate violations
# API Triggers: CreateUser
# Services: Cloudwatch Events (trigger), Lambda, IAM, SNS
######

import logging
import os
import json
import boto3
from botocore.exceptions import ClientError


OUTBOUND_TOPIC_ARN = os.environ["outbound_topic_arn"]


def lambda_handler(event, context):
    """
    Primary Function.

    Sets variables that call functions that check for violations.
    If violations are found, a message is generated and sent to the Amazon SNS
        topic.
    """
    setup_logging()
    log.info('Lambda received event:')
    log.info(json.dumps(event))


    create_user_violation = check_user_create(event)

    if create_user_violation:
        subject = "Violation - IAM User is out of compliance"
        message = violation_message(event)
        send_violation(OUTBOUND_TOPIC_ARN, message, subject, event, context)
    else:
        log.info('No violations found.')


def check_user_create(event):
    """
    Violation check for IAM User Created In Prod Account.

    Function checks event for the existence of eventName CreateUser.
    If that exists then the policy is out of compliance.
    """
    violation = False
    if 'errorCode' in event['detail']:
        log.info(event['detail']['errorCode'])
        return violation

    create_user = event['detail']['eventName']

    if create_user == 'CreateUser':
        violation = True

    return(violation)


def violation_message(event):
    """
    Build A Message.

    Generates a message when a IAM User has been created.
    """
    message = 'An IAM User was created in an Account' + '\n\n'
    message += 'IAM ARN: ' + \
        event['detail']['responseElements']['user']['arn'] + ' \n'
    message += 'IAM User: ' + \
        event['detail']['responseElements']['user']['userName'] + ' \n'
    message += 'Event: ' + \
        event['detail']['eventName'] + '\n'
    message += 'Actor: ' + \
        event['detail']['userIdentity']['arn'] + '\n'
    message += 'Source IP Address: ' + \
        event['detail']['sourceIPAddress'] + '\n'
    message += 'User Agent: ' + \
        event['detail']['userAgent'] + '\n'
    return message


def send_violation(outbound_topic_arn, message, subject, event, context):
    """
    Send Violation.

    Appends additional information to the message from the Lambda Context
    Sends the message created using an API call to Amazon SNS.
    """
    findsnsregion = outbound_topic_arn.split(":")
    snsregion = findsnsregion[3]
    message += '\nAccount: ' + event["account"] + "\n"
    message += "Region: " + event["detail"]["awsRegion"] + "\n"
    sendclient = boto3.client('sns', region_name=snsregion)
    try:
        sendclient.publish(
            TopicArn=outbound_topic_arn,
            Message=message,
            Subject=subject
        )
    except ClientError as err:
        log.error(err)
        return False

def setup_logging():
    """
    Logging Function.

    Creates a global log object and sets its level.
    """
    global log
    log = logging.getLogger()
    log_levels = {'INFO': 20, 'WARNING': 30, 'ERROR': 40}

    if 'logging_level' in os.environ:
        log_level = os.environ['logging_level'].upper()
        if log_level in log_levels:
            log.setLevel(log_levels[log_level])
        else:
            log.setLevel(log_levels['ERROR'])
            log.error("The logging_level environment variable is not set to INFO, WARNING, or \
                        ERROR.  The log level is set to ERROR")
    else:
        log.setLevel(log_levels['ERROR'])
    log.info('Logging setup complete - set to log level ' + str(log.getEffectiveLevel()))
