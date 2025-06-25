import { metaclass } from "@dashkite/joy/metaclass"

import Headers from "./headers"

class Colloquial extends metaclass()

  @getters

    headers: ->
      @_headers ?= Headers.make @

export default Colloquial

