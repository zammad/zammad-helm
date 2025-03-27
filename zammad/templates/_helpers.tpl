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
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Pod labels
*/}}
{{- define "zammad.podLabels" -}}
{{ include "zammad.labels" . }}
{{- with .Values.podLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "zammad.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zammad.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common annotations
*/}}
{{- define "zammad.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Pod annotations
*/}}
{{- define "zammad.podAnnotations" -}}
{{ include "zammad.annotations" . }}
{{- with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
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
autowizard secret name
*/}}
{{- define "zammad.autowizardSecretName" -}}
{{- if .Values.secrets.autowizard.useExisting -}}
{{ .Values.secrets.autowizard.secretName }}
{{- else -}}
{{ include "zammad.fullname" . }}-{{ .Values.secrets.autowizard.secretName }}
{{- end -}}
{{- end -}}

{{/*
elasticsearch secret name
*/}}
{{- define "zammad.elasticsearchSecretName" -}}
{{- if .Values.secrets.elasticsearch.useExisting -}}
{{ .Values.secrets.elasticsearch.secretName }}
{{- else -}}
{{ include "zammad.fullname" . }}-{{ .Values.secrets.elasticsearch.secretName }}
{{- end -}}
{{- end -}}

{{/*
postgresql secret name
*/}}
{{- define "zammad.postgresqlSecretName" -}}
{{- if .Values.secrets.postgresql.useExisting -}}
{{ .Values.secrets.postgresql.secretName }}
{{- else -}}
{{ include "zammad.fullname" . }}-{{ .Values.secrets.postgresql.secretName }}
{{- end -}}
{{- end -}}

{{/*
redis secret name
*/}}
{{- define "zammad.redisSecretName" -}}
{{- if .Values.secrets.redis.useExisting -}}
{{ .Values.secrets.redis.secretName }}
{{- else -}}
{{ include "zammad.fullname" . }}-{{ .Values.secrets.redis.secretName }}
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
  value: "http://$(MINIO_ROOT_USER):$(MINIO_ROOT_PASSWORD)@{{ include "zammad.fullname" . }}-minio:9000/zammad?region=zammad&force_path_style=true"
{{- else -}}
- name: S3_URL
  value: "http://{{ .Values.minio.auth.rootUser }}:{{ .Values.minio.auth.rootPassword }}@{{ include "zammad.fullname" . }}-minio:9000/zammad?region=zammad&force_path_style=true"
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
environment variables for the Zammad Rails stack
*/}}
{{- define "zammad.env" -}}
{{- if or .Values.zammadConfig.redis.pass .Values.secrets.redis.useExisting -}}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "zammad.redisSecretName" . }}
      key: {{ .Values.secrets.redis.secretKey }}
{{- end }}
- name: MEMCACHE_SERVERS
  value: "{{ if .Values.zammadConfig.memcached.enabled }}{{ .Release.Name }}-memcached{{ else }}{{ .Values.zammadConfig.memcached.host }}{{ end }}:{{ .Values.zammadConfig.memcached.port }}"
- name: RAILS_TRUSTED_PROXIES
  value: "{{ .Values.zammadConfig.railsserver.trustedProxies }}"
- name: REDIS_URL
  value: "redis://:$(REDIS_PASSWORD)@{{ if .Values.zammadConfig.redis.enabled }}{{ .Release.Name }}-redis-master{{ else }}{{ .Values.zammadConfig.redis.host }}{{ end }}:{{ .Values.zammadConfig.redis.port }}"
- name: POSTGRESQL_PASS
  valueFrom:
    secretKeyRef:
      name: {{ include "zammad.postgresqlSecretName" . }}
      key: {{ .Values.secrets.postgresql.secretKey }}
- name: DATABASE_URL
  value: "postgres://{{ .Values.zammadConfig.postgresql.user }}:$(POSTGRESQL_PASS)@{{ if .Values.zammadConfig.postgresql.enabled }}{{ .Release.Name }}-postgresql{{ else }}{{ .Values.zammadConfig.postgresql.host }}{{ end }}:{{ .Values.zammadConfig.postgresql.port }}/{{ .Values.zammadConfig.postgresql.db }}?{{ .Values.zammadConfig.postgresql.options }}"
{{ include "zammad.env.S3_URL" . }}
- name: TMP # All zammad containers need the possibility to create temporary files, e.g. for file uploads or image resizing.
  value: {{ .Values.zammadConfig.railsserver.tmpdir }}
{{- with .Values.extraEnv }}
{{ toYaml . }}
{{- end }}
{{- if .Values.autoWizard.enabled }}
- name: AUTOWIZARD_RELATIVE_PATH
  value: tmp/auto_wizard/auto_wizard.json
{{- end }}
{{- end -}}

{{/*
environment variable to let Rails fail during startup if migrations are pending
*/}}
{{- define "zammad.env.failOnPendingMigrations" -}}
# Let containers fail if migrations are pending.
- name: RAILS_CHECK_PENDING_MIGRATIONS
  value: 'true'
{{- end -}}

{{/*
volume mounts for the Zammad Rails stack
*/}}
{{- define "zammad.volumeMounts" -}}
- name: {{ include "zammad.fullname" . }}-tmp
  mountPath: /tmp
- name: {{ include "zammad.fullname" . }}-tmp
  mountPath: /opt/zammad/tmp
{{- if .Values.zammadConfig.storageVolume.enabled }}
- name: {{ include "zammad.fullname" . }}-storage
  mountPath: /opt/zammad/storage
{{- end -}}
{{- if .Values.autoWizard.enabled }}
- name: autowizard
  mountPath: "/opt/zammad/tmp/auto_wizard"
{{- end }}
{{- with .Values.zammadConfig.customVolumeMounts }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
volumes for the Zammad Rails stack
*/}}
{{- define "zammad.volumes" -}}
- name: {{ include "zammad.fullname" . }}-tmp
  {{- toYaml .Values.zammadConfig.tmpDirVolume | nindent 2 }}
{{- if .Values.zammadConfig.storageVolume.enabled }}
{{- if .Values.zammadConfig.storageVolume.existingClaim }}
- name: {{ include "zammad.fullname" . }}-storage
  persistentVolumeClaim:
    claimName: {{ .Values.zammadConfig.storageVolume.existingClaim | default (include "zammad.fullname" .) }}
{{- else }}
  {{ fail "Please provide an existing PersistentVolumeClaim with ReadWriteMany access if you enable .Values.zammadConfig.storageVolume." }}
{{- end -}}
{{- end -}}
{{- if .Values.autoWizard.enabled }}
- name: autowizard
  secret:
    secretName: {{ include "zammad.autowizardSecretName" . }}
    items:
    - key: {{ .Values.secrets.autowizard.secretKey }}
      path: auto_wizard.json
{{- end }}
{{- with .Values.zammadConfig.customVolumes }}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
shared configuration for Zammad Pods
*/}}
{{- define "zammad.podSpec" -}}
{{- with .Values.image.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if .Values.serviceAccount.create }}
serviceAccountName: {{ include "zammad.serviceAccountName" . }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
shared configuration for Zammad Deployment Pods
*/}}
{{- define "zammad.podSpec.deployment" -}}
{{ include "zammad.podSpec" . }}
{{- if .Values.zammadConfig.initContainers.volumePermissions.enabled }}
initContainers:
  - name: zammad-volume-permissions
    image: "{{ .Values.zammadConfig.initContainers.volumePermissions.image.repository }}:{{ .Values.zammadConfig.initContainers.volumePermissions.image.tag }}"
    imagePullPolicy: {{ .Values.zammadConfig.initContainers.volumePermissions.image.pullPolicy }}
    command:
      {{- .Values.zammadConfig.initContainers.volumePermissions.command | toYaml | nindent 6 }}
    {{- with .Values.zammadConfig.initContainers.volumePermissions.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.zammadConfig.initContainers.volumePermissions.securityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    volumeMounts:
      {{- include "zammad.volumeMounts" . | nindent 6 }}
{{- end }}
{{- end -}}

{{/*
shared configuration for Zammad containers
*/}}
{{- define "zammad.containerSpec" -}}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- with .containerConfig.startupProbe }}
startupProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .containerConfig.livenessProbe }}
livenessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .containerConfig.readinessProbe }}
readinessProbe:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .containerConfig.resources }}
resources:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .containerConfig.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
