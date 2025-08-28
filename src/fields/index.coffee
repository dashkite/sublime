import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { metaclass } from "@dashkite/joy/metaclass"
import Generic from "@dashkite/generic"

import clone from "#helpers/clone"
import equal from "#helpers/equal"

import Serializers from "./serializers"

normalize = ( f ) ->
  Fn.arity f.length,
    ( name, args... ) ->
      f.apply @, [ name?.toLowerCase?(), args... ]

class Fields extends metaclass()

  @make: ( data = {}) -> 

    self = new @

    for name, value of data
      self.set name, value

    self

  constructor: ->
    super()
    @data = {}

  get: normalize ( name ) ->
    serializer = Serializers.find name
    if ( @data[ name ] )?
      serializer.parse @data[ name ]

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

clone.define [ Fields ], ({ data }) ->
  Fields.make clone data

equal.define [ Fields, Fields ], ( a, b ) ->
  equal a.data, b.data

export default Fields