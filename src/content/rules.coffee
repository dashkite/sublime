import { MediaType, Accept } from "@dashkite/media-type"

rulebase =

  apply: ({ input, output }) ->

    if input.content?
      # we only need to worry about the accept header if there's a request
      # implying this is a response...

      if output.request? && ( accept = output.request.headers.get "accept" )?
        if ( type = output.headers[ "content-type" ])?
          if ( type = Accept.select accept, type )?
            output.headers[ "content-type" ] = MediaType.format type
            output.content = MediaType.serialize type, input.content
          else
          output.status = 415
          output.description = "unsupported media type"      
        else if ( type = Accept.selectByContent input.content, accept )?
          output.headers[ "content-type" ] = MediaType.format type
          output.content = MediaType.serialize type, input.content
        else
          output.status = 415
          output.description = "unsupported media type"   
      # otherwise, try to serialize based on the content-type   
      else if ( type = output.headers[ "content-type" ])?
        output.content = MediaType.serialize type, input.content
      # otherwise infer the content-type and serialize based on that
      else
        output.content = MediaType.serialize input.content
        type = MediaType.fromValue input.content
        output.headers[ "content-type" ] = MediaType.format type
      # if we were able to serialize the content, 
      # set the content-length header
      if output.content?
        output.headers[ "content-length" ] = output.content.length
    else
      for key, value of output.headers
        if key.startsWith "content-"
          delete output.headers[ key ]
    { input, output }

export default rulebase