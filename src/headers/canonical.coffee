import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Val from "@dashkite/joy/value"
import { metaclass } from "@dashkite/joy/metaclass"
import Generic from "@dashkite/generic"

import Serializers from "./serializers"

normalize = ( f ) ->
  Fn.arity f.length,
    ( name, args... ) ->
      f.apply @, [ name?.toLowerCase?(), args... ]

class Headers extends metaclass()

  @make: -> new @

  @from: ( headers ) ->

    self = @make()

    if headers?
      for name, value of headers
        self.set name, value

    self

  constructor: -> 
    super()
    @data = {}

  equal: ( value ) ->
    ( Type.isKind Headers, value ) &&
      Val.equal @data, value.data

  get: normalize ( name ) -> @data[ name ]

  set: normalize do ->

    ( Generic.make "set" ) 
    
      .define [ String, Type.isNotNullish ], ( name, value ) ->
        serializer = Serializers.find name
        @data[ name ] = serializer.format value

      .define [ String, String ], ( name, value ) ->
        serializer = Serializers.find name
        # this validates the value
        @data[ name ] = serializer.format serializer.parse value    

  remove: normalize ( name ) -> delete @data[ name ]

  [ Symbol.iterator ]: -> yield from Object.entries @data

export default Headers