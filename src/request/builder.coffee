import $builder from "#builder"
import content from "#content/rulebase"

import Value from "./value"
import rulebase from "./rulebase"

builder = ( rulebases ) ->

  class Builder extends $builder Value
    
    @rulebases [ rulebase, content, rulebases... ]

  { Builder, Value }

export default builder
