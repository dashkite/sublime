import * as Fn from "@dashkite/joy/function"
import { metaclass } from "@dashkite/joy/metaclass"
import * as Val from "@dashkite/joy/value"
import Headers from "#headers/canonical"
import clone from "#helpers/clone"

class State extends metaclass()

  @make: ({ errors, data, state... }) ->
    errors ?= []
    data ?= {}
    _ = {}
    Object.assign ( new @ ), { errors, data, _, state... }

  clone: -> clone @

  equal: ({ input, state... }) ->
    { input: _input, _state... } = @
    Val.equal state, _state

  throw: ( error ) -> @errors.push error


clone.define [ Headers ], Fn.identity

clone.define [ State ], ( target ) ->
  { output, state... } = target
  target.constructor.make { 
    output: clone output 
    state...
  }

export default State