import * as P from "@dashkite/parse"
import mediaType from "./media-type"
import accept from "./accept"

Parsers =

  mediaType: P.parser mediaType
  accept: P.parser accept

export default Parsers