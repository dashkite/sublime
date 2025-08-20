import State from "./request"

class ResponseState extends State

  clone: ->
    { output: { output..., request }, state... } = @
    ResponseState.make { 
      output: { request, ( structuredClone output )... }
      state...
    }

export default ResponseState