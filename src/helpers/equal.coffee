import Generic from "@dashkite/generic"
import * as Type from "@dashkite/joy/type"
import * as Val from "@dashkite/joy/value"
import { symmetricDifference as diff } from "@dashkite/joy/set"

equal = Generic.make 
  name: "equal" 
  default: ( a, b ) -> a == b

equal.define [ Type.isObject, Type.isObject ], ( a, b ) ->
  return true if Object.is a, b
  ka = Object.keys a
  kb = Object.keys b
  ( ka.length == kb.length ) && 
    (( diff ka, kb ).size == 0 ) &&
    ( ka.every ( key ) -> equal a[ key ], b[ key ] )

equal.define [ Type.isArray, Type.isArray ], ( a, b ) ->
  return true if Object.is a, b
  ( a.length == b.length ) && 
    ( a.every ( value, index ) -> equal value, b[ index ] )
  
export default equal