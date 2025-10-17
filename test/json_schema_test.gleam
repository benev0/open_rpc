import gleam/json
import internal/either
import internal/json_literal
import internal/json_schema2

pub fn decode_empty_test() {
  let data = "{}"
  assert Ok([]) == json.parse(data, json_schema2.schema_decoder())
}

pub fn decode_const_test() {
  let data = "{ \"const\": true }"
  assert Ok([json_schema2.Const(json_literal.JsonBool(True))])
    == json.parse(data, json_schema2.schema_decoder())
}

pub fn decode_type_test() {
  let data = "{ \"type\": \"null\" }"
  assert Ok([json_schema2.Type(either.Left(json_schema2.NullType))])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": \"boolean\" }"
  assert Ok([json_schema2.Type(either.Left(json_schema2.BooleanType))])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": \"object\" }"
  assert Ok([json_schema2.Type(either.Left(json_schema2.ObjectType))])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": \"array\" }"
  assert Ok([json_schema2.Type(either.Left(json_schema2.ArrayType))])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": \"number\" }"
  assert Ok([json_schema2.Type(either.Left(json_schema2.NumberType))])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": \"string\" }"
  assert Ok([json_schema2.Type(either.Left(json_schema2.StringType))])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": [\"string\", \"boolean\"] }"
  assert Ok([
      json_schema2.Type(
        either.Right([json_schema2.StringType, json_schema2.BooleanType]),
      ),
    ])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"type\": [] }"
  assert Ok([
      json_schema2.Type(either.Right([])),
    ])
    == json.parse(data, json_schema2.schema_decoder())
}

pub fn decode_if_then_else_test() {
  let data = "{ \"if\": { }, \"then\": { } }"
  assert Ok([json_schema2.IfThen([], [])])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"if\": { }, \"else\": { } }"
  assert Ok([json_schema2.IfElse([], [])])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"if\": { }, \"then\": { }, \"else\": { } }"
  assert Ok([json_schema2.IfThenElse([], [], [])])
    == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"then\": { }, \"else\": { } }"
  assert Ok([]) == json.parse(data, json_schema2.schema_decoder())

  let data = "{ \"if\": { } }"
  assert Ok([]) == json.parse(data, json_schema2.schema_decoder())
}
