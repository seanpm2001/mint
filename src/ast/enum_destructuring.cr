module Mint
  class Ast
    class EnumDestructuring < Node
      getter name, option, parameters

      def initialize(@parameters : Array(Node),
                     @option : TypeId,
                     @name : TypeId?,
                     @file : Parser::File,
                     @from : Int64,
                     @to : Int64)
      end

      # TODO: Probably this will need to go into the type checker
      # if we want to support cases like this:
      #
      #   enum Test {
      #     Branch(String)
      #   }
      #
      #   let Test::Branch(value) = Test::Branch("Hello")
      def exhaustive?
        false
      end
    end
  end
end
