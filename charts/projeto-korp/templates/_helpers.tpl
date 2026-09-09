{{- define "projeto-korp.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "projeto-korp.fullname" -}}
{{- if .Release.Name -}}
{{- printf "%s-%s" .Release.Name (include "projeto-korp.name" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "projeto-korp.name" . -}}
{{- end -}}
{{- end -}}

{{- define "projeto-korp.labels" -}}
app.kubernetes.io/name: {{ include "projeto-korp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
