validate = ->

  if @input.url? && !@output.url?
    throw new Error "sublime: unsupported url value"

  # throws unless the URL is valid
  ( new URL @output.url )

export default validate