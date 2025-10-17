import gleam/dict
import internal/either.{Left, Right}
import internal/json_literal.{
  JsonArray, JsonBool, JsonNull, JsonNumber, JsonObject, JsonString,
}

pub fn json_literal_bool_test() {
  let data = "true"
  assert Ok(JsonBool(True)) == json_literal.parse_json_literal(data)
  let data = "false"
  assert Ok(JsonBool(False)) == json_literal.parse_json_literal(data)
}

pub fn json_literal_number_test() {
  let data = "3"
  assert Ok(JsonNumber(Left(3))) == json_literal.parse_json_literal(data)
  let data = "3.0"
  assert Ok(JsonNumber(Right(3.0))) == json_literal.parse_json_literal(data)
}

pub fn json_literal_strign_test() {
  let data = "\"data\""
  assert Ok(JsonString("data")) == json_literal.parse_json_literal(data)
  let data = "\"\""
  assert Ok(JsonString("")) == json_literal.parse_json_literal(data)
}

pub fn json_literal_array_test() {
  let data = "[]"
  assert Ok(JsonArray([])) == json_literal.parse_json_literal(data)
  let data = "[1.0,2]"
  assert Ok(JsonArray([JsonNumber(Right(1.0)), JsonNumber(Left(2))]))
    == json_literal.parse_json_literal(data)
}

pub fn json_literal_object_test() {
  let data = "{}"
  assert Ok(JsonObject(dict.new())) == json_literal.parse_json_literal(data)
  let data = "{ \"a\": true, \"b\": 1 }"
  let expected =
    dict.new()
    |> dict.insert("a", JsonBool(True))
    |> dict.insert("b", JsonNumber(Left(1)))
    |> JsonObject
  assert Ok(expected) == json_literal.parse_json_literal(data)
}

pub fn json_literal_null_test() {
  let data = "null"
  assert Ok(JsonNull) == json_literal.parse_json_literal(data)
}

pub fn json_literal_deep_test() {
  let data =
    "{
    \"a\" : { \"a\" : [ true, false, null, 1, 0.0, {}, \"false\" ] },
    \"b\" : false
  }"
  let expected =
    dict.new()
    |> dict.insert(
      "a",
      JsonObject(
        dict.new()
        |> dict.insert(
          "a",
          JsonArray([
            JsonBool(True),
            JsonBool(False),
            JsonNull,
            JsonNumber(Left(1)),
            JsonNumber(Right(0.0)),
            JsonObject(dict.new()),
            JsonString("false"),
          ]),
        ),
      ),
    )
    |> dict.insert("b", JsonBool(False))
    |> JsonObject
  assert Ok(expected) == json_literal.parse_json_literal(data)
}

pub fn json_literal_bad_test() {
  let data = "mull"
  let assert Error(_) = json_literal.parse_json_literal(data)
}
