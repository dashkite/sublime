import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Obj from "@dashkite/joy/object"
import * as Text from "@dashkite/joy/text"
import Generic from "@dashkite/generic"
import data from "./data"

Status =

  description: Fn.memoize ( status ) ->
    data[ status ]?.toLowerCase()

  from: Fn.memoize do ->
    
    Generic.make "Status.from"

      .define [ Type.isNumber ], ( status ) -> status

      .define [ Type.isString ], ( text ) ->
        status = Text.parseNumber text
        if Number.isNaN status
          Status.from description: text
        else status
      
      .define [ Obj.has "status" ], ({ status }) ->
        Status.from status

      .define [ Obj.has "description" ], ({ description }) ->
        _description = description.toLowerCase()
        Text.parseNumber do ->
          Object
            .entries data
            .find ( entry ) ->
              _description == entry[ 1 ].toLowerCase()
            .at 0

export default Status