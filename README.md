Le but de ce dépôt est de fournir un point de départ pour valider
des hypothèses de fonctionnement relatif à [Presto](https://prestodb.io/).

## étape 1 : identifier comment utiliser une image docker de presto ?

[presto/Dockerfile] est écrit à partir de `voldern/docker-presto`

* [voldern/docker-presto](https://github.com/voldern/docker-presto/blob/master/Dockerfile)

## étape 2 : construire un environnement qui supporte une requête presto

Je vais utiliser postgresql comme premier catalog.

```bash
docker-compose build
docker-compose up
```

## étape 3 : exécuter une requête autoportante pour presto

```bash
./presto-cli --server localhost:8080

presto> SELECT 1+1;

presto> SHOW CATALOGS;
  Catalog
------------
 postgresql
 system
(2 rows)

Query 20180819_092048_00003_9zkwq, FINISHED, 1 node
Splits: 19 total, 19 done (100,00%)
0:01 [0 rows, 0B] [0 rows/s, 0B/s]
```

## étape 4 : exécuter une requête presto sur le catalog postgresql

```bash
./presto-cli --server localhost:8080 --catalog postgresql --schema postgresql

> SHOW SCHEMAS FROM postgresql;
```

## étape 5 : requêter une table de postgresl

J'ai échoué à faire des requêtes sur le shéma pg_catalog.
J'ai crée une table `table1̀` dans le shéma `public` with [pgadmin](http://localhost:5050).

```
CREATE TABLE public.table1
(
    value integer
);
```

Sur presto

```
presto:postgresql> SELECT * FROM public.table1;
 value
-------
(0 rows)

Query 20180819_093334_00012_acqrk, FINISHED, 1 node
Splits: 17 total, 17 done (100,00%)
0:00 [0 rows, 0B] [0 rows/s, 0B/s]
```

## étape 6 : insérer des données dans postgresql depuis presto

```
presto:postgresql> INSERT INTO public.table1 (value) VALUES (1);
INSERT: 1 row

Query 20180819_093802_00015_acqrk, FINISHED, 1 node
Splits: 35 total, 35 done (100,00%)
0:00 [0 rows, 0B] [0 rows/s, 0B/s]


presto:postgresql> EXPLAIN INSERT INTO public.table1 (value) VALUES (1);
                                                                 Query Plan
-----------------------------------------------------------------------------------------------------------------------------------
 - Output[rows] => [rows:bigint]
     - TableCommit[postgresql:JdbcTransactionHandle{uuid=99135de9-8b94-41a0-a35b-976a0defa7e7}:jdbc:postgres.public.table1] => [row
         - LocalExchange[SINGLE] () => partialrows:bigint, fragment:varbinary
             - RemoteExchange[GATHER] => partialrows:bigint, fragment:varbinary
                 - TableWriter => [partialrows:bigint, fragment:varbinary]
                         value := field
                     - LocalExchange[SINGLE] () => field:integer
                             Cost: {rows: 1 (5B), cpu: 5.00, memory: 0.00, network: 5.00}
                         - RemoteExchange[REPARTITION] => field:integer
                                 Cost: {rows: 1 (5B), cpu: 5.00, memory: 0.00, network: 5.00}
                             - Values => [field:integer]
                                     Cost: {rows: 1 (5B), cpu: 0.00, memory: 0.00, network: 0.00}
                                     (1)
```

* [presto - command line interface](https://prestodb.io/docs/current/installationa/cli.html)

## Annexe : puis je utiliser presto avec Azure ?

D'après ces explications, il est possible de se plugger sur `Azure Blob Storage`
et `Azure Data Lake Store` au travers du connecteur Hive.

* [Presto with Azure Data Lake Store and Blob Storage](https://github.com/arsenvlad/docker-presto-adls-wasb)

## Annexe : puis je utiliser presto depuis airflow ?

Il y'a un driver python [presto-python-client](https://github.com/prestodb/presto-python-client).

```python
>>> import prestodb
>>> conn=prestodb.dbapi.connect(
...    host='localhost',
...    port=8080,
...    user='user',
...    catalog='postgresql',
...    schema='public',
... )
>>> cur = conn.cursor()
>>> cur.execute('SELECT * FROM table1')
<prestodb.client.PrestoResult object at 0x7f86504be9d0>
>>> rows = cur.fetchall()
>>> print(rows)
[[1]]
```

## Annexe : est ce que spark peut charger un RDD depuis Presto ?

Il existe une limite. Jusqu'à récemment, presto ne supporte pas les
prepared statements.

Une [MR qui corrige cette limite](https://github.com/prestodb/presto/issues/1195) est mergé dans le master.
D'après mes tests, ce fix est disponible dans la version 0.208.

```
cd /opt/spark
bin/spark-shell --driver-class-path presto-jdbc-0.208.jar --jars presto-jdbc-0.208.jar

scala> val jdbcDF = spark.sqlContext.read.format("jdbc").options(
     Map("url" -> "jdbc:presto://presto:8080",
     "dbtable" -> "postgresql.public.table1",
     "user" -> "test",
     "password" -> "")).load()

scala> jdbcDF.show()
+-----+
|value|
+-----+
|    1|
+-----+
```

* [Spark with presto](http://theckang.com/2016/spark-with-presto/)