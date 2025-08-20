import builder from "#builder"
import State from "#state/request"

import Value from "./value"
import rulebase from "./rulebase"

class Builder extends builder Value
  
  @rulebase rulebase

  @state State

export default Builder
