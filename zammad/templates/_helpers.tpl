{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "zammad.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zammad.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zammad.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "zammad.labels" -}}
helm.sh/chart: {{ include "zammad.chart" . }}
{{ include "zammad.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "zammad.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zammad.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "zammad.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "zammad.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
autowizard config
*/}}
{{- define "zammad.env.AUTOWIZARD_JSON" -}}
- name: AUTOWIZARD_JSON
{{- if .Values.secrets.autowizard.useExisting -}}
  valueFrom:
    secretKeyRef:
      key: {{ .Values.secrets.autowizard.secretKey }}
      name: {{ .Values.secrets.autowizard.secretName }}
{{- else -}}
  value: {{ .Values.autoWizard.config | b64enc | quote }}
{{- end -}}
{{- end -}}

{{/*
elasticsearch password
*/}}
{{- define "zammad.env.ELASTICSEARCH_PASSWORD" -}}
- name: ELASTICSEARCH_PASSWORD
{{- if .Values.secrets.elasticsearch.useExisting -}}
  valueFrom:
    secretKeyRef:
      key: {{ .Values.secrets.elasticsearch.secretKey }}
      name: {{ .Values.secrets.elasticsearch.secretName }}
{{- else -}}
  value: {{ .Values.zammadConfig.elasticsearch.pass | quote }}
{{- end -}}
{{- end -}}

{{/*
database URL
*/}}
{{- define "zammad.env.DATABASE_URL" -}}
{{- if .Values.secrets.postgresql.useExisting -}}
- name: POSTGRESQL_PASS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.postgresql.secretName }}
      key: {{ .Values.secrets.postgresql.secretKey }}
- name: DATABASE_URL
  value: "postgres://{{ .Values.zammadConfig.postgresql.user }}:$(POSTGRESQL_PASS)@{{ if .Values.zammadConfig.postgresql.enabled }}{{ .Release.Name }}-postgresql{{ else }}{{ .Values.zammadConfig.postgresql.host }}{{ end }}:{{ .Values.zammadConfig.postgresql.port }}/{{ .Values.zammadConfig.postgresql.db }}"
{{- else -}}
- name: DATABASE_URL
  value: "postgres://{{ .Values.zammadConfig.postgresql.user }}:{{ .Values.zammadConfig.postgresql.pass | urlquery }}@{{ if .Values.zammadConfig.postgresql.enabled }}{{ .Release.Name }}-postgresql{{ else }}{{ .Values.zammadConfig.postgresql.host }}{{ end }}:{{ .Values.zammadConfig.postgresql.port }}/{{ .Values.zammadConfig.postgresql.db }}"
{{- end -}}
{{- end -}}


{{/*
redis URL
*/}}
{{- define "zammad.env.REDIS_URL" -}}
{{- if .Values.secrets.redis.useExisting -}}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.redis.secretName }}
      key: {{ .Values.secrets.redis.secretKey }}
- name: REDIS_URL
  value: "redis://:$(REDIS_PASSWORD)@{{ if .Values.zammadConfig.redis.enabled }}{{ .Release.Name }}-redis-master{{ else }}{{ .Values.zammadConfig.redis.host }}{{ end }}:{{ .Values.zammadConfig.redis.port }}"
{{- else -}}
- name: REDIS_URL
  value: "redis://:{{ .Values.zammadConfig.redis.pass | urlquery }}@{{ if .Values.zammadConfig.redis.enabled }}{{ .Release.Name }}-redis-master{{ else }}{{ .Values.zammadConfig.redis.host }}{{ end }}:{{ .Values.zammadConfig.redis.port }}"
{{- end -}}
{{- end -}}

{{/*
S3 access URL
*/}}
{{- define "zammad.env.S3_URL" -}}
{{- with .Values.zammadConfig.minio.externalS3Url -}}
- name: S3_URL
  value: {{ . | quote }}
{{- else -}}
{{- if .Values.zammadConfig.minio.enabled -}}
{{- if .Values.minio.auth.existingSecret -}}
- name: MINIO_ROOT_USER
  valueFrom:
    secretKeyRef:
      key: root-user
      name: {{ .Values.minio.auth.existingSecret }}
- name: MINIO_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      key: root-password
      name: {{ .Values.minio.auth.existingSecret }}
- name: S3_URL
  value: "http://$(MINIO_ROOT_USER):$(MINIO_ROOT_PASSWORD)@{{ template "zammad.fullname" . }}-minio:9000/zammad?region=zammad&force_path_style=true"
{{- else -}}
- name: S3_URL
  value: "http://{{ .Values.minio.auth.rootUser }}:{{ .Values.minio.auth.rootPassword | urlquery }}@{{ template "zammad.fullname" . }}-minio:9000/zammad?region=zammad&force_path_style=true"
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
