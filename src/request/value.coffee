import { metaclass } from "@dashkite/joy/metaclass"
import Headers from "#headers/programmatic"

class Value extends metaclass()

  @make: ( output ) ->
    Object.assign ( new @ ), { output }

  @getters

    data: -> @output

    url: -> new URL @output.url

    domain: -> @url.hostname

    origin: -> @url.origin

    target: -> @url.pathname + @url.search

    query: -> Object.fromEntries @url.searchParams

    method: -> @output.method

    headers: -> Headers.make @

export default Value