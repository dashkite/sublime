import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import Request from "#request"
import Headers from "#headers/canonical"
import Content from "#content/rulebase"
import status from "./status"

Status =
  fromDescription: Fn.memoize ( description ) ->
    description = description.toLowerCase()
    Text.parseNumber do ->
      Object
        .entries status
        .find ( entry ) ->
          description == entry[ 1 ].toLowerCase()
        .at 0

rulebase = ->

  # request
  if @input.request?
    @output.request = await Request
      .make @input.request
      .get()

  # status and description
  if @input.status?
    if Type.isNumber @input.status
      @output.status = @input.status
    else if Type.isString @input.status
      @output.status = Text.parseNumber @input.status

  else if @input.description?
    @output.status = Status.fromDescription @input.description
  else if @input.content?
    @output.status = 200
  else
    @output.status = 204

  # headers
  @output.headers = ( Headers.from @input.headers ).data

  # content
  Content.apply @

export default rulebase