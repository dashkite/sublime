import { MediaType } from "@dashkite/media-type"

rulebase =

  apply: ({ input, output }) ->

    if input.content?
      if ( type = output.headers[ "content-type" ])?
        output.content = MediaType.serialize type, input.content
      else
        output.content = MediaType.serialize input.content
        type = MediaType.fromValue input.content
        output.headers[ "content-type" ] = MediaType.format type
      output.headers[ "content-length" ] = output.content.length
    else
      for key, value of output.headers
        if key.startsWith "content-"
          delete output.headers[ key ]
    { input, output }

export default rulebase