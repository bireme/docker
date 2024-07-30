Documentation

https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html#fetching-docker-compose-yaml


Some directories in the container are mounted, which means that their contents are synchronized between your computer and the container.

./dags - you can put your DAG files here.
./logs - contains logs from task execution and scheduler.
./config - you can add custom log parser or add airflow_local_settings.py to configure cluster policy.
./plugins - you can put your custom plugins here.

This file uses the latest Airflow image (apache/airflow). If you need to install a new Python library or system library, you can build your image.


Add python packages

https://airflow.apache.org/docs/docker-stack/build.html#adding-packages-from-requirements-txt

- Create a requirements.txt file with packages to include
- Run start.sh to build the image with instalation of python packages

