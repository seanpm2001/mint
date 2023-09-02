module Mint
  class Ast
    class Locale < Node
      getter fields, comment, language

      def initialize(@fields : Array(RecordField),
                     @comment : Comment?,
                     @language : String,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end
    end
  end
end
