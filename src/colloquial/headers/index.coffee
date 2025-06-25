import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { metaclass } from "@dashkite/joy/metaclass"
import Generic from "@dashkite/generic"
import { MediaType } from "@dashkite/media-type"

import Serializers from "./serializers"
import Fields from "./fields"

normalize = ( f ) ->
  Fn.arity f.length,
    ( name, args... ) ->
      f.apply @, [ name?.toLowerCase?(), args... ]


class Headers extends metaclass()

  @make: ( target ) ->
    self = Object.assign ( new @ ), { target, _: {} }
    for name, value of target.specifier.headers
      self.set name, value
    self

  @getters
    encoded: -> 
      EncodedHeaders.make @

  get: normalize ( name ) ->  @_[ name ]

  set: normalize do ->
  
    ( Generic.make "Headers::set" ) 
    
      .define [ String, Type.isNotNullish ], ( name, value ) ->
        serializer = Serializers.find name
        @_[ name ] = serializer.format value

      .define [ String, String ], ( name, value ) ->
        serializer = Serializers.find name
        # this validates the value
        @set name, serializer.parse value


export default Headers