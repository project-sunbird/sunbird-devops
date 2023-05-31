{{- define "common.valid.csps" -}}
{{- $validcsps := "azure or aws or gcloud" -}}
{{- printf "%s" $validcsps -}}
{{- end -}}

{{- define "common.csp.validation" -}}
{{- $csplist := list "azure" "aws" "gcloud" -}}
{{- has . $csplist -}}
{{- end -}}