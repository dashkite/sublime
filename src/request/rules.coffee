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

    # check for method not allowed
    # using Sky API description

    # is the right thing to do? this should really be
    # the response, but we can short-circuit with the API
    # description?

    # OTOH we can catch this when constructing a request
    # and know to generate the corresponding response

    # BUT what if we're IN the origin lambda? 
    # discovery won't work

    if input.resource? && output.method?
      method = Scout.method [ input.resource.name, output.method ], api
      if !method?
        throw new Error "sublime: method not allowed"

    # headers
    output.headers = ( Headers.from input.headers ).data

    # content
    { input, output } = Content.apply { input, output }

    { input, output }

export default rulebase