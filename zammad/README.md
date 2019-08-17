# Zammad Helm Chart

This directory contains a Kubernetes chart to deploy [Zammad](https://zammad.org/) ticket system.

## Prerequisites Details

-   Kubernetes 1.8+
-   Cluster with at least 4GB of free RAM

## Chart Details

This chart will do the following:

-   Install Zammad statefulset
-   Install Elasticsearch, Memcached & PostgreSQL as requirements


## Installing the Chart

To install the chart use the following:

```console
$ helm repo add zammad https://zammad.github.io
$ helm upgrade --install zammad zammad/zammad --namespace zammad
```

## Configuration

The following table lists the configurable parameters of the zammad chart and their default values.

| Parameter                                          | Description                                      | Default                         |
| -------------------------------------------------- | ------------------------------------------------ | ------------------------------- |
| `useElasticsearch`                                 | Use Elasticsearch dependency                     | `true`                          |
| `useMemcached`                                     | Use Memcached dependency                         | `true`                          |
| `usePostgresql`                                    | Use PostgreSQL dependency                        | `true`                          |
| `image.repository`                                 | Container image to use                           | `zammad/zammad-docker-compose`  |
| `image.tag`                                        | Container image tag to deploy                    | `3.1.0-10`                       |
| `image.pullPolicy`                                 | Container pull policy                            | `IfNotPresent`                  |
| `service.type`                                     | Service type                                     | `ClusterIP`                     |
| `service.port`                                     | Service port                                     | `80`                            |
| `ingress.enabled`                                  | Enable Ingress                                   | `false`                         |
| `ingress.annotations`                              | Additional ingress annotations                   | ``                              |
| `ingress.path`                                     | Ingress path                                     | ``                              |
| `ingress.hosts`                                    | Ingress hosts                                    | ``                              |
| `ingress.tls`                                      | Ingress TLS                                      | `[]`                            |
| `envConfig.elasticsearch.host`                     | Elasticsearch host                               | `zammad-elasticsearch-client`   |
| `envConfig.elasticsearch.port`                     | Elasticsearch port                               | `9200`                          |
| `envConfig.memcached.host`                         | Memcached host                                   | `zammad-memcached`              |
| `envConfig.memcached.port`                         | Memcached port                                   | `11211`                         |
| `envConfig.postgresql.host`                        | PostgreSql host                                  | `zammad-postgresql`             |
| `envConfig.postgresql.port`                        | PostgreSql port                                  | `5432`                          |
| `envConfig.postgreql.pass`                         | PostgreSql pass                                  | ``                              |
| `envConfig.postgresql.user`                        | PostgreSql user                                  | `zammad`                        |
| `envConfig.postgresql.db`                          | PostgreSql database                              | `zammad_production`             |
| `envConfig.postgresql.dbCreate`                    | Create PostgreSql database                       | `false`                         |
| `autoWizard.enabled`                               | enable autowizard                                | `false`                         |
| `autoWizard.config`                                | autowizard json config                           | `""`                            |
| `persistence.enabled`                              | Enable persistence                               | `true`                          |
| `persistence.accessMode`                           | Access mode                                      | `ReadWriteOnce`                 |
| `persistence.size`                                 | Volume size                                      | `15Gi`                          |
| `resources.nginx`                                  | Resource usage of Zammad's nginx container       | `{}`                            |
| `resources.railsserver`                            | Resource usage of Zammad's railsserver container | `{}`                            |
| `resources.scheduler`                              | Resource usage of Zammad's scheduler container   | `{}`                            |
| `resources.websocket`                              | Resource usage of Zammad's websocket container   | `{}`                            |
| `nodeSelector`                                     | Node Selector                                    | `{}`                            |
| `tolerations`                                      | Tolerations                                      | `[]`                            |
| `affinity`                                         | Affinity                                         | `{}`                            |
| `elasticsearch.image.repository`                   | Elasticsearch image repo                         | `zammad/zammad-docker-compose`  |
| `elasticsearch.image.tag`                          | Elasticsearch image tag                          | `zammad-elasticsearch-3.1.0-10`  |
| `elasticsearch.cluster.xpackEnable`                | Enable Elasticsearch Xpack option                | `false`                         |
| `elasticsearch.cluster.env`                        | Elasticsearch environment variables              | ``                              |
| `elasticsearch.client.replicas`                    | Elasticsearch client replicas                    | `1`                             |
| `elasticsearch.data.terminationGracePeriodSeconds` | Elasticsearch termination Grace Period           | `60`                            |
| `elasticsearch.data.replicas`                      | Elasticsearch data replicas                      | `1`                             |
| `elasticsearch.master.replicas`                    | Elasticsearch master replicas                    | `1`                             |
| `memcached.replicaCount`                           | Memcached replicas                               | `1`                             |
| `postgresql.postgresqlUsername`                    | PostgreSQL user                                  | `zammad`                        |
| `postgresql.postgresqlPassword`                    | PostgreSQL password                              | `zammad`                        |
| `postgresql.postgresqlDatabase`                    | PostgreSQL DB                                    | `zammad_production`             |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

### Properly configuring Elasticsearch

The default **elasticsearch.yml** set by the Elasticsearch chart expects 2 masters.  If using just 1 master replica, there are 3 environment variables which should be set equally to avoid issues starting Elasticsearch.

Set the following environment variables under **elasticsearch.cluster.env**.  The Zammad StatefulSet will most likely fail without setting these correctly.

Refer to the Elasticsearch documentation for info on these variables.  \[[1](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-gateway.html)] \[[2](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html#split-brain)]

```yaml
elasticsearch:
  cluster:
    env:
      EXPECTED_MASTER_NODES: "1"
      MINIMUM_MASTER_NODES: "1"
      RECOVER_AFTER_MASTER_NODES: "1"
  master:
    replicas: 1
```

### Important note for  NFS filesystems

For persistent volumes, NFS filesystems should work correctly for **Elasticsearch** and **PostgreSQL**; however, errors will occur if Zammad itself uses an NFS-based persistent volume.  Websockets will break completely.  This is particularly bad news for receiving notifications from the application and using the Chat module.

Don't use an NFS-based storage class for Zammad's persistent volume.

This is relevant to **EFS** for AWS users, as well.

## Using zammad

Once the zammad pod is ready, it can be accessed using the ingress or port forwarding:

```console
$ kubectl port-forward service/zammad 8080:80
```
