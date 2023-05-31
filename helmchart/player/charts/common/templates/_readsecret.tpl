{{- define "common.read.secret" -}}
{{- $secret := (lookup "v1" "Secret" .Namespace .Name).data -}}
{{- if $secret -}}
  {{- if hasKey $secret .Key -}}
    {{- index $secret .Key | b64dec -}}
  {{- else -}}
    {{- if .LocalDevelopment -}}
      {{- printf "Ignoring API server errors to allow templating" -}}
    {{- else -}}
      {{- printf "ERROR | %s | The secret \"%s\" does not contain the key \"%s\" in namespace \"%s\"" .ChartName .Name .Key .Namespace | fail -}}
    {{- end -}}
  {{- end -}}
{{ else -}}
  {{- if .LocalDevelopment -}}
    {{- printf "Ignoring API server errors to allow templating" -}}
  {{- else -}}
    {{- printf "ERROR | %s | The secret \"%s\" does not exist in the namespace \"%s\"" .ChartName .Name .Namespace | fail -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "common.secret.exists" -}}
{{ $secret := (lookup "v1" "Secret" .Namespace .Name).data}}  
{{- if $secret -}}
  {{- if hasKey $secret .Key -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "common.secret.as.map" -}}
{{ $secret := (lookup "v1" "Secret" .Namespace .Name).data}}  
{{- if $secret -}}
  {{- $secret -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}