import { metaclass } from "@dashkite/joy/metaclass"

import Headers from "#headers/programmatic"

import rulebase from "./rules"

class Request extends metaclass()

  @make: ({ url, method, content, headers } = {}) ->
    Object.assign ( new @ ), 
      await rulebase.apply
        input: { url, method, content, headers }
        output: {}

  update: ( mutator ) ->
    mutator @input
    Object.assign @, 
      await rulebase.apply { @input, output: {}}

  @getters

    url: -> new URL @output.url

    domain: -> @url.hostname

    origin: -> @url.origin

    target: -> @url.pathname + @url.search

    query: -> Object.fromEntries @url.searchParams

    method: -> @output.method

    headers: -> Headers.make @

export default Request


