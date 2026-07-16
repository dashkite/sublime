# Testing

Sublime utilizes the `genie` task runner to orchestrate its testing pipeline. The testing approach verifies the behavior of request and response builders, content negotiation, serialization, and conversion to external formats.

## Running Tests

To run the full test suite, invoke the `genie` test task from the repository root:

```bash
npx genie test
```

## Testing Approach

The tests employ a scenario-based model driven by `@dashkite/runner`, defining expected inputs and evaluating the resulting `Request` or `Response` structures. The suite thoroughly exercises edge cases around header cardinality and data conversion, including the translation of structures to and from Web Fetch representations. Mock authorizers and state delegates are utilized to test the integration points of the rule-based builder system.
