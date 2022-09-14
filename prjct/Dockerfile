FROM apache/airflow:2.3.4

# Update and install system packages
USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends gcc libc6-dev libcurl4-openssl-dev libssl-dev libkrb5-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dependecies
COPY requirements.txt /requirements.txt

USER airflow

RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir --user gssapi \
  && pip install --no-cache-dir --user -r /requirements.txt

