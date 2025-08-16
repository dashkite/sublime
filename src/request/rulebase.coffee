import * as Type from "@dashkite/joy/type"
import { MediaType } from "@dashkite/media-type"
import EventReactor from "@dashkite/reactive/event-reactor"
import Headers from "#headers/canonical"

rulebase = ( reactor ) ->

  yield from EventReactor

    .make reactor
    .bind @

    .forward "finalize, validate"

    .when "url", ( event ) ->

      if @input.url?
        if Type.isString @input.url
          @output.url = @input.url
        else if Type.isKind URL, @input.url
          @output.url = @input.url.toString()
      else if @input.origin?    
        url = new URL ( @input.target ? "/" ), @input.origin
        url.search = new URLSearchParams @input.query
        @output.url = url.href
      else yield event

    .when "method", ( event ) ->

      if @input.method?
        @output.method = @input.method.toLowerCase()
      else
        if !@input.content?
          # default but yield in case another rulebase has
          # a better idea of what to do
          @output.method = "get"
          yield event 
        else
          yield event

    .when "headers", ( event ) ->

      if @input.headers?
        @output.headers = ( Headers.from @input.headers ).data
      else
        @output.headers = Headers.make().data

    .when "content", ( event ) ->

      if @input.content?

        # serialize the content based on content-type
        # otherwise infer the content-type

        if ( type = @output.headers[ "content-type" ])?
          @output.content = MediaType.serialize type, @input.content
        else
          @output.content = MediaType.serialize @input.content
          type = MediaType.fromValue @input.content
          @output.headers[ "content-type" ] = MediaType.format type

        # if we were able to serialize the content, 
        # set the content-length header

        # TODO can we set the content length more reliably?

        if @output.content?
          @output.headers[ "content-length" ] = @output.content.length

      else

        # delete content headers because there's no content
        for key, value of @output.headers
          if key.startsWith "content-"
            delete @output.headers[ key ]

  await return


export default rulebase