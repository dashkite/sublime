import EventReactor from "@dashkite/reactive/event-reactor"

validate = ( reactor ) ->

  EventReactor

    .make reactor
    .bind @

    .when "validate", ->

      if @input.url? && !@output.url?
        throw new Error "sublime: unsupported url value"

      # throws unless the URL is valid
      ( new URL @output.url )

      # TODO check for inconsistencies between content
      # headers and content

    .run()

export default validate