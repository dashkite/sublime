import assert from "@dashkite/assert"
import { test } from "@dashkite/amen"
import reverie, { make, oneOf, integer, string, boolean, object, derive } from "@dashkite/reverie"
import fidelity, { converge, print } from "@dashkite/fidelity"

import Sublime from "../src"
import convert from "../src/convert"

# Generative pilot test suite for @dashkite/sublime
# Exercises Request.Builder, Response.Builder, and convert invariants using Reverie generators
# Monitors and converges in-process V8 coverage using Fidelity

export default ->
  test "Sublime Generative Property Pilot", ->
    $ = Sublime.make()

    # Define Reverie combinators for HTTP inputs
    methodGen = oneOf "GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "get", "post", "put"
    protocolGen = oneOf "http", "https"
    hostGen = oneOf "example.com", "dashkite.com", "api.sublime.io", "localhost:8080"
    pathGen = oneOf "/posts", "/api/v1/users", "/items/123", "/feed.xml", "/search"
    queryGen = oneOf(
      { query: "generative", limit: "10" }
      { page: "1" }
      { tag: "coffee", debug: "true" }
      {}
    )
    headersGen = oneOf(
      { "x-api-key": "secret-123" }
      { "x-client-ver": "2.1.0" }
      { "x-request-id": "req-99" }
      { "x-custom-header": "test-val" }
    )
    statusGen = oneOf 200, 201, 204, 301, 302, 400, 401, 403, 404, 500
    bodyGen = oneOf(
      "Hello World"
      JSON.stringify(message: "generative test payload", count: 42)
      ""
    )

    # In-process coverage convergence loop
    convergenceResult = await fidelity.converge
      targetPackage: "sublime"
      target: 0.85
      stall: 10
      max: 100
      run: (iteration) ->
        try
          ctx = make 1337 + iteration * 31

          # 1. Generate randomized Request scenarios
          for i in [ 0 ... 5 ]
            method = ctx.sample methodGen
            protocol = ctx.sample protocolGen
            host = ctx.sample hostGen
            path = ctx.sample pathGen
            query = ctx.sample queryGen
            headers = ctx.sample headersGen
            hasBody = method.toUpperCase() not in [ "GET", "HEAD" ]
            body = if hasBody then ctx.sample(bodyGen) else undefined

            queryString = ( "#{ k }=#{ v }" for k, v of query ).join "&"
            fullUrl = if queryString.length > 0 then "#{ protocol }://#{ host }#{ path }?#{ queryString }" else "#{ protocol }://#{ host }#{ path }"

            builder = $.Request.Builder.make
              method: method
              url: fullUrl
              headers: Object.assign {}, headers
              content: body

            builder.update ( input ) ->
              input.headers["x-test-iteration"] = String iteration
              input

            request = await builder.get()

            # Invariant 1: Method normalization to canonical lowercase
            assert.equal request.method, method.toLowerCase(), "Method must normalize to lowercase"

            # Invariant 2: URL origin matches protocol and host
            assert.equal request.url.origin, "#{ protocol }://#{ host }", "URL origin integrity"

            # Invariant 3: URL domain matches host without port
            expectedDomain = host.split(":")[0]
            assert.equal request.url.domain, expectedDomain, "URL domain integrity"

            # Invariant 4: Header preservation and retrieval (handling List vs Singleton serializers)
            iterHeader = request.headers.get("x-test-iteration")
            iterHeaderStr = if Array.isArray(iterHeader) then iterHeader[0] else String(iterHeader)
            assert.equal iterHeaderStr, String(iteration), "Updated header must persist"

            for k, v of headers
              rawVal = request.headers.get(k.toLowerCase())
              valStr = if Array.isArray(rawVal) then rawVal[0] else String(rawVal)
              assert.equal valStr, v, "Headers must match generated value"

            # Invariant 5: Round-trip conversion with Fetch API Request
            if method.toUpperCase() not in [ "GET", "HEAD" ]
              fetchReq = convert "fetch", request
              assert.equal fetchReq.method.toLowerCase(), request.method, "Fetch Request method matches"
              assert.equal fetchReq.url, request.url.toString(), "Fetch Request URL matches"

          # 2. Generate randomized Response scenarios
          for j in [ 0 ... 5 ]
            status = ctx.sample statusGen
            headers = ctx.sample headersGen
            # In WHATWG Fetch, 204/304 responses must not have content
            content = if status in [ 204, 205, 304 ] then undefined else ctx.sample(bodyGen)

            resBuilder = $.Response.Builder.make
              status: status
              headers: Object.assign {}, headers
              content: content

            response = await resBuilder.get()

            # Invariant 6: Status code preservation
            assert.equal response.status, status, "Response status code must match input"

            # Invariant 7: Response description populated
            assert ( response.description? and typeof response.description == "string" ), "Response description must be non-empty string"

            # Invariant 8: Round-trip conversion with Fetch API Response
            fetchRes = convert "fetch", response
            assert.equal fetchRes.status, response.status, "Fetch Response status matches"

            sublimeRes = await convert "sublime", fetchRes
            assert.equal sublimeRes.status, response.status, "Round-trip Sublime Response status matches"
        catch error
          console.error "GENERATIVE TEST ERROR:", error
          throw error

    # Print fidelity coverage report to console
    if convergenceResult?.coverage?
      fidelity.print convergenceResult.coverage

    # Assert convergence metrics
    assert convergenceResult.iterations > 0, "Convergence must run at least one iteration"
    assert convergenceResult.coverage.ratio > 0, "Coverage ratio must be strictly positive"
