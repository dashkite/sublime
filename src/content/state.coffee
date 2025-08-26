import { MediaType } from "@dashkite/media-type"
import * as Val from "@dashkite/joy/value"

import _State from "#state"

class State extends _State

  @getters

    "content-type": ->
      @_[ "content-type" ] ?= 
        if ( @output.headers?.get "content-type" )?
          MediaType.parse @output.headers.get "content-type"

    charset: -> 
      ( @_[ "content-type" ]?.parameters?.charset )? "utf-8"


export default State