import $builder from "#builder"
import content from "#content/rulebase"

import Value from "./value"
import rulebase from "./rulebase"

builder = ( Request, rulebases ) ->
  
  class Builder extends $builder Value

    @rulebases [( rulebase Request ), content, rulebases... ]

  { Builder, Value }

export default builder
