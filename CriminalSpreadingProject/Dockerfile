FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip
RUN pip install apache-airflow pandas virtualenv
RUN airflow db init
RUN airflow users create \
    --username admin \
    --firstname Peter \
    --lastname Parker \
    --role Admin \
    --email spiderman@superhero.org \
    --password admin

#WORKDIR /app
#COPY dags /root/airflow/dags
#--mount type=bind,source="$(pwd)"/airflow/dags,target=/root/airflow/dags airflow

CMD airflow standalone