import * as Val from "@dashkite/joy/value"

class State

  @make: ({ errors, state... }) ->
    errors ?= []
    Object.assign ( new @ ), { errors, state... }

  clone: ->
    { output, state... } = @
    State.make { 
      output: structuredClone output 
      state...
    }

  equal: ({ input, state... }) ->
    { input: _input, _state... } = @
    Val.equal state, _state

  throw: ( error ) -> @errors.push error

export default State