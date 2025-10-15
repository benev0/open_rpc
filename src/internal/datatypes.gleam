import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/option.{type Option}
import internal/either.{type Either}
import internal/json_schema.{type JsonSchema}

// fixme
/// see https://spec.open-rpc.org/#runtime-expression
type RTE =
  decode.Dynamic

// fixme
type Any =
  decode.Dynamic

/// see https://spec.open-rpc.org/#openrpc-object
pub type Schema {
  Schema(
    openrpc: String,
    info: Info,
    methods: List(Method),
    servers: Option(List(Server)),
    components: Components,
    external_docs: ExternalDoc,
  )
}

/// see https://spec.open-rpc.org/#info-object
pub type Info {
  Info(
    title: String,
    version: String,
    description: Option(String),
    tos_url: Option(String),
    contact: Option(Contact),
    license: Option(License),
  )
}

// appears to have no null restrictions
/// see https://spec.open-rpc.org/#contact-object
pub type Contact {
  Contact(name: Option(String), url: Option(String), email: Option(String))
}

/// see https://spec.open-rpc.org/#license-object
pub type License {
  License(name: String, url: Option(String))
}

/// see https://spec.open-rpc.org/#server-object
pub type Server {
  Server(
    name: String,
    url: RTE,
    summary: Option(String),
    description: Option(String),
    variables: Dict(String, ServerVariable),
  )
}

/// see https://spec.open-rpc.org/#server-variable-object
pub type ServerVariable {
  ServerVariable(
    enum: Option(List(String)),
    default: String,
    description: Option(String),
  )
}

/// see https://spec.open-rpc.org/#method-object
pub type Method {
  Method(
    name: String,
    tags: Option(Either(Tag, Reference)),
    summary: Option(String),
    description: Option(String),
    external_docs: Option(ExternalDoc),
    params: List(Either(ContentDescriptor, Reference)),
    result: Option(Either(ContentDescriptor, Reference)),
    deprecated: Bool,
    servers: Option(List(Server)),
    errors: Option(List(Either(Error, Reference))),
    links: Option(List(Either(Link, Reference))),
    param_structure: Option(ParamStructure),
    examples: Option(Either(ExamplePairing, Reference)),
  )
}

/// see https://spec.open-rpc.org/#method-object
/// params field
pub type ParamStructure {
  ByName
  ByPosition
  Either
}

// see https://spec.open-rpc.org/#content-descriptor-object
pub type ContentDescriptor {
  ContentDescriptor(
    name: String,
    summary: Option(String),
    description: Option(String),
    // default false (nullable)
    required: Bool,
    schema: JsonSchema,
    // default false (nullable)
    deprecated: Bool,
  )
}

/// see https://spec.open-rpc.org/#external-documentation-object
pub type ExternalDoc {
  ExternalDoc(description: Option(String), url: String)
}

/// see https://spec.open-rpc.org/#reference-object
/// and https://json-schema.org/draft-07/json-schema-core#rfc.section.8.3
pub type Reference {
  Reference(ref: String)
}

/// see https://spec.open-rpc.org/#tag-object
pub type Tag {
  Tag(
    name: String,
    summary: Option(String),
    description: Option(String),
    enteral_doc: Option(ExternalDoc),
  )
}

/// see https://spec.open-rpc.org/#components-object
pub type Components {
  Components(
    content_descriptors: Dict(String, ContentDescriptor),
    schemas: Dict(String, Schema),
    examples: Dict(String, Example),
    links: Dict(String, Link),
    errors: Dict(String, Error),
    example_pairings: Dict(String, ExamplePairing),
    tags: Dict(String, Tag),
  )
}

/// see https://spec.open-rpc.org/#link-object
pub type Link {
  Link(
    name: String,
    description: Option(String),
    summary: Option(String),
    method: Option(String),
    params: Dict(String, Either(Any, RTE)),
    server: Option(Server),
  )
}

/// see https://spec.open-rpc.org/#example-object
pub type Example {
  Example(
    name: Option(String),
    summary: Option(String),
    description: Option(String),
    value: Option(Any),
    external_value: Option(String),
  )
}

/// see https://spec.open-rpc.org/#error-object
pub type Error {
  Error(code: Int, message: Option(String), data: Option(Any))
}

/// see https://spec.open-rpc.org/#example-pairing-object
pub type ExamplePairing {
  ExamplePairing(
    name: String,
    description: Option(String),
    summary: Option(String),
    params: List(Either(Example, Reference)),
    result: Either(Example, Reference),
  )
}
