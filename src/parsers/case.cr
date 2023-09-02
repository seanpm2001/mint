module Mint
  class Parser
    def case_expression(for_css : Bool = false) : Ast::Case?
      parse do |start_position|
        next unless word! "case"

        whitespace
        parens = char! '('

        whitespace
        await = word! "await"

        whitespace
        next error :case_expected_condition do
          expected "the condition of a case expression", word
          snippet self
        end unless condition = expression

        whitespace
        next error :case_expected_closing_parenthesis do
          expected "the closing parenthesis of a case expression", word
          snippet self
        end if parens && !char!(')')

        body = block2(
          ->{ error :case_expected_opening_bracket do
            expected "the opening bracket of a case expression", word
            snippet self
          end },
          ->{ error :case_expected_closing_bracket do
            expected "the closing bracket of a case expression", word
            snippet self
          end }
        ) { many { case_branch(for_css) || comment } }

        error :case_expected_branches do
          expected "a branch of a case expression", word
          snippet self
        end if body.empty?

        branches = [] of Ast::CaseBranch
        comments = [] of Ast::Comment

        body.each do |item|
          case item
          when Ast::CaseBranch
            branches << item
          when Ast::Comment
            comments << item
          end
        end

        Ast::Case.new(
          condition: condition,
          from: start_position,
          branches: branches,
          comments: comments,
          await: await,
          to: position,
          file: file)
      end
    end
  end
end
