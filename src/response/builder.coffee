import builder from "#builder"
import content from "#content/rulebase"

import rulebase from "./rulebase"
import Value from "./value"

class Builder extends builder Value

  @rulebases [ rulebase, content ]

export default Builder
