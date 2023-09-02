module Mint
  class Ast
    class Record < Node
      getter fields

      UNIT = new(
        file: Parser::File.new("", ""),
        fields: [] of RecordField,
        from: 0,
        to: 2)

      def initialize(@fields : Array(RecordField),
                     @file : Parser::File,
                     @from : Int32,
                     @to : Int32)
      end

      def self.empty
        UNIT
      end
    end
  end
end
