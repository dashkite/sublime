import EventReactor from "@dashkite/reactive/event-reactor"

validate = ( reactor ) ->

  EventReactor

    .make reactor
    .bind @

    .when "validate", ->

      # TODO do we leave request as option

      if !@output.status?
        throw new Error "sublime: invalid status"

      # TODO check for inconsistencies between content
      # headers and content

    .run()

export default validate