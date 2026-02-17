{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}
{{- define "jaeger-common.ingress.backend" -}}
service:
  name: {{ .serviceName }}
  port:
  {{- if typeIs "string" .servicePort }}
  name: {{ .servicePort }}
  {{- else if or (typeIs "int" .servicePort) (typeIs "float64" .servicePort) }}
  number: {{ .servicePort | int }}
  {{- end }}
{{- end -}}

{{/*
Return true if ingress supports ingressClassName (Kubernetes 1.18+).
*/}}
{{- define "jaeger-common.ingress.supportsIngressClassname" -}}
{{- "true" -}}
{{- end -}}
