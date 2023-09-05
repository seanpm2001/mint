module Mint
  class Parser
    def case_branch(for_css : Bool = false) : Ast::CaseBranch?
      parse do |start_position|
        unless word! "=>"
          pattern = destructuring
          whitespace

          next unless word! "=>"
        end

        whitespace

        expression =
          if for_css
            many { css_definition }
          else
            next error :case_branch_expected_expression do
              block "A case branch must have an expression."
              expected "the body of a case expression", word
              snippet self
            end unless item = self.expression

            item
          end

        Ast::CaseBranch.new(
          pattern: pattern.as(Ast::TypeDestructuring | Ast::TupleDestructuring | Ast::Node?),
          expression: expression,
          from: start_position,
          to: position,
          file: file)
      end
    end
  end
end
