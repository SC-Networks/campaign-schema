{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "$id": "schema.json",
  "title": "SCN Workflow Config v3",
  "description": "Validates a given workflow config v3",
  "type": "object",
  "properties": {
    "configuration-version": {
      "const": "3"
    },
    "nodes": {
      "type": "array",
      "items": {
        "anyOf": [.[] | {"$ref": "#/definitions/nodes/\(.category)/\(.name)"}]
      }
    },
    "helpers": {
      "type": "array",
      "items": {
        "anyOf": [
          {
            "$ref": "#/definitions/helpers/postit"
          },
          {
            "$ref": "#/definitions/helpers/referenceObject"
          }
        ]
      }
    }
  },
  "additionalProperties": false,
  "required": [
    "nodes",
    "helpers",
    "configuration-version"
  ],
  "definitions": {
    "nodes": group_by(.category)
             | map(
                 {
                     key: .[0].category,
                     value: map(
                         {
                             key: .name,
                             value: {
                                 title: .name,
                                 type: "object",
                                 properties: ({
                                     id: {"$ref": "#/definitions/types/uuid"},
                                     type: {const: .name},
                                     config: {
                                         type: "object",
                                         properties: .config,
                                         additionalProperties: false,
                                         required: .config | keys
                                     },
                                     meta: {"$ref": "#/definitions/meta/node"}
                                 } * if .category == "endPoints" then {}
                                     elif .category == "conditions" then {connections: {"$ref": "#/definitions/connections/doubleOutput"}}
                                     else {connections: {"$ref": "#/definitions/connections/singleOutput"}} end
                                 ),
                                 additionalProperties: false,
                                 required: ([
                                     "id",
                                     "type",
                                     "config",
                                     "meta"
                                 ] + if .category == "endPoints" then [] else ["connections"] end)
                             }
                         }
                     )
                     | from_entries
                 }
             )
             | from_entries
,
    "helpers": {
      "postit": {
        "title": "postit",
        "type": "object",
        "properties": {
          "id": {
            "$ref": "#/definitions/types/uuid"
          },
          "type": {
            "const": "postit"
          },
          "config": {
            "type": "object",
            "properties": {
              "title": {
                "type": "string"
              },
              "description": {
                "type": "string"
              },
              "color": {
                "type": "string"
              }
            },
            "additionalProperties": false,
            "required": [
              "title",
              "description",
              "color"
            ]
          },
          "meta": {
            "type": "object",
            "properties": {
              "position": {
                "$ref": "#/definitions/meta/position"
              },
              "size": {
                "type": "object",
                "properties": {
                  "width": {
                    "type": "integer"
                  },
                  "height": {
                    "type": "integer"
                  }
                },
                "required": [
                  "width",
                  "height"
                ],
                "additionalProperties": false
              }
            },
            "additionalProperties": false,
            "required": [
              "position",
              "size"
            ]
          }
        },
        "additionalProperties": false,
        "required": [
          "id",
          "type",
          "config",
          "meta"
        ]
      },
      "referenceObject": {
        "title": "referenceObject",
        "type": "object",
        "properties": {
          "id": {
            "$ref": "#/definitions/types/uuid"
          },
          "type": {
            "const": "referenceObject"
          },
          "config": {
            "type": "object",
            "properties": {
              "type": {
                "oneOf": [
                  {
                    "type": "integer"
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "resourceId": {
                "$ref": "#/definitions/types/evalancheId"
              },
              "title": {
                "type": "string"
              },
              "description": {
                "type": "string"
              }
            },
            "additionalProperties": false,
            "required": [
              "type",
              "resourceId",
              "title",
              "description"
            ]
          },
          "meta": {
            "type": "object",
            "properties": {
              "position": {
                "$ref": "#/definitions/meta/position"
              }
            },
            "additionalProperties": false,
            "required": [
              "position"
            ]
          },
          "connections": {
            "type": "object",
            "properties": {
              "top": {
                "$ref": "#/definitions/meta/referenceConnectionContainer"
              },
              "right": {
                "$ref": "#/definitions/meta/referenceConnectionContainer"
              },
              "bottom": {
                "$ref": "#/definitions/meta/referenceConnectionContainer"
              },
              "left": {
                "$ref": "#/definitions/meta/referenceConnectionContainer"
              }
            },
            "additionalProperties": false,
            "required": [
              "top",
              "right",
              "bottom",
              "left"
            ]
          }
        },
        "additionalProperties": false,
        "required": [
          "id",
          "type",
          "config",
          "meta",
          "connections"
        ]
      }
    },
    "meta": {
      "node": {
        "type": "object",
        "properties": {
          "position": {
            "$ref": "#/definitions/meta/position"
          }
        },
        "additionalProperties": false,
        "required": [
          "position"
        ]
      },
      "position": {
        "type": "object",
        "properties": {
          "x": {
            "type": "integer"
          },
          "y": {
            "type": "integer"
          }
        },
        "required": [
          "x",
          "y"
        ],
        "additionalProperties": false
      },
      "referenceConnectionContainer": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "targetType": {
              "enum": [
                "referenceObject",
                "node"
              ]
            },
            "targetId": {
              "$ref": "#/definitions/types/uuid"
            },
            "targetDirection": {
              "enum": [
                "top",
                "right",
                "bottom",
                "left"
              ]
            }
          },
          "required": [
            "targetId",
            "targetType",
            "targetDirection"
          ],
          "additionalProperties": false
        }
      },
      "referenceConnection": {
        "properties": {
          "targetId": {
            "$ref": "#/definitions/types/uuid"
          },
          "direction": {
            "enum": [
              "top",
              "right",
              "bottom",
              "left"
            ]
          }
        },
        "additionalProperties": false,
        "required": [
          "targetId",
          "direction"
        ]
      }
    },
    "types": {
      "uuid": {
        "type": "string",
        "format": "uuid"
      },
      "evalancheId": {
        "oneOf": [
          {
            "type": "integer",
            "minimum": 1
          },
          {
            "type": "null"
          }
        ]
      },
      "multipass": {
        "oneOf": [
          {
            "type": "object",
            "properties": {
              "enabled": {
                "const": true
              },
              "lockDuration": {
                "$ref": "#/definitions/types/duration"
              }
            },
            "additionalProperties": false,
            "required": [
              "enabled",
              "lockDuration"
            ]
          },
          {
            "type": "object",
            "properties": {
              "enabled": {
                "description": "This needs to be an enum, const:false does not work with type-generator",
                "enum": [
                  false
                ]
              }
            },
            "additionalProperties": false,
            "required": [
              "enabled"
            ]
          }
        ]
      },
      "duration": {
        "description": "subset of a iso 8601 duration, only days and hours are allowed",
        "type": "string",
        "pattern": "^P\\d+DT\\d+H$"
      },
      "dateTime": {
        "type": "string",
        "format": "date-time"
      },
      "time": {
        "type": "string",
        "format": "time"
      },
      "wait": {
        "oneOf": [
          {
            "type": "object",
            "properties": {
              "type": {
                "const": "duration"
              },
              "value": {
                "$ref": "#/definitions/types/duration"
              }
            },
            "required": [
              "type",
              "value"
            ],
            "additionalProperties": false
          },
          {
            "type": "object",
            "properties": {
              "type": {
                "const": "dateTime"
              },
              "value": {
                "$ref": "#/definitions/types/dateTime"
              }
            },
            "required": [
              "type",
              "value"
            ],
            "additionalProperties": false
          },
          {
            "type": "object",
            "properties": {
              "type": {
                "const": "weekdaysAndTime"
              },
              "value": {
                "$ref": "#/definitions/types/weekdaysAndTime"
              }
            },
            "required": [
              "type",
              "value"
            ],
            "additionalProperties": false
          }
        ]
      },
      "since": {
        "oneOf": [
          {
            "type": "object",
            "properties": {
              "type": {
                "const": "beginning"
              }
            },
            "required": [
              "type"
            ],
            "additionalProperties": false
          },
          {
            "type": "object",
            "properties": {
              "type": {
                "const": "duration"
              },
              "value": {
                "$ref": "#/definitions/types/duration"
              }
            },
            "required": [
              "type",
              "value"
            ],
            "additionalProperties": false
          },
          {
            "type": "object",
            "properties": {
              "type": {
                "const": "dateTime"
              },
              "value": {
                "$ref": "#/definitions/types/dateTime"
              }
            },
            "required": [
              "type",
              "value"
            ],
            "additionalProperties": false
          }
        ]
      },
      "weekdaysAndTime": {
        "type": "object",
        "properties": {
          "days": {
            "type": "array",
            "uniqueItems": true,
            "items": {
              "enum": [
                "mon",
                "tue",
                "wed",
                "thu",
                "fri",
                "sat",
                "sun"
              ]
            }
          },
          "time": {
            "$ref": "#/definitions/types/time"
          }
        },
        "required": [
          "days",
          "time"
        ],
        "additionalProperties": false
      },
      "baseOperator": {
        "enum": [
          "equal",
          "lessThan",
          "lessThanOrEqual",
          "greaterThan",
          "greaterThanOrEqual"
        ]
      },
      "extendedOperator": {
        "enum": [
          "notEqual",
          "contains",
          "endsWith",
          "is",
          "isNot",
          "containsNot",
          "containsAny",
          "containsNotAny",
          "sameDay",
          "isExactly",
          "sameMonth",
          "equalsInet"
        ]
      },
      "radius": {
        "type": "integer",
        "minimum": 1,
        "maximum": 100
      },
      "url": {
        "type": "string"
      },
      "ratio": {
        "type": "integer",
        "minimum": 0,
        "maximum": 100
      }
    },
    "connections": {
      "singleOutput": {
        "type": "object",
        "properties": {
          "true": {
            "oneOf": [
              {
                "$ref": "#/definitions/types/uuid"
              },
              {
                "type": "null"
              }
            ]
          }
        },
        "required": [
          "true"
        ],
        "additionalProperties": false
      },
      "doubleOutput": {
        "type": "object",
        "properties": {
          "true": {
            "oneOf": [
              {
                "$ref": "#/definitions/types/uuid"
              },
              {
                "type": "null"
              }
            ]
          },
          "false": {
            "oneOf": [
              {
                "$ref": "#/definitions/types/uuid"
              },
              {
                "type": "null"
              }
            ]
          }
        },
        "required": [
          "true",
          "false"
        ],
        "additionalProperties": false
      }
    }
  }
}