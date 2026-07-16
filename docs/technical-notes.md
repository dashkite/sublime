# Technical Notes

### Conceptual Architecture

HTTP request and response structures are fundamental building blocks of network communication, often characterized in computer science as the implementation of Representational State Transfer (REST) [Fielding, 2000]. However, many of their constituent forms contain domain-specific formatting that is information-dense and tricky to manipulate programmatically.

When working with these structures, creators often write imperative flows with extensive checks, conditional control flow, and extra validation steps. This obscures the high-level goal of state transfer across the network and imposes a burden on the narrative context of the local code.

Sublime acts as an abstract, generalized model of an HTTP request and response. It serves as the central hub in a hub-and-spoke transformation model, eliminating point-to-point data conversions and creating narrative clarity in the resulting code. Creators can focus on simple, declarative business logic instead of translating between environment-specific formats.

### Colloquial to Canonical Inference

A defining capability of Sublime is its support for a "colloquial" description of network operations. Creators can specify a request or response minimally using shorthand—focusing only on the intent of the operation—rather than meticulously populating every required header, content type, and structural detail of a complete HTTP message.

Sublime leverages its underlying rule engine to perform the necessary inference on your behalf. It automatically expands the minimal colloquial representation into a robust, canonical version perfectly suited for standard network transfer. This abstraction creates narrative clarity in the code, ensuring that the primary goal of the state transfer is never obscured by the mechanics of the protocol.

### The Athena Rule Engine

Sublime addresses the complexity of managing HTTP structures by embedding the Athena rule engine. Athena evaluates rules until the state reaches a stable equilibrium (fixed-point iteration), eliminating the need for heavy inference mechanisms like the Rete algorithm.

By relying on Athena, Sublime handles parsing, conditional checks, validation, confirmation, serialization, and schema assertions simultaneously. It interprets headers and media types according to strict HTTP standards. Because the architecture is built on Athena, developers can also access the internal event stream of the processing dynamically if desired. This establishes Sublime—alongside its companion library, Altair—as the recommended tool for handling high-level HTTP parsing concerns.

### Authorization with Sierra

Security and authentication logic often bloat HTTP request building. Sublime mitigates this by delegating to the DashKite Sierra library. Sierra utilizes polymorphic dispatch and a central registry to manage compound credentials securely (e.g., using JSON64 encoding and schemes like `credentials` or `rune`).

By integrating seamlessly with Sierra, Sublime resolves authorization questions autonomously. It pulls the appropriate tokens and schemes without cluttering the HTTP assembly logic, allowing creators to keep their business logic focused on the primary state transfer goal rather than credential management.

### HTTP Standards and Headers

Sublime manages all HTTP constraints in strict adherence to industry standards established by the IETF and W3C. Specifically, it constructs and normalizes headers in compliance with RFC 9110 (HTTP Semantics) and manages media types seamlessly. By abstracting the intricacies of header cardinality and HTTP standards, Sublime ensures that network payloads are canonically correct by default.
