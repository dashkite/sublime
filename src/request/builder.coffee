import builder from "#builder"

import Value from "./value"
import rulebase from "./rulebase"
import driver from "./driver"
import validate from "./validate"

class Builder extends builder()
  
  @produces Value
  
  @validator validate
  
  @rulebase [ driver, rulebase ]

export default Builder
