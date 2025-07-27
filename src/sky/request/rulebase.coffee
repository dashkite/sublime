import Scout from "@dashkite/scout"

rulebase = ->

  if @input.resource?

    api = await Scout.discover @input.resource.origin

    target = Scout.encode @input.resource, api
    @output.url = ( new URL target, api.origin ).toString()

    if @output.method?
      method = Scout.method [ @input.resource.name, @output.method ], api
      if !method?
        throw new Error "sublime: method not allowed"

export default rulebase