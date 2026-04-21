# Reference

## Sublime

### make
$make: rulebases \to sublime$

Creates a Sublime instance with the given rulebases. Returns an object containing `Request` and `Response` constructors.

```coffee
{ Request, Response } = Sublime.make()
```

## Request

### Request.Builder.make
$make: input \to builder$

Creates a new request builder with the given input.

### Request.Builder.get
$get: \dashrightarrow request$

Asynchronously processes the input through the rulebases and returns a `Request.Value`.

### Request.Value.url
$url \to xurl$

The request URL.

### Request.Value.method
$method \to string$

The normalized request method.

### Request.Value.headers
$headers \to fields$

The request headers.

### Request.Value.content
$content \to any$

The request content, automatically deserialized based on the `content-type` header.

## Response

### Response.Builder.make
$make: input \to builder$

Creates a new response builder with the given input.

### Response.Builder.get
$get: \dashrightarrow response$

Asynchronously processes the input through the rulebases and returns a `Response.Value`.

### Response.Value.status
$status \to number$

The response status code.

### Response.Value.ok
$ok \to boolean$

True if the status code is in the 2xx range.

### Response.Value.description
$description \to string$

The status description.

### Response.Value.headers
$headers \to fields$

The response headers.

### Response.Value.content
$content \to any$

The response content, automatically deserialized based on the `content-type` header.

## Fields

### get
$get: name \to value$

Retrieves the value of the named header, automatically parsed.

## convert
$convert: target, value \dashrightarrow result$

Converts a Sublime value to the target format.

```coffee
# Convert a Sublime request to a Fetch request
fetchRequest = await convert "fetch", request
```
