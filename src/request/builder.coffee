import builder from "#builder"
import content from "#content/rulebase"

import Value from "./value"
import rulebase from "./rulebase"

class Builder extends builder Value
  
  @rulebases [ rulebase, content ]

export default Builder
