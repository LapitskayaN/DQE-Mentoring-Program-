# Deequ task
executing pyspark-notebook and running tests. 
Results are provided in pyspark-notebook in readable format.

# requirements 
spark_version=3.0.0
hadoop_version=3.2
pydeequ==1.0.1
pyspark==3.4.0

##Installing
prepare docker image to run jupyter pyspark-notebooks
Rebuild docker "pyspark-notebook" image to support spark 3.0.0 version for PyDeequ needs
docker build --rm --force-rm -t jupyter/pyspark-notebook:spark-3.0.0 . --build-arg spark_version=3.0.0 --build-arg hadoop_version=3.2 --build-arg spark_checksum=bfe45406c67cc4ae00411ad18cc438f51e7d4b6f14eb61e7bf6b5450897c2e8d3ab020152657c0239f253735c263512ffabf538ac5b9fffa38b8295736a9c387 --build-arg 

##add sqlserverjdbc.jar
corelibs\odbc

Run rebuilt docker image:
"docker run -v %cd%:/home/jovyan/work -p 8888:8888 -p 4040:4040 --user root -e JUPYTER_ENABLE_LAB=yes --name pyspark jupyter/pyspark-notebook"

##prepare docker container 
docker run -v %cd%:/home/jovyan/work -p 8888:8888 -p 4040:4040 --user root -e JUPYTER_ENABLE_LAB=yes --name pyspark jupyter/pyspark-notebook:spark-3.0.0

##notebook
folder \deequ
Run pyspark-notebook docker container and open Module6_Deequ.ipynb notebook.
after container is created open notebook with provided link in browser


