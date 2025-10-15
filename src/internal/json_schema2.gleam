import gleam/dict.{type Dict}
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
  IfThenElse(Schema, Schema)

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
}
