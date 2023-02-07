FROM apache/airflow:2.3.4

# Update and install system packages
USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends python3-venv python3-pip s3fs gcc libc6-dev libcurl4-openssl-dev libssl-dev libkrb5-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dependecies
COPY requirements.txt /requirements.txt

USER airflow

RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel \
  && pip3 install --no-cache-dir --user gssapi \
  && pip3 install --no-cache-dir --user -r /requirements.txt

