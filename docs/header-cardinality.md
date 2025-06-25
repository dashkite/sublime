# Header Cardinality

> [!WARNING]
>
> This document’s accuracy is suspect and should be cross-checked against [the specification](https://www.rfc-editor.org/rfc/rfc9110.html#section-5.6.1).

## List (Multi-Valued) Headers

List headers are multi-valued headers, which often allow for comma-separated values or headers that may appear more than once (which tacitly append new values).

### Content Negotiation

`Accept`, `Accept-Charset`, `Accept-Encoding`, `Accept-Language`, `Accept-Ranges`

### Control

`Allow`, `Cache-Control`, `Connection`, `Expect`, `Forwarded`, `Range`, `TE`, `Trailer`, `Transfer-Encoding`, `Upgrade`, `Vary`

### Authentication And Metadata

`WWW-Authenticate`, `Proxy-Authenticate`, `If-Match`, `If-None-Match`, `Accept-Patch`, `Accept-CH`, `IM`, `Preference-Applied`

## Unary (Single-Valued) Headers

`Authorization`, `Content-Length`, `Content-Type`, `Content-MD5`, `Date`, `ETag`, `Expires`, `Last-Modified`, `Location`, `Host`, `Origin`, `Referer`, `Retry-After`, `Server`, `User-Agent`, `Warning`, `Pragma`

## Other Headers

### Cookies

- `Cookie` uses semicolon-separated name-value pairs within a single header line and does **not** follow comma-list syntax ([developer.mozilla.org][2]).

- `Set-Cookie` must be repeated as separate header fields—attempts to combine multiple `Set-Cookie` values into one comma-separated line are deprecated and widely unsupported ([datatracker.ietf.org][1], [developer.mozilla.org][2]).

[1]: https://datatracker.ietf.org/doc/html/rfc7230 "RFC 7230 - Hypertext Transfer Protocol (HTTP/1.1) - IETF Datatracker"
[2]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Set-Cookie "Set-Cookie header - HTTP - MDN Web Docs"
