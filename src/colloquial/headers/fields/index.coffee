import * as Fn from "@dashkite/joy/function"
import fields from "./data"

Fields =
  
  find: Fn.memoize ( name ) ->
    fields.find ( field ) -> name == field.name

export default Fields