{{/*
Expand the name of the chart.
*/}}
{{- define "ai-hub-manifest.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified release name.
*/}}
{{- define "ai-hub-manifest.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "ai-hub-manifest.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Generate chart label.
*/}}
{{- define "ai-hub-manifest.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{/*
Common labels used by all resources.
*/}}
{{- define "ai-hub-manifest.labels" -}}
{{- $labels := dict "app.kubernetes.io/managed-by" .Release.Service "app.kubernetes.io/instance" .Release.Name "helm.sh/chart" (include "ai-hub-manifest.chart" .) -}}
{{- if .Values.commonLabels }}
{{- $labels = merge $labels .Values.commonLabels }}
{{- end }}
{{- toYaml $labels -}}
{{- end -}}

{{/*
Namespace helper to allow overriding the release namespace via values.
*/}}
{{- define "ai-hub-manifest.targetNamespace" -}}
{{- if .Values.namespace.name -}}
{{- .Values.namespace.name -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

