import * as Type from "@dashkite/joy/type"
import { MediaType } from "@dashkite/media-type"
import Headers from "#headers/canonical"
import Content from "#content/rulebase"

import validate from "./validate"

rulebase = ->

  if @input.url?
    if Type.isString @input.url
      @output.url = @input.url
    else if Type.isKind URL, @input.url
      @output.url = @input.url.toString()
  else if @input.origin?    
    url = new URL ( @input.target ? "/" ), @input.origin
    url.search = new URLSearchParams @input.query
    @output.url = url.href

  # method
  if !@input.method?
    if  !@input.content?
      @output.method = "get"
  else
    @output.method = @input.method.toLowerCase()

  if @input.headers?
    @output.headers = ( Headers.from @input.headers ).data
  else
    @output.headers = Headers.make().data

  if @input.content? 
    Content.apply @

export default rulebase