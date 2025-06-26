import * as Type from "@dashkite/joy/type"
import { MediaType } from "@dashkite/media-type"
import Scout from "@dashkite/scout"
import Headers from "#headers/canonical"
import Content from "#content/rules"

rulebase =

  apply: ({ input, output }) ->

    # url
    if input.url?
      if Type.isString input.url
        output.url = input.url
      else if Type.isKind URL, input.url
        output.url = input.url.toString()
      else
        throw new Error "sublime: unsupported url value"

    # resource locator
    # determine URL via Sky API convention
    if input.resource?
      api = await Scout.discover input.resource.origin
      target = Scout.encode input.resource, api
      output.url = ( new URL target, api.origin ).toString()
        
    # method
    if !input.method?
      if  !input.content?
        output.method = "get"
    else
      output.method = input.method.toLowerCase()

    # headers
    output.headers = ( Headers.from input.headers ).data

    # content
    { input, output } = Content.apply { input, output }

    { input, output }

export default rulebase