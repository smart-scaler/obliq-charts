{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}
{{- define "jaeger-common.labels.standard" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" (include "jaeger-common.names.name" .context) "helm.sh/chart" (include "jaeger-common.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ template "jaeger-common.tplvalues.merge" (dict "values" (list .customLabels $default) "context" .context) }}
{{- else -}}
app.kubernetes.io/name: {{ include "jaeger-common.names.name" . }}
helm.sh/chart: {{ include "jaeger-common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | replace "+" "_" | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "jaeger-common.labels.matchLabels" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{ merge (pick (include "jaeger-common.tplvalues.render" (dict "value" .customLabels "context" .context) | fromYaml) "app.kubernetes.io/name" "app.kubernetes.io/instance") (dict "app.kubernetes.io/name" (include "jaeger-common.names.name" .context) "app.kubernetes.io/instance" .context.Release.Name ) | toYaml }}
{{- else -}}
app.kubernetes.io/name: {{ include "jaeger-common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end -}}
