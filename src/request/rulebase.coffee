import * as Type from "@dashkite/joy/type"
import { MediaType } from "@dashkite/media-type"
import Scout from "@dashkite/scout"
import Headers from "#headers/canonical"
import Content from "#content/rulebase"

import validate from "./validate"

rulebase = ->

  if @input.resource?
    api = await Scout.discover @input.resource.origin

  if @input.url?
    if Type.isString @input.url
      @output.url = @input.url
    else if Type.isKind URL, @input.url
      @output.url = @input.url.toString()

    # resource locator
    # determine URL via Sky API convention

  if @input.resource?
    target = Scout.encode @input.resource, api
    @output.url = ( new URL target, api.origin ).toString()

  # method
  if !@input.method?
    if  !@input.content?
      @output.method = "get"
  else
    @output.method = @input.method.toLowerCase()

  if @input.resource? && @output.method?
    method = Scout.method [ @input.resource.name, @output.method ], api
    if !method?
      throw new Error "sublime: method not allowed"

  if @input.headers?
    @output.headers = ( Headers.from @input.headers ).data
  else
    @output.headers = Headers.make().data

  if @input.content? 
    Content.apply @

export default rulebase