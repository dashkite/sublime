# Usage Guides

## Composing a Basic Request

This task demonstrates converting a colloquial description of an HTTP POST request into a canonical Sublime form. Sublime enables developers to specify high-level intent and handles the underlying inference and serialization automatically. This separation lets creators focus on business logic instead of HTTP intricacies.

```coffeescript
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()

request = await Request.Builder
  .make
    url: "https://example.com/api"
    method: "POST"
    content: { account: "alice" }
  .get()

# integration logic for handling finalized requests goes here
console.log request.url.toString()
console.log request.method
```

1. Initialize a `Sublime` instance to access the `Request` tools.
2. Provide the `url`, `method`, and `content` payload to the `Request.Builder`.
3. Call `get()` to resolve the builder's Athena rules and retrieve the finalized request structure.
4. Access the normalized `url` and `method` properties from the generated `Request.Value`.

## Interpreting Server Responses

This task illustrates evaluating an HTTP response structure. Sublime enables developers to assess success states and decode response payloads without writing boilerplate validation logic.

```coffeescript
import Sublime from "@dashkite/sublime"

{ Response } = Sublime.make()

# simulation of incoming data from a network transport layer
response = await Response.Builder
  .make
    status: 404
    content: { error: "Not Found" }
  .get()

if not response.ok
  console.log response.description
  console.log response.content.error
```

1. Initialize a `Sublime` instance to access the `Response` tools.
2. Provide the `status` and raw `content` to the `Response.Builder`.
3. Call `get()` to generate the finalized `Response.Value`.
4. Evaluate the `ok` boolean flag to determine if the status falls within the successful `2xx` range.
5. Access the human-readable `description` and the deserialized `content` for error handling.

## Managing Header Cardinality

This task demonstrates managing complex HTTP headers across both requests and responses. Sublime enables developers to extract specific values from multi-valued headers without writing custom string-parsing routines.

```coffeescript
import Sublime from "@dashkite/sublime"

{ Request, Response } = Sublime.make()

request = await Request.Builder
  .make
    url: "https://example.com/api"
    headers:
      "Accept": "text/html, application/xhtml+xml, application/xml;q=0.9, */*;q=0.8"
  .get()

response = await Response.Builder
  .make
    status: 200
    headers:
      "Content-Type": "application/json; charset=utf-8"
  .get()

acceptHeader = request.headers.get "Accept"
contentType = response.headers.get "Content-Type"
```

1. Instantiate both a `Request.Builder` and a `Response.Builder` containing complex headers.
2. Resolve the builders to obtain the finalized `Value` objects.
3. Call the `get` method on the `headers` field collections for both the request and the response.
4. Retrieve the accurately parsed header strings, completely abstracted away from any internal array or concatenation structures.

## Bridging to Native Web Transports

This task outlines managing a full network lifecycle by translating finalized, canonical Sublime objects to and from target native Web structures. The `convert` capability handles bidirectional translation, converting a canonical Sublime `Request` out to a target `fetch` format, and converting a target native `Response` back into the canonical Sublime ecosystem.

```coffeescript
import Sublime from "@dashkite/sublime"
import convert from "@dashkite/sublime/src/convert"

{ Request, Response } = Sublime.make()

request = await Request.Builder
  .make
    url: "https://example.com/api"
    method: "GET"
  .get()

# delegation to an external networking library
fetchRequest = await convert "fetch", request
fetchResponse = await fetch fetchRequest

# processing the native response back into a Sublime representation
response = await convert "sublime", fetchResponse

if response.ok
  console.log response.content
```

1. Construct a `Request.Value` using the standard builder pattern.
2. Use the `convert` function with the `"fetch"` target, passing the finalized `request`.
3. Utilize the returned `fetchRequest` with native networking utilities.
4. Pass the resulting native `fetchResponse` back through the `convert` function with the `"sublime"` target.
5. Utilize the fully deserialized Sublime `Response.Value` within the application logic.

## Accessing the Inference Iterator

This task demonstrates tapping directly into the underlying Athena rules engine to observe processing. Both the `Request` and `Response` builders expose an iterator, allowing developers to monitor state mutations dynamically, emit custom metrics, or inject delegator routines into the resolution lifecycle.

```coffeescript
import Sublime from "@dashkite/sublime"

{ Request } = Sublime.make()
builder = Request.Builder.make url: "https://example.com/api"

# setup initial abstract state payload for the engine
state = { input: builder.input, output: {}, errors: [], working: {} }

# obtain the async iterator from the underlying Athena rulebase
reactor = builder.rules.start state

# consume processing events as they occur
for await event from reactor
  # custom logging or reactive logic goes here
  console.log event.name

# once the iterator completes, the output object represents the finalized request
console.log state.output.url.toString()
```

1. Instantiate a builder (such as `Request.Builder`) with initial parameters.
2. Construct a state object containing `input`, `output`, `errors`, and `working` registries.
3. Call `start()` directly on the builder's `rules` property, passing the state to initialize the Athena engine iterator.
4. Iterate asynchronously over the `reactor` to receive and process events.
5. Read the finalized properties directly from the `state.output` object once the iterator completes.
