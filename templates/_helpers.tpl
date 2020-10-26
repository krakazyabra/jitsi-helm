{{/*
Expand the name of the chart.
*/}}
{{- define "jitsi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jitsi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the jicofo cmp name
*/}}
{{- define "jitsi.name-jicofo" -}}
{{- printf "jicofo" | trunc 63 -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "jitsi.labels" -}}
{{/*
k8s-app: {{ .Chart.Name }}
app.kubernetes.io/name: {{ include "jitsi.name" . }}
*/}}
scope: {{ .Chart.Name  }}
helm.sh/chart: {{ include "jitsi.chart" . }}
app.kubernetes.io/instance: {{ .Chart.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
