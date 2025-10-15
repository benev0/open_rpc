import gleam/dict.{type Dict}
import gleam/option.{type Option}
import internal/either.{type Either}
import internal/json_literal.{type JsonLiteral}

// very large and very cursed see https://www.learnJsonSchema.com/draft7/ for impl draft7
/// see https://spec.open-rpc.org/#schema-object
/// todo: finish
/// reading a meta-meta-model sucks
/// also schema implicitly implies a ref
/// also see https://json-schema.org/implementers
pub type JsonSchema {
  JsonSchema(id: String, schema: String)
}

/// see https://www.learnJsonSchema.com/draft7/validation/type/
pub type SchemaType {
  NullType
  BooleanType
  ObjectType
  ArrayType
  // will need types for Int and Float
  NumberType
  IntegerType
  StringType(format: Option(String), pattern: Option(String))
}

/// see https://www.learnJsonSchema.com/draft7/validation/enum/
pub type SchemaEnum {
  SchemaEnum
}

/// see https://www.learnJsonSchema.com/draft7/validation/const/
pub type ConstType {
  ConstType
}

pub type ObjectProperties =
  Dict(String, SchemaType)

pub type NumberRestriction(numtype) {
  NumberRestriction(
    multiple_of: numtype,
    maximum: numtype,
    exclusive_maximum: numtype,
    minimum: numtype,
    exclusive_minimum: numtype,
  )
}

pub type StringRestriction {
  StringRestriction(
    // assertion
    max_length: Int,
    min_length: Int,
    pattern: String,
    // annotation
    format: String,
    content_encoding: String,
    content_media_type: String,
  )
}

pub type ArrayRestriction {
  ArrayRestriction(
    items: Either(JsonSchema, List(JsonSchema)),
    additional_items: JsonSchema,
    max_items: Int,
    min_items: Int,
    unique_items: Bool,
    contains: JsonSchema,
  )
}

pub type ObjectRestriction {
  ObjectRestriction(
    max_properties: Int,
    min_properties: Int,
    required: List(String),
    properties: Dict(String, JsonSchema),
    pattern_properties: Dict(String, JsonSchema),
    additional_properties: JsonSchema,
    dependencies: Either(Dict(String, List(String)), JsonSchema),
    property_names: JsonSchema,
  )
}

// todo: if and below https://www.learnJsonSchema.com/draft7/validation/if/
// aka all any type
pub type GeneralRestriction {
  GeneralRestriction(
    // applicator
    if_restriction: If,
    all_of: List(JsonSchema),
    any_of: List(JsonSchema),
    one_of: List(JsonSchema),
    not: JsonSchema,
    // reserved location
    definitions: Dict(String, JsonSchema),
    // annotation
    title: String,
    description: String,
    default: JsonLiteral,
    read_only: Bool,
    write_only: Bool,
    examples: List(JsonLiteral),
  )
}

// needs to somehow have ability to apply to any restriction
pub type If {
  IfThen(if_: JsonSchema, then: JsonSchema)
  IfElse(if_: JsonSchema, else_: JsonSchema)
  IfThenElse(if_: JsonSchema, then: JsonSchema, else_: JsonSchema)
}
