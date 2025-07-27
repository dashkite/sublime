validate = ->

  if !@output.status? && !output.description?
    throw new Error "sublime: invalid status"


export default validate