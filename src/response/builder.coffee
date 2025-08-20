import builder from "#builder"

import rulebase from "./rulebase"
import Value from "./value"
import State from "#state/response"

class Builder extends builder Value

  @rulebase rulebase

  @state State

export default Builder
