import status from "statuses"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"
import Request from "#request"
import Headers from "#headers/canonical"
import Content from "#content/rules"

rulebase =

  apply: ({ input, output }) ->

    # request
    output.request = await Request.make input.request

    # status and description
    if input.status?
      if Type.isNumber input.status
        output.status = input.status
      else if Type.isString input.status
        output.status = Text.parseNumber input.status
      else
        throw new Error "sublime: invalid status"
      output.description = ( status output.status ).toLowerCase()
    else if input.description?
      output.description = input.description.toLowerCase()
      output.status = status output.description
    else if input.content?
      output.status = 200
      output.description = "ok"
    else
      output.status = 204
      output.description = "no content"

    # headers
    output.headers = ( Headers.from input.headers ).data

    # content
    { input, output } = Content.apply { input, output }

    { input, output }

export default rulebase