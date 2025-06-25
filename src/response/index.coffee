import { metaclass } from "@dashkite/joy/metaclass"
import Headers from "#headers/programmatic"

import rulebase from "./rules"

class Response extends metaclass()

  @make: ({ request, status, description, headers, content } = {}) ->
    Object.assign ( new @ ), 
      await rulebase.apply
        input: { request, status, description, headers, content }
        output: {}

  @getters

    url: -> new URL @output.request.url

    domain: -> @url.hostname

    origin: -> @url.origin

    target: -> @url.pathname + @url.search

    query: -> Object.fromEntries @url.searchParams

    method: -> @output.request.method

    headers: -> Headers.make @

    status: -> @output.status

    description: -> @output.description

    content: -> @output.content

export default Response


