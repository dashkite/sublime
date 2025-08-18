import builder from "#builder"

import Value from "./value"
import rulebase from "./rulebase"
import validate from "./validate"

class Builder extends builder()
  
  @produces Value
  
  @validator validate
  
  @rulebase [ rulebase ]

export default Builder
