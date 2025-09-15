import { metaclass } from "@dashkite/joy/metaclass"

class XURL extends metaclass URL
  @getters
    domain: -> @hostname
    target: -> @pathname + @search
    query: -> Object.fromEntries @searchParams


export default XURL
