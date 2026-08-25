import { metaclass } from "@dashkite/joy/metaclass"
import { MediaType } from "@dashkite/media-type"
import Fields from "#fields"
import clone from "#helpers/clone"
import equal from "#helpers/equal"
import isJSON from "#helpers/is-json"
import Request from "#request/value"

class Value extends metaclass()

  @make: ( output ) ->
    Object.assign ( new @ ), { output }

  @getters

    data: -> @output

    request: -> Request.make @output.request

    url: -> new URL @output.request.url

    domain: -> @url.hostname

    origin: -> @url.origin

    target: -> @url.pathname + @url.search

    query: -> Object.fromEntries @url.searchParams

    method: -> @output.request.method

    headers: -> Fields.make @output.headers

    status: -> @output.status

    ok: -> 200 <= @status < 300

    description: -> @output.description

    content: -> 
      if ( typeof @output.content is "string" ) and isJSON @headers.get "content-type"
        JSON.parse @output.content
      else
        @output.content

clone.define [ Value ], ( value ) ->
  Value.make clone value.data

equal.define [ Value, Value ], ( a, b ) ->
  equal a.data, b.data


export default Value


