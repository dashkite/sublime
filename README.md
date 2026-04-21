# Sublime

*Canonical HTTP request and response format, with accessors and mutators*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

## Purpose

Sublime provides a rule-based system for reliably inferring the details of an HTTP request or response based on the available context. It handles URL construction, header management, content-type inference, and serialization/deserialization.

The rulebase is modular, allowing rule "modules" to be added to improve Sublime's ability to enrich requests and responses.

## Installation

Use your favorite package manager to install `@dashkite/sublime`.

## Usage

```coffee
import Sublime from "@dashkite/sublime"

# Create a Sublime instance with default rules
{ Request, Response } = Sublime.make()

# Build a request
request = await Request.Builder
  .make
    url: "https://example.com/api"
    method: "POST"
    content: { hello: "world" }
  .get()

console.log request.url.toString() # https://example.com/api
console.log request.method # post (normalized)
console.log request.headers.get "content-type" # application/json (inferred)
console.log request.content # { hello: "world" } (deserialized from JSON string in output)
```

## Other Resources

- [Reference](docs/reference.md)

## Status

Not suitable for production use. Please report bugs and feature requests via the issue tracker.
