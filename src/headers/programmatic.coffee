import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { metaclass } from "@dashkite/joy/metaclass"
import Generic from "@dashkite/generic"

import Serializers from "./serializers"

normalize = ( f ) ->
  Fn.arity f.length,
    ( name, args... ) ->
      f.apply @, [ name?.toLowerCase?(), args... ]

class Headers extends metaclass()

  @make: ( target ) ->
    Object.assign ( new @ ), { target }

  @getters
    data: -> @target.output.headers

  get: normalize ( name ) ->
    serializer = Serializers.find name
    if @target.output.headers[ name ]
      serializer.parse @target.output.headers[ name ]

  set: normalize ( name, value ) ->
    @target.update ( input ) ->
      input.headers[ name ] = value
    @target.output.headers[ name ]

export default Headers