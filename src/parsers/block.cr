module Mint
  class Parser
    def block : Ast::Block?
      parse do |start_position|
        statements =
          brackets do
            many { comment || statement }
          end

        Ast::Block.new(
          statements: statements,
          from: start_position,
          to: position,
          file: file) if statements
      end
    end

    def block(opening_bracket_error : Proc(Nil)? = nil,
              closing_bracket_error : Proc(Nil)? = nil,
              statement_error : Proc(Nil)? = nil)
      block(
        opening_bracket_error,
        closing_bracket_error,
        statement_error) { comment || statement }
    end

    def block(opening_bracket_error : Proc(Nil)? = nil,
              closing_bracket_error : Proc(Nil)? = nil,
              statement_error : Proc(Nil)? = nil,
              & : -> Ast::Node?) : Ast::Block?
      parse do |start_position|
        statements =
          brackets(
            opening_bracket_error: opening_bracket_error,
            closing_bracket_error: closing_bracket_error) do
            many { yield }.tap do |items|
              next statement_error.call if statement_error && items.none?
            end
          end

        next unless statements

        Ast::Block.new(
          statements: statements,
          from: start_position,
          to: position,
          file: file)
      end
    end
  end
end
