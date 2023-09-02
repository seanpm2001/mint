module Mint
  class Parser
    def tuple_destructuring : Ast::TupleDestructuring?
      parse do |start_position|
        next unless char! '{'
        whitespace

        parameters = list(terminator: '}', separator: ',') { destructuring }

        whitespace
        next unless char! '}'

        Ast::TupleDestructuring.new(
          parameters: parameters,
          from: start_position,
          to: position,
          file: file)
      end
    end
  end
end
