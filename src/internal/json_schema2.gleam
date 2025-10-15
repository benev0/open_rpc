import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/list
import gleam/option.{None, Some}
import internal/either.{type Either}
import internal/json_literal.{type JsonLiteral}

pub type URIReference

pub type URI

pub type Schema =
  List(Validation)

pub type Draft7 {
  Draft7(
    id: URIReference,
    schema: URI,
    ref: URIReference,
    comment: String,
    validation: Schema,
  )
}

pub type Number =
  Either(Int, Float)

pub type Type {
  NullType
  BooleanType
  ObjectType
  ArrayType
  NumberType
  StringType
}

// currently only the 2017 properties
// https://www.learnjsonschema.com/draft7
pub type Validation {
  Type(Either(Type, List(Type)))
  Enum(List(JsonLiteral))
  Const(JsonLiteral)
  MultipleOf(Number)
  Maximum(Number)
  ExclusiveMaximum(Number)
  Minimum(Number)
  ExclusiveMinimum(Number)
  MaxLength(Int)
  MinLength(Int)
  Pattern(String)
  Items(Either(Schema, List(Schema)))
  AdditionalItems(Schema)
  MaxItems(Int)
  MinItems(Int)
  UniqueItems(Bool)
  Contains(Schema)
  MaxProperties(Int)
  MinProperties(Int)
  Required(List(String))
  Properties(Dict(String, Schema))
  PatternProperties(Dict(String, Schema))
  AdditionalProperties(Schema)
  Dependencies(Dict(String, Either(Schema, List(String))))
  PropertyNames(Schema)

  // all valid variants of if then else
  IfThen(Schema, Schema)
  IfElse(Schema, Schema)
  IfThenElse(Schema, Schema, Schema)

  AllOf(List(Schema))
  AnyOf(List(Schema))
  OneOf(List(Schema))
  Not(Schema)
  Format(String)
  ContentEncoding(String)
  ContentMediaType(String)
  Definitions(Dict(String, Schema))
  Title(String)
  Description(String)
  Default(JsonLiteral)
  ReadOnly(Bool)
  WriteOnly(Bool)
  Examples(List(JsonLiteral))

  // special
  Noop
}

fn type_enum_decoder() {
  use type_ <- decode.then(decode.string)
  case type_ {
    "null" -> decode.success(NullType)
    "boolean" -> decode.success(BooleanType)
    "object" -> decode.success(ObjectType)
    "array" -> decode.success(ArrayType)
    "number" -> decode.success(NumberType)
    "string" -> decode.success(StringType)
    _ ->
      decode.failure(
        NullType,
        "expected one of 'null', 'boolean', 'object', 'array', 'number', 'string'",
      )
  }
}

/// will have issues if left accepts right
/// safety is a <> b should hold
pub fn either_decoder(
  left_decoder: Decoder(a),
  right_decoder: Decoder(b),
) -> Decoder(Either(a, b)) {
  decode.one_of(left_decoder |> decode.map(either.Left), [
    right_decoder |> decode.map(either.Right),
  ])
}

pub fn extend_schema_decoder(
  schema: Schema,
  field_name: String,
  lazy_decoder: fn() -> Decoder(Validation),
  next: fn(Schema) -> Decoder(Schema),
) -> Decoder(Schema) {
  use extended_schema <- decode.optional_field(
    field_name,
    schema,
    lazy_decoder() |> decode.map(list.prepend(schema, _)),
  )
  next(extended_schema)
}

pub fn number_decoder() {
  decode.one_of(decode.int |> decode.map(either.Left), [
    decode.float |> decode.map(either.Right),
  ])
}

fn type_decoder() -> Decoder(Validation) {
  either_decoder(type_enum_decoder(), decode.list(type_enum_decoder()))
  |> decode.map(Type)
}

fn enum_decoder() -> Decoder(Validation) {
  decode.list(json_literal.json_decoder()) |> decode.map(Enum)
}

fn const_decoder() -> Decoder(Validation) {
  json_literal.json_decoder() |> decode.map(Const)
}

fn multiple_of_decoder() -> Decoder(Validation) {
  number_decoder() |> decode.map(MultipleOf)
}

fn maximum_decoder() -> Decoder(Validation) {
  number_decoder() |> decode.map(Maximum)
}

fn exclusive_maximum_decoder() -> Decoder(Validation) {
  number_decoder() |> decode.map(ExclusiveMaximum)
}

fn minimum_decoder() -> Decoder(Validation) {
  number_decoder() |> decode.map(Minimum)
}

fn exclusive_minimum_decoder() -> Decoder(Validation) {
  number_decoder() |> decode.map(ExclusiveMinimum)
}

fn max_length_decoder() -> Decoder(Validation) {
  decode.int |> decode.map(MaxLength)
}

fn min_length_decoder() -> Decoder(Validation) {
  decode.int |> decode.map(MinLength)
}

fn pattern_decoder() -> Decoder(Validation) {
  decode.string |> decode.map(Pattern)
}

fn items_decoder() -> Decoder(Validation) {
  either_decoder(schema_decoder(), decode.list(schema_decoder()))
  |> decode.map(Items)
}

fn additional_items_decoder() -> Decoder(Validation) {
  schema_decoder() |> decode.map(AdditionalItems)
}

fn max_items_decoder() -> Decoder(Validation) {
  decode.int |> decode.map(MaxItems)
}

fn min_items_decoder() -> Decoder(Validation) {
  decode.int |> decode.map(MinItems)
}

fn unique_items_decoder() -> Decoder(Validation) {
  decode.bool |> decode.map(UniqueItems)
}

fn contains_decoder() -> Decoder(Validation) {
  schema_decoder() |> decode.map(Contains)
}

fn max_properties_decoder() -> Decoder(Validation) {
  decode.int |> decode.map(MaxProperties)
}

fn min_properties_decoder() -> Decoder(Validation) {
  decode.int |> decode.map(MinProperties)
}

fn required_decoder() -> Decoder(Validation) {
  decode.list(decode.string) |> decode.map(Required)
}

fn properties_decoder() -> Decoder(Validation) {
  decode.dict(decode.string, schema_decoder()) |> decode.map(Properties)
}

fn pattern_properties_decoder() -> Decoder(Validation) {
  decode.dict(decode.string, schema_decoder()) |> decode.map(PatternProperties)
}

fn additional_properties_decoder() -> Decoder(Validation) {
  schema_decoder() |> decode.map(AdditionalProperties)
}

fn dependencies_decoder() -> Decoder(Validation) {
  decode.dict(
    decode.string,
    either_decoder(schema_decoder(), decode.list(decode.string)),
  )
  |> decode.map(Dependencies)
}

fn property_names_decoder() -> Decoder(Validation) {
  schema_decoder() |> decode.map(AdditionalProperties)
}

fn if_then_else_decoder() -> Decoder(Validation) {
  use if_ <- decode.then(schema_decoder())
  use then <- decode.optional_field(
    "then",
    None,
    decode.optional(schema_decoder()),
  )
  use else_ <- decode.optional_field(
    "else",
    None,
    decode.optional(schema_decoder()),
  )
  case then, else_ {
    Some(then_s), Some(else_s) ->
      decode.success(IfThenElse(if_, then_s, else_s))
    None, Some(else_s) -> decode.success(IfElse(if_, else_s))
    Some(then_s), None -> decode.success(IfThen(if_, then_s))
    None, None -> decode.success(Noop)
  }
}

fn all_of_decoder() -> Decoder(Validation) {
  decode.list(schema_decoder()) |> decode.map(AllOf)
}

fn any_of_decoder() -> Decoder(Validation) {
  decode.list(schema_decoder()) |> decode.map(AnyOf)
}

fn one_of_decoder() -> Decoder(Validation) {
  decode.list(schema_decoder()) |> decode.map(OneOf)
}

fn not_decoder() -> Decoder(Validation) {
  schema_decoder() |> decode.map(Not)
}

fn format_decoder() -> Decoder(Validation) {
  decode.string |> decode.map(Format)
}

fn content_encoding_decoder() -> Decoder(Validation) {
  decode.string |> decode.map(ContentEncoding)
}

fn content_media_type_decoder() -> Decoder(Validation) {
  decode.string |> decode.map(ContentMediaType)
}

fn definitions_decoder() -> Decoder(Validation) {
  decode.dict(decode.string, schema_decoder()) |> decode.map(Definitions)
}

fn title_decoder() -> Decoder(Validation) {
  decode.string |> decode.map(Title)
}

fn description_decoder() -> Decoder(Validation) {
  decode.string |> decode.map(Description)
}

fn default_decoder() -> Decoder(Validation) {
  json_literal.json_decoder() |> decode.map(Default)
}

fn read_only_decoder() -> Decoder(Validation) {
  decode.bool |> decode.map(ReadOnly)
}

fn write_only_decoder() -> Decoder(Validation) {
  decode.bool |> decode.map(WriteOnly)
}

fn examples_decoder() -> Decoder(Validation) {
  decode.list(json_literal.json_decoder()) |> decode.map(Examples)
}

pub fn schema_decoder() -> Decoder(Schema) {
  use <- decode.recursive()
  let schema = []
  use schema <- extend_schema_decoder(schema, "type", type_decoder)
  use schema <- extend_schema_decoder(schema, "enum", enum_decoder)
  use schema <- extend_schema_decoder(schema, "const", const_decoder)
  use schema <- extend_schema_decoder(schema, "multipleOf", multiple_of_decoder)
  use schema <- extend_schema_decoder(schema, "maximum", maximum_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "exclusiveMaximum",
    exclusive_maximum_decoder,
  )
  use schema <- extend_schema_decoder(schema, "minimum", minimum_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "exclusiveMinimum",
    exclusive_minimum_decoder,
  )
  use schema <- extend_schema_decoder(schema, "maxLength", max_length_decoder)
  use schema <- extend_schema_decoder(schema, "minLength", min_length_decoder)
  use schema <- extend_schema_decoder(schema, "pattern", pattern_decoder)
  use schema <- extend_schema_decoder(schema, "items", items_decoder)

  use schema <- extend_schema_decoder(
    schema,
    "additionalItems",
    additional_items_decoder,
  )
  use schema <- extend_schema_decoder(schema, "maxItems", max_items_decoder)
  use schema <- extend_schema_decoder(schema, "minItems", min_items_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "uniqueItems",
    unique_items_decoder,
  )
  use schema <- extend_schema_decoder(schema, "contains", contains_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "maxProperties",
    max_properties_decoder,
  )
  use schema <- extend_schema_decoder(
    schema,
    "minProperties",
    min_properties_decoder,
  )
  use schema <- extend_schema_decoder(schema, "required", required_decoder)
  use schema <- extend_schema_decoder(schema, "properties", properties_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "patternProperties",
    pattern_properties_decoder,
  )
  use schema <- extend_schema_decoder(
    schema,
    "additionalProperties",
    additional_properties_decoder,
  )
  use schema <- extend_schema_decoder(
    schema,
    "dependencies",
    dependencies_decoder,
  )
  use schema <- extend_schema_decoder(
    schema,
    "propertyNames",
    property_names_decoder,
  )
  use schema <- extend_schema_decoder(schema, "if", if_then_else_decoder)
  use schema <- extend_schema_decoder(schema, "allOf", all_of_decoder)
  use schema <- extend_schema_decoder(schema, "anyOf", any_of_decoder)
  use schema <- extend_schema_decoder(schema, "oneOf", one_of_decoder)
  use schema <- extend_schema_decoder(schema, "not", not_decoder)
  use schema <- extend_schema_decoder(schema, "format", format_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "contentEncoding",
    content_encoding_decoder,
  )
  use schema <- extend_schema_decoder(
    schema,
    "ContentMediaType",
    content_media_type_decoder,
  )
  use schema <- extend_schema_decoder(
    schema,
    "definitions",
    definitions_decoder,
  )
  use schema <- extend_schema_decoder(schema, "title", title_decoder)
  use schema <- extend_schema_decoder(
    schema,
    "description",
    description_decoder,
  )
  use schema <- extend_schema_decoder(schema, "default", default_decoder)
  use schema <- extend_schema_decoder(schema, "readOnly", read_only_decoder)
  use schema <- extend_schema_decoder(schema, "writeOnly", write_only_decoder)
  use schema <- extend_schema_decoder(schema, "examples", examples_decoder)

  // special case for if, then, else (if only?)

  decode.success(schema)
}
