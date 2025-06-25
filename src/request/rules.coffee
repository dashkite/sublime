import * as Type from "@dashkite/joy/type"
import { MediaType } from "@dashkite/media-type"
import Headers from "#headers/canonical"
import Content from "#content/rules"

rulebase =

  apply: ({ input, output }) ->

    # url
    if Type.isString input.url
      output.url = input.url
    else if Type.isKind URL, input.url
      output.url = input.url.toString()
    else
      throw new Error "sublime: unsupported url value"

    # method
    if !input.method?
      if  !input.content?
        output.method = "get"
      else
        throw new Error "sublime: unable to infer HTTP method"
    else
      output.method = input.method.toLowerCase()

    # headers
    output.headers = ( Headers.from input.headers ).data

    # content
    { input, output } = Content.apply { input, output }

    { input, output }

export default rulebase