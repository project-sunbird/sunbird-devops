{{- define "common.read.configmap.name" -}}
{{- printf "%s-config" .Chart.Name -}}
{{- end -}}