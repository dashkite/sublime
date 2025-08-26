import Generic from "@dashkite/generic"
import * as Type from "@dashkite/joy/type"

clone = Generic.make 
  name: "clone" 
  default: ( value ) -> structuredClone value

clone.define [ Type.isObject ], ( object ) ->
  result = {}
  for key, value of object
    result[ key ] = clone value
  result

clone.define [ Type.isArray ], ( array ) ->
  clone value for value in array

export default clone