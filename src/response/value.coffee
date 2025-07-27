import { metaclass } from "@dashkite/joy/metaclass"
import Headers from "#headers/programmatic"

class Value extends metaclass()

  @make: ( output ) ->
    Object.assign ( new @ ), { output }

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

export default Value


