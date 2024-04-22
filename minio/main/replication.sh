#!/bin/bash
echo -e "\n*****************************************"
echo -e "****** started replication process ******"
echo -e "*****************************************\n"

HOSTS=`env | grep MC_HOST`
# like: minio1 minio2 ...
INSTANCES=`for host in $HOSTS; do echo $host | cut -d "=" -f 1 | cut -d "_" -f 3; done`
REPLICATED_INSTANCES=''
NON_REPLICATED_INSTANCES=''

# waiting for all hosts to start responding
for host in $HOSTS
do
  until curl -s `echo ${host} | cut -d "=" -f 2` > /dev/null; do sleep 5 &&
    echo "host `echo $host | cut -d "@" -f 2` not up yet. retrying"; done
done

# set instances
for host in $HOSTS
do
   MINIO_ID=`echo $host | cut -d "=" -f 1 | cut -d "_" -f 3`;
   MINIO_PROTOCOL=`echo $host | cut -d "=" -f 2 | cut -d ":" -f 1`;
   MINIO_URL=`echo $host | cut -d "@" -f 2`;
   MINIO_USER=`echo $host | cut -d "/" -f 3 | cut -d ":" -f 1`;
   MINIO_PASSWORD=`echo $host | cut -d "/" -f 3 | cut -d ":" -f 2 | cut -d "@" -f 1`;

   mc alias set ${MINIO_ID} ${MINIO_PROTOCOL}://${MINIO_URL} ${MINIO_USER} ${MINIO_PASSWORD}
done


# detect the replicated/non-replicated instances
for instance in $INSTANCES;
do
  mc admin replicate info $instance | grep http > /dev/null
  if [ $? == 0 ];
  then
    REPLICATED_INSTANCES="${REPLICATED_INSTANCES} ${instance}"
  else
    NON_REPLICATED_INSTANCES="${NON_REPLICATED_INSTANCES} ${instance}"
    echo "non-replicated instance found: $instance"
  fi
done

# decide wether there is an instance to be added to replication or not
if [ "x${NON_REPLICATED_INSTANCES}" != "x" ];
then
  mc admin replicate add $REPLICATED_INSTANCES $NON_REPLICATED_INSTANCES
  echo -e "\n************************************************"
  echo -e "****** new instances added to replication ******"
  echo -e "************************************************\n"
  echo "new replicated instances:"
  echo $NON_REPLICATED_INSTANCES
else
  echo -e "\n***************************************"
  echo -e "****** replication already setup ******"
  echo -e "***************************************\n"
fi