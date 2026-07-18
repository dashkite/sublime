# Reference

## Concepts

Sublime utilizes a rule-based inference engine to convert various colloquial forms of HTTP structures into a specific target form, by passing through a canonical Sublime form. Instead of manually specifying every header and parameter, creators provide a minimal, colloquial request or response that expresses their high-level intent. Sublime then infers the necessary details to construct a robust, canonical representation. 

This process relies heavily on a builder pattern intertwined with the Athena rules engine. Builders collect initial colloquial inputs and evaluate them against registered rulebases. Once the engine reaches equilibrium, the builder emits a finalized `Value` object representing the fully resolved, canonical request or response. Finally, creators can transform these canonical `Value` objects into environment-specific target formats (such as the standard Web Fetch `Request` or `Response` objects) using the provided `convert` capability.

## Sublime

### make
$make: rulebases \to sublime$

Initializes a factory object containing `Request` and `Response` builders. By passing an array of rulebases, developers inject custom logic into the inference engine, allowing it to handle domain-specific content types, headers, or authorization schemes natively.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

$ = Sublime.make []
assert.ok $.Request.Builder
```

## Request.Builder

### make
$make: input \to builder$

Instantiates a new request builder initialized with a colloquial `input` configuration. The builder acts as the entry point for the Athena rules engine, gathering this initial colloquial context before processing.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
builder = Request.Builder.make url: "https://example.com"

assert.equal builder.input.url, "https://example.com"
```

### get
$get: \dashrightarrow request$

Processes the accumulated inputs asynchronously through the configured rulebases, generating the finalized `Request.Value`. During this phase, the internal engine infers missing headers, normalizes methods, and serializes payloads.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com", method: "POST" ).get()

assert.equal request.method, "POST"
```

## Request.Value

### url
$url \to xurl$

Returns the canonical URL representing the target endpoint of the request. The value is normalized to ensure structural consistency.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com" ).get()

assert.equal request.url.toString(), "https://example.com/"
```

### method
$method \to string$

Returns the normalized HTTP method for the request. Sublime handles casing ensuring that methods conform to standard HTTP semantics.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com", method: "post" ).get()

assert.equal request.method, "POST"
```

### headers
$headers \to fields$

Returns a collection representing the HTTP headers attached to the request. This collection manages the complexities of header cardinality, such as merging list headers and enforcing single-valued constraints.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com", headers: { "X-Test": "123" } ).get()

assert.equal request.headers.get("X-Test"), "123"
```

### content
$content \to any$

Returns the request body content. Sublime deserializes this content automatically based on the inferred or explicitly defined `content-type` header.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com", content: { hello: "world" } ).get()

assert.deepEqual request.content, { hello: "world" }
```

## Response.Builder

### make
$make: input \to builder$

Instantiates a new response builder initialized with a colloquial `input` configuration, establishing the baseline state for inference.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
builder = Response.Builder.make status: 200

assert.equal builder.input.status, 200
```

### get
$get: \dashrightarrow response$

Processes the accumulated inputs asynchronously through the configured rulebases, returning the finalized `Response.Value`.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
response = await Response.Builder.make( status: 404 ).get()

assert.equal response.status, 404
```

## Response.Value

### status
$status \to number$

Returns the precise HTTP status code of the response.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
response = await Response.Builder.make( status: 201 ).get()

assert.equal response.status, 201
```

### ok
$ok \to boolean$

Evaluates whether the response represents a successful operation. It returns `true` if the status code falls within the `2xx` range.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
response = await Response.Builder.make( status: 204 ).get()

assert.equal response.ok, true
```

### description
$description \to string$

Returns a human-readable phrase describing the status code, assisting in logging and debugging flows.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
response = await Response.Builder.make( status: 200 ).get()

assert.equal response.description, "OK"
```

### headers
$headers \to fields$

Returns a collection representing the HTTP headers attached to the response.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
response = await Response.Builder.make( status: 200, headers: { "X-Response": "456" } ).get()

assert.equal response.headers.get("X-Response"), "456"
```

### content
$content \to any$

Returns the response body content, automatically deserialized according to the response's `content-type` header.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()
response = await Response.Builder.make( status: 200, content: { status: "success" } ).get()

assert.deepEqual response.content, { status: "success" }
```

## Fields

### get
$get: name \to value$

Retrieves the value associated with the specified header field name, resolving any underlying structural nuances like comma-separated lists.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com", headers: { "Accept": "application/json" } ).get()

assert.equal request.headers.get("Accept"), "application/json"
```

## Convert

### convert
$convert: target, value \dashrightarrow result$

Translates a Sublime internal structure into a specialized format required by a `target` system. It currently translates directly to standard `fetch` structures, enabling seamless integration with native web APIs.

```coffeescript
import assert from "node:assert"
import Sublime from "@dashkite/sublime"
import convert from "@dashkite/sublime/src/convert"

{ Request } = Sublime.make()
request = await Request.Builder.make( url: "https://example.com" ).get()
fetchRequest = await convert "fetch", request

assert.ok fetchRequest instanceof global.Request
```

## Header Cardinality

> [!WARNING]
>
> This document’s accuracy is suspect and should be cross-checked against [the specification](https://www.rfc-editor.org/rfc/rfc9110.html#section-5.6.1).

List headers are multi-valued headers, which often allow for comma-separated values or headers that may appear more than once (which tacitly append new values).

### Content Negotiation

`Accept`, `Accept-Charset`, `Accept-Encoding`, `Accept-Language`, `Accept-Ranges`

### Control

`Allow`, `Cache-Control`, `Connection`, `Expect`, `Forwarded`, `Range`, `TE`, `Trailer`, `Transfer-Encoding`, `Upgrade`, `Vary`

### Authentication And Metadata

`WWW-Authenticate`, `Proxy-Authenticate`, `If-Match`, `If-None-Match`, `Accept-Patch`, `Accept-CH`, `IM`, `Preference-Applied`

### Unary (Single-Valued) Headers

`Authorization`, `Content-Length`, `Content-Type`, `Content-MD5`, `Date`, `ETag`, `Expires`, `Last-Modified`, `Location`, `Host`, `Origin`, `Referer`, `Retry-After`, `Server`, `User-Agent`, `Warning`, `Pragma`

### Cookies

- `Cookie` uses semicolon-separated name-value pairs within a single header line and does **not** follow comma-list syntax.
- `Set-Cookie` must be repeated as separate header fields—attempts to combine multiple `Set-Cookie` values into one comma-separated line are deprecated and widely unsupported.
