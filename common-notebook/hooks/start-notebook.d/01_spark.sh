#!/bin/bash
export SPARK_OPTS="--deploy-mode=client --master k8s://https://kubernetes.default.svc:443 --conf spark.kubernetes.namespace=${ELIIZA_DSP_SPARK_NAMESPACE} --conf spark.driver.pod.name=${HOSTNAME} --conf spark.driver.host=$(hostname -i) --conf spark.ui.proxyBase=${JUPYTERHUB_SERVICE_PREFIX}proxy/4040 --conf spark.kubernetes.driver.container.image=${ELIIZA_DSP_SPARK_IMAGE} --conf spark.kubernetes.executor.container.image=${ELIIZA_DSP_SPARK_IMAGE} --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info"
export SPARK_PUBLIC_DNS=${ELIIZA_DSP_JUPYTERHUB_HOST}${JUPYTERHUB_SERVICE_PREFIX}proxy/4040/jobs/

echo "spark.driver.pod.name ${HOSTNAME}" >> /usr/local/spark/conf/spark-defaults.conf
echo "spark.driver.host $(hostname -i)" >> /usr/local/spark/conf/spark-defaults.conf
echo "spark.ui.proxyBase ${JUPYTERHUB_SERVICE_PREFIX}proxy/4040" >> /usr/local/spark/conf/spark-defaults.conf
echo "spark.kubernetes.driver.container.image ${ELIIZA_DSP_SPARK_IMAGE}" >> /usr/local/spark/conf/spark-defaults.conf
echo "spark.kubernetes.executor.container.image ${ELIIZA_DSP_SPARK_IMAGE}" >> /usr/local/spark/conf/spark-defaults.conf
