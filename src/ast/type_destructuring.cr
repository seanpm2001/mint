module Mint
  class Ast
    class TypeDestructuring < Node
      getter name, option, parameters

      def initialize(@parameters : Array(Node),
                     @file : Parser::File,
                     @option : Id,
                     @name : Id?,
                     @from : Int64,
                     @to : Int64)
      end

      # TODO: Probably this will need to go into the type checker
      # if we want to support cases like this:
      #
      #   type Test {
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
