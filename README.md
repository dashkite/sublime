# Sublime

*Canonical HTTP request and response format, with accessors and mutators*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Sublime provides a rule-based system for reliably inferring the details of an HTTP request or response based on the available context. It handles URL construction, header management, content-type inference, and serialization.

## Features

- Constructs URLs robustly from partial inputs.
- Manages HTTP headers, including lists and single-valued variations.
- Infers content types based on data structures.
- Provides automatic serialization and deserialization of payloads.
- Converts structures between canonical representations and standard Web Fetch structures.

## Installation

```bash
pnpm install @dashkite/sublime
```

## Usage

Sublime works by creating a unified interface for composing HTTP requests and responses.

```coffeescript
import Sublime from "@dashkite/sublime"

{ Request, Response } = Sublime.make()

request = await Request.Builder
  .make
    url: "https://example.com/api"
    method: "POST"
    content: { hello: "world" }
  .get()

console.log request.url.toString()
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
