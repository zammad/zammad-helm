# Zammad Helm Chart

This directory contains a Kubernetes chart to deploy [Zammad](https://zammad.org/) ticket system.


## Prerequisites Details

* Kubernetes 1.8+


## Chart Details

This chart will do the following:

* Install Zammad deployment
* Install Elasticsearch, Memcached & PostgreSQL as requirements


## Installing the Chart

To install the chart use the following:

```console
$ helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
$ helm install incubator/zammad
```


## Configuration

The following table lists the configurable parameters of the zammad chart and their default values.

|             Parameter             |              Description                 |               Default               |
|-----------------------------------|------------------------------------------|-------------------------------------|
| `useElasticsearch`                | Use Elasticsearch dependency               | `true`                              |
| `useMemcached`                    | Use Memcached dependency                 | `true`                              |
| `usePostgresql`                   | Use PostgreSQL dependency                | `true`                              |
| `image.repository`                | Container image to use                   | `zammad/zammad-docker-compose`      |
| `image.tag`                       | Container image tag to deploy            | `2.8.0-22`                          |
| `image.pullPolicy`                | Container pull policy                    | `IfNotPresent`                      |
| `service.type`                    | Service type                             | `ClusterIP`                         |
| `service.port`                    | Service port                             | `80`                                |
| `ingress.enabled`                 | Enable Ingress                           | `false`                             |
| `ingress.annotations`             | Additional ingress annotations           | ``                                  |
| `ingress.path`                    | Ingress path                             | ``                                  |
| `ingress.hosts`                   | Ingress hosts                            | ``                                  |
| `ingress.tls`                     | Ingress TLS                              | `[]`                                |
| `env`                             | Environment variables                    | `See values.yaml`                   |
| `persistence.enabled`             | Enable persistence                       | `true`                              |
| `persistence.accessMode`          | Access mode                              | `ReadWriteOnce`                     |
| `persistence.size`                 | Volume size                              | `15Gi`                              |
| `resources.nginx`                 | Resource usage of Zammad's nginx container          | `{}`                                |
| `resources.railsserver`           | Resource usage of Zammad's railsserver container    | `{}`                                |
| `resources.scheduler`             | Resource usage of Zammad's scheduler container      | `{}`                                |
| `resources.websocket`             | Resource usage of Zammad's websocket container      | `{}`                                |
| `nodeSelector`                    | Node Selector                             | `{}`                                |
| `tolerations`                     | Tolerations                              | `[]`                                |
| `affinity`                        | Affinity                                 | `{}`                                |
| `elasticsearch.image.repository`  | Elasticsearch image repo                 | `zammad/zammad-docker-compose`      |
| `elasticsearch.image.tag`         | Elasticsearch image tag                  | `zammad-elasticsearch-2.8.0-22`     |
| `elasticsearch.cluster.xpackEnable` | Enable Elasticsearch Xpack option             | `false`                             |
| `elasticsearch.cluster.env`       | Elasticsearch environment variables      | ``                                  |
| `elasticsearch.client.replicas`   | Elasticsearch client replicas            | `1`                                 |
| `elasticsearch.data.terminationGracePeriodSeconds` | Elasticsearch termination Grace Period | `60`                 |
| `elasticsearch.data.replicas`     | Elasticsearch data replicas              | `1`                                 |
| `elasticsearch.master.replicas`   | Elasticsearch master replicas            | `1`                                 |
| `memcached.replicaCount`          | Memcached replicas                       | `1`                                 |
| `postgresql.postgresqlUsername`   | PostgreSQL user                          | `zammad`                            |
| `postgresql.postgresqlPassword`   | PostgreSQL password                      | `zammad`                            |
| `postgresql.postgresqlDatabase`   | PostgreSQL DB                            | `zammad_production`                 |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

### Properly configuring Elasticsearch
The default **elasticsearch.yml** set by the Elasticsearch chart expects 2 masters.  If using just 1 master replica, there are 3 environment variables which should be set equally to avoid issues starting Elasticsearch.

Set the following environment variables under **elasticsearch.cluster.env**.  The Zammad StatefulSet will most likely fail without setting these correctly.

Refer to the Elasticsearch documentation for info on these variables.  [[1](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-gateway.html)] [[2](https://www.elastic.co/guide/en/elasticsearch/reference/5.6/modules-node.html#split-brain)]

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

## Using zammad

Once the zammad pod is ready, it can be accessed using the ingress or port forwarding:

```console
$ kubectl port-forward service/zammad 8080:80
```
