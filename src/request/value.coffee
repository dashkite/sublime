import { metaclass } from "@dashkite/joy/metaclass"
import Fields from "#fields"
import clone from "#helpers/clone"
import equal from "#helpers/equal"
import isJSON from "#helpers/is-json"

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

    headers: -> Fields.make @output.headers

    content: -> 
      if isJSON @headers.get "content-type"
        JSON.parse @output.content
      else
        @output.content

clone.define [ Value ], ( value ) ->
  Value.make clone value.data

equal.define [ Value, Value ], ( a, b ) ->
  equal a.data, b.data

export default Value