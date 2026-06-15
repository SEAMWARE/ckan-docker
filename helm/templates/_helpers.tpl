{{- define "seamware-ckan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.fullname" -}}
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

{{- define "seamware-ckan.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "seamware-ckan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "seamware-ckan.selectorLabels" -}}
app.kubernetes.io/name: {{ include "seamware-ckan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "seamware-ckan.webName" -}}
{{- include "seamware-ckan.fullname" . -}}
{{- end -}}

{{- define "seamware-ckan.postgresql.name" -}}
{{- printf "%s-postgresql" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.redis.name" -}}
{{- printf "%s-redis" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.solr.name" -}}
{{- printf "%s-solr" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.appConfigMapName" -}}
{{- printf "%s-env" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.appSecretName" -}}
{{- printf "%s-secrets" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.postgresqlInitConfigMapName" -}}
{{- printf "%s-postgresql-init" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.webStorageClaimName" -}}
{{- if .Values.web.storage.existingClaim -}}
{{- .Values.web.storage.existingClaim -}}
{{- else -}}
{{- printf "%s-storage" (include "seamware-ckan.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "seamware-ckan.postgresqlStorageClaimName" -}}
{{- printf "%s-data" (include "seamware-ckan.postgresql.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.solrStorageClaimName" -}}
{{- printf "%s-data" (include "seamware-ckan.solr.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "seamware-ckan.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "seamware-ckan.postgresql.name" . -}}
{{- else -}}
{{- required "postgresql.host is required when postgresql.enabled=false" .Values.postgresql.host -}}
{{- end -}}
{{- end -}}

{{- define "seamware-ckan.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- include "seamware-ckan.redis.name" . -}}
{{- else -}}
{{- required "redis.host is required when redis.enabled=false" .Values.redis.host -}}
{{- end -}}
{{- end -}}

{{- define "seamware-ckan.solr.host" -}}
{{- if .Values.solr.enabled -}}
{{- include "seamware-ckan.solr.name" . -}}
{{- else -}}
{{- required "solr.host is required when solr.enabled=false" .Values.solr.host -}}
{{- end -}}
{{- end -}}

{{- define "seamware-ckan.sqlalchemyURL" -}}
{{- printf "postgresql://%s:%s@%s:%v/%s" .Values.ckan.database.user .Values.ckan.database.password (include "seamware-ckan.postgresql.host" .) .Values.postgresql.port .Values.ckan.database.name -}}
{{- end -}}

{{- define "seamware-ckan.datastoreWriteURL" -}}
{{- printf "postgresql://%s:%s@%s:%v/%s" .Values.ckan.database.user .Values.ckan.database.password (include "seamware-ckan.postgresql.host" .) .Values.postgresql.port .Values.ckan.database.datastoreName -}}
{{- end -}}

{{- define "seamware-ckan.datastoreReadURL" -}}
{{- printf "postgresql://%s:%s@%s:%v/%s" .Values.ckan.database.datastoreReadOnlyUser .Values.ckan.database.datastoreReadOnlyPassword (include "seamware-ckan.postgresql.host" .) .Values.postgresql.port .Values.ckan.database.datastoreName -}}
{{- end -}}

{{- define "seamware-ckan.solrURL" -}}
{{- printf "http://%s:%v/solr/%s" (include "seamware-ckan.solr.host" .) .Values.solr.port .Values.solr.core -}}
{{- end -}}

{{- define "seamware-ckan.redisURL" -}}
{{- printf "redis://%s:%v/%v" (include "seamware-ckan.redis.host" .) .Values.redis.port .Values.redis.db -}}
{{- end -}}

{{- define "seamware-ckan.imagePullSecrets" -}}
{{- with .Values.image.pullSecrets }}
imagePullSecrets:
  {{- range . }}
  - name: {{ . | quote }}
  {{- end }}
{{- end }}
{{- end -}}
