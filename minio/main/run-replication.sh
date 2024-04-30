# minio-replicate:
#   image: minio/mc:RELEASE.2023-10-14T01-57-03Z
#   entrypoint: ["/bin/bash", "/replication.sh"]
#   volumes:
#     - ./replication.sh:/replication.sh
#   env_file:
#     - .env

docker run -it --rm -v ${PWD}/replication.sh:/replication.sh \
	--entrypoint /replication.sh \
	--env-file .env minio/mc:RELEASE.2023-10-14T01-57-03Z
