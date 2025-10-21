import gleam/dict
import gleam/json
import internal/either
import internal/json_literal
import internal/json_schema

pub fn decode_empty_test() {
  let data = "{}"
  assert Ok(dict.new()) == json.parse(data, json_schema.schema_decoder())
}

pub fn decode_const_test() {
  let data = "{ \"const\": true }"
  assert Ok(
      dict.from_list([
        #("const", json_schema.Const(json_literal.JsonBool(True))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())
}

pub fn decode_type_test() {
  let data = "{ \"type\": \"null\" }"
  assert Ok(
      dict.from_list([
        #("type", json_schema.Type(either.Left(json_schema.NullType))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": \"boolean\" }"
  assert Ok(
      dict.from_list([
        #("type", json_schema.Type(either.Left(json_schema.BooleanType))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": \"object\" }"
  assert Ok(
      dict.from_list([
        #("type", json_schema.Type(either.Left(json_schema.ObjectType))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": \"array\" }"
  assert Ok(
      dict.from_list([
        #("type", json_schema.Type(either.Left(json_schema.ArrayType))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": \"number\" }"
  assert Ok(
      dict.from_list([
        #("type", json_schema.Type(either.Left(json_schema.NumberType))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": \"string\" }"
  assert Ok(
      dict.from_list([
        #("type", json_schema.Type(either.Left(json_schema.StringType))),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": [\"string\", \"boolean\"] }"
  assert Ok(
      dict.from_list([
        #(
          "type",
          json_schema.Type(
            either.Right([json_schema.StringType, json_schema.BooleanType]),
          ),
        ),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"type\": [] }"
  assert Ok(dict.from_list([#("type", json_schema.Type(either.Right([])))]))
    == json.parse(data, json_schema.schema_decoder())
}

pub fn decode_if_then_else_test() {
  let data = "{ \"if\": { }, \"then\": { } }"
  assert Ok(
      dict.from_list([#("if", json_schema.IfThen(dict.new(), dict.new()))]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"if\": { }, \"else\": { } }"
  assert Ok(
      dict.from_list([#("if", json_schema.IfElse(dict.new(), dict.new()))]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"if\": { }, \"then\": { }, \"else\": { } }"
  assert Ok(
      dict.from_list([
        #("if", json_schema.IfThenElse(dict.new(), dict.new(), dict.new())),
      ]),
    )
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"then\": { }, \"else\": { } }"
  assert Ok(dict.from_list([]))
    == json.parse(data, json_schema.schema_decoder())

  let data = "{ \"if\": { } }"
  assert Ok(dict.from_list([]))
    == json.parse(data, json_schema.schema_decoder())
}
