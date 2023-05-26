.PHONY: schema.json meta/nodes/*.json meta/nodes.schema.json

schema.json: meta/nodes/*.json
	@jq -f meta/schema.jq --slurp meta/nodes/*.json > $@
	@yajsv -s meta/json-schema-draft-v7.json $@

meta/nodes/*.json: meta/nodes.schema.json
	@yajsv -s meta/nodes.schema.json $@

meta/nodes.schema.json:
	@yajsv -s meta/json-schema-draft-v7.json $@
