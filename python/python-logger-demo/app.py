# Generates a log message every 10s showing : timestamp, pod name, random hex string

import os
import time
import logging
import datetime
import secrets

logging.basicConfig(level=logging.INFO)

while True:
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    random_hex = secrets.token_hex(5)  # Generating 10 random hexadecimal characters
    pod_name = os.environ.get('HOSTNAME')
    message = f"random info: {random_hex}"
    log_message = f"{timestamp} {pod_name} {message}"
    logging.info(log_message)
    time.sleep(10)
