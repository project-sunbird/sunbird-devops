CREATE KEYSPACE IF NOT EXISTS {{ hierarchy_keyspace_name }} WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': '1'
};

CREATE KEYSPACE IF NOT EXISTS {{ question_keyspace_name }} WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': '1'
};

CREATE TABLE IF NOT EXISTS {{ hierarchy_keyspace_name }}.questionset_hierarchy (
  identifier text,
  hierarchy text,
  instructions text,
  outcomeDeclaration text,
  PRIMARY KEY (identifier)
);

CREATE TABLE IF NOT EXISTS {{ question_keyspace_name }}.question_data (
  identifier text,
  body blob,
  editorState text,
  answer blob,
  solutions text,
  instructions text,
  hints text,
  media text,
  responseDeclaration text,
  interactions text,
  outcomeDeclaration text,
  feedback text,
  PRIMARY KEY (identifier)
);

{% if groups['cassandra-node-2'] is defined %}
ALTER KEYSPACE {{ hierarchy_keyspace_name }} WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'datacenter1' : 2
};
ALTER KEYSPACE {{ question_keyspace_name }} WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'datacenter1' : 2
};
{% endif %}