import * as Fn from "@dashkite/joy/function"
import { metaclass } from "@dashkite/joy/metaclass"
import * as Val from "@dashkite/joy/value"
import Value from "#request/value"
import clone from "#helpers/clone"
import equal from "#helpers/equal"

class State extends metaclass()

  @make: ({ errors, working, state... }) ->
    errors ?= []
    working ?= {}
    _ = {}
    Object.assign ( new @ ), { errors, working, _, state... }

  clone: -> clone @

  equal: ( value ) -> equal @, value

  # TODO avoid adding duplicate errors
  throw: ( error ) -> @errors.push error

clone.define [ State ], ( target ) ->
  { output, working, _, state... } = target
  target.constructor.make { 
    output: clone output 
    working: clone working
    _: clone _
    state...
  }

equal.define [ State, State ], ( a, b ) ->
  equal { a... }, { b... }


export default State