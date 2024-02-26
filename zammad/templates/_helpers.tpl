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
{{- define "zammad.autowizardConfig" -}}
{{- if .Values.secrets.autowizard.useExisting -}}
{{- $password := (lookup "v1" "Secret" .Release.Namespace .Values.secrets.autowizard.secretName .) -}}
{{- if $password -}}
{{ index $password "data" .Values.secrets.autowizard.secretKey | b64dec  }}
{{- else -}}
{{- fail "Unable to retrieve the autowizard secret (.Values.secrets.autowizard.secretName)" }}
{{- end -}}
{{- else -}}
{{ .Values.autoWizard.config | b64enc }}
{{- end -}}
{{- end -}}

{{/*
elasticsearch password
*/}}
{{- define "zammad.elasticsearchPassword" -}}
{{- if .Values.secrets.elasticsearch.useExisting -}}
{{- $password := (lookup "v1" "Secret" .Release.Namespace .Values.secrets.elasticsearch.secretName .) -}}
{{- if $password -}}
{{ index $password "data" .Values.secrets.elasticsearch.secretKey  | b64dec  }}
{{- else -}}
{{- fail "Unable to retrieve the elasticsearch secret (.Values.secrets.elasticsearch.secretName)" }}
{{- end -}}
{{- else -}}
{{ .Values.zammadConfig.elasticsearch.pass }}
{{- end -}}
{{- end -}}

{{/*
postgresql password
*/}}
{{- define "zammad.postgresqlPassword" -}}
{{- if .Values.secrets.postgresql.useExisting -}}
{{- $password := (lookup "v1" "Secret" .Release.Namespace .Values.secrets.postgresql.secretName .) -}}
{{- if $password -}}
{{ index $password "data" .Values.secrets.postgresql.secretKey  | b64dec  }}
{{- else -}}
{{- fail "Unable to retrieve the postgresql secret (.Values.secrets.postgresql.secretName)" }}
{{- end -}}
{{- else -}}
{{ .Values.zammadConfig.postgresql.pass }}
{{- end -}}
{{- end -}}

{{/*
redis password
*/}}
{{- define "zammad.redisPassword" -}}
{{- if .Values.secrets.redis.useExisting -}}
{{- $password := (lookup "v1" "Secret" .Release.Namespace .Values.secrets.redis.secretName .) -}}
{{- if $password -}}
{{ index $password "data" .Values.secrets.redis.secretKey  | b64dec  }}
{{- else -}}
{{- fail "Unable to retrieve the redis secret (.Values.secrets.redis.secretName)" }}
{{- end -}}
{{- else -}}
{{ .Values.zammadConfig.redis.pass }}
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
