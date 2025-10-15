import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import internal/either.{type Either, Left, Right}

pub type JsonLiteral {
  JsonString(String)
  JsonNumber(Either(Int, Float))
  JsonObject(Dict(String, JsonLiteral))
  JsonArray(List(JsonLiteral))
  JsonBool(Bool)
  JsonNull
}

fn json_decoder() -> decode.Decoder(JsonLiteral) {
  use <- decode.recursive
  decode.one_of({ decode.string |> decode.map(JsonString) }, [
    decode.int |> decode.map(fn(num) { JsonNumber(Left(num)) }),
    decode.float |> decode.map(fn(num) { JsonNumber(Right(num)) }),
    decode.bool |> decode.map(JsonBool),
    decode.list(json_decoder()) |> decode.map(JsonArray),
    decode.dict(decode.string, json_decoder()) |> decode.map(JsonObject),
    // yes this is troll, but this should hold if all other decoders are valid
    decode.success(JsonNull),
  ])
}

pub fn parse_json_literal(data: String) -> Result(JsonLiteral, json.DecodeError) {
  json.parse(data, json_decoder())
}
