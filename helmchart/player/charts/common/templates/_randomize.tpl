{{- define "common.randomize" }}
  {{- randAlphaNum . | trim }}
{{- end }}