{% for server in groups['graylog'] %}
- {
    host_name: {{server}},
    host_port: 27017,
    host_type: replica,
  }
{% endfor %}

