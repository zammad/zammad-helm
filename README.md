# Zammad Helm Chart

This directory contains a Kubernetes chart to deploy Zammad ticket system


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
| `useElasticsearch`                | use Elasticsearch dependcy               | `true`                              |
| `useMemcached`                    | use Memcached dependency                 | `true`                              |
| `usePostgresql                    | use PostgreSQL dependency                | `true`                              |
| `image.repository`                | Container image to use                   | `zammad/zammad-docker-compose`      |
| `image.tag`                       | Container image tag to deploy            | `2.8.0-35c3`                        |
| `image.pullPolicy`                | Container pull policy                    | `IfNotPresent`                      |
| `service.type`                    | Service type                             | `ClusterIP`                         |
| `service.port`                    | Service port                             | `80`                                |
| `ingress.enabled`                 | enable Ingress                           | `false`                             |
| `ingress.annotations`             | Additional ingress annotations           | ``                                  |
| `ingress.path`                    | Ingress path                             | ``                                  |
| `ingress.hosts`                   | Ingress hosts                            | ``                                  |
| `ingress.tls`                     | Ingress TLS                              | `[]`                                |
| `env`                             | Environment variables                    | `See values.yaml`                   |
| `persistance.enabled`             | Enable persistance                       | `true`                              |
| `persistance.accessMode`          | Access mode                              | `ReadWriteOnce`                     |
| `persistance.size                 | Volume size                              | `15Gi`                              |
| `resources.nginx`                 | Resource usage of Zammads nginx          | `{}`                                |
| `resources.railsserver`           | Resource usage of Zammads railsserver    | `{}`                                |
| `resources.scheduler`             | Resource usage of Zammads scheduler      | `{}`                                |
| `resources.websocket`             | Resource usage of Zammads websocket      | `{}`                                |
| `nodeSelector`                    | nodeSelector                             | `{}`                                |
| `tolerations`                     | Tolerations                              | `[]`                                |
| `affinity`                        | affinity                                 | `{}`                                |
| `elasticsearch.image.repository`  | Elasticsearch image repo                 | `zammad/zammad-docker-compose`      |
| `elasticsearch.image.tag`         | Elasticsearch image tag                  | `zammad-elasticsearch-2.8.0-35c3`   |
| `elasticsearch.cluster.xpackEnable` | Elasticsearch Xpack option             | `false`                             |
| `elasticsearch.cluster.env`       | Elasticsearch environment variables      | ``                                  |
| `elasticsearch.client.replicas`   | Elasticsearch client replicas            | `2`                                 |
| `elasticsearch.data.terminationGracePeriodSeconds` | Elasticsearch termination Grace Period | `60`                 |
| `elasticsearch.data.replicas`     | Elasticsearch data replicas              | `2`                                 |
| `elasticsearch.master.replicas`   | Elasticsearch master replicas            | `2`                                 |
| `memcached.replicaCount`          | Memcached replicas                       | `1`                                 |
| `postgresql.postgresqlUsername`   | PostgreSQL user                          | `zammad`                            |
| `postgresql.postgresqlPassword`   | PostgreSQL password                      | `zammad`                            |
| `postgresql.postgresqlDatabase`   | PostgreSQL DB                            | `zammad_production`                 |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.


## Using zammad

Once the zammad pod is ready, it can be accessed using the ingress or port forwarding:

```console
$ kubectl port-forward service/zammad 8080:80
```
