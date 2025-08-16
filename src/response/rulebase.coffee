import { MediaType, Accept } from "@dashkite/media-type"
import EventReactor from "@dashkite/reactive/event-reactor"
import Request from "#request"
import Headers from "#headers/canonical"
import Status from "./status"

rulebase = ( reactor ) ->

  yield from EventReactor

    .make reactor
    .bind @

    .forward "finalize, validate"

    .when "request", ( event ) ->

      if @input.request?
        @output.request = await Request
          .make @input.request
          .get()
      else
        yield event

    .when "status", ( event ) ->

      if @input.status?
        @output.status = Status.from @input.status
      else if @input.description?
        @output.status = Status.from @input.description
      else if @input.content?
        @output.status = 200
      else
        @output.status = 204

    .when "headers", ( event ) ->

      @output.headers = ( Headers.from @input.headers ).data

    .when "content", ( event ) ->

      try

        if @input.content?

          if ( accept = @output.request?.headers.get "accept" )?

            if ( type = @output.headers[ "content-type" ])?

              if ( selected = Accept.select accept, type )?
                @output.headers[ "content-type" ] = MediaType.format selected
                @output.content = MediaType.serialize selected, @input.content
              else
                @output.status = 415

            else if ( selected = Accept.selectByContent @input.content, accept )?
              @output.headers[ "content-type" ] = MediaType.format selected
              @output.content = MediaType.serialize selected, @input.content
            else
              @output.status = 415
              @output.description = "unsupported media type"

          else if ( type = @output.headers[ "content-type" ])?
            @output.content = MediaType.serialize type, @input.content
          else
            @output.content = MediaType.serialize @input.content
            type = MediaType.fromValue @input.content
            @output.headers[ "content-type" ] = MediaType.format type

          if @output.content?
            @output.headers[ "content-length" ] = @output.content.length

        else

          # delete content headers because there's no content
          for key, value of @output.headers
            if key.startsWith "content-"
              delete @output.headers[ key ]

      catch error
        console.warn "sublime: error processing content"
        console.warn error
        yield event

  await return

export default rulebase