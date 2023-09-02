module Mint
  class Parser
    def if_expression(for_css = false) : Ast::If?
      thruthy_opening_error = ->{ error :if_expected_truthy_opening_bracket do
        expected "the opening bracket of the truthy expression", word
        snippet self
      end }

      thruthy_closing_error = ->{ error :if_expected_truthy_closing_bracket do
        expected "the closing bracket of the truthy expression", word
        snippet self
      end }

      thruthy_error = ->{ error :if_expected_truthy_expression do
        block do
          text "The"
          bold "body of an if expression"
          text "must be a single expression."
        end

        expected "an expression", word
        snippet self
      end }

      else_opening_error = ->{ error :if_expected_else_opening_bracket do
        expected "the opening bracket of the else expression", word
        snippet self
      end }

      else_closing_error = ->{ error :if_expected_else_closing_bracket do
        expected "the closing bracket of the else expression", word
        snippet self
      end }

      else_error = ->{ error :if_expected_else_expression do
        block do
          text "The"
          bold "body of an if expression"
          text "must be a single expression."
        end

        expected "an expression", word
        snippet self
      end }

      parse do |start_position|
        next unless word! "if"
        whitespace

        parens = char! '('
        whitespace

        next error :if_expected_condition do
          block do
            text "The"
            bold "condition"
            text "of an if expression"
            bold "must be a single expression."
          end

          expected "the condition", word
          snippet self
        end unless condition = statement || expression
        whitespace

        next error :if_expected_closing_parenthesis do
          expected "the closing parenthesis of the condition of an if expression", word
          snippet self
        end if parens && !char!(')')
        whitespace

        truthy =
          if for_css
            brackets(thruthy_opening_error, thruthy_closing_error) do
              many { css_definition }
            end
          else
            block(
              opening_bracket_error: thruthy_opening_error,
              closing_bracket_error: thruthy_closing_error,
              statement_error: thruthy_error)
          end

        next thruthy_error.call unless truthy

        falsy = nil
        whitespace

        if word! "else"
          whitespace

          unless falsy = if_expression(for_css: for_css)
            falsy =
              if for_css
                brackets(else_opening_error, else_closing_error) do
                  many { css_definition }
                end
              else
                block(
                  opening_bracket_error: else_opening_error,
                  closing_bracket_error: else_closing_error,
                  statement_error: else_error)
              end

            next else_error.call unless falsy
          end
        end

        Ast::If.new(
          branches: {truthy, falsy},
          condition: condition,
          from: start_position,
          to: position,
          file: file).tap do |node|
          case condition
          when Ast::Statement
            condition.if_node = node
          end
        end
      end
    end
  end
end
