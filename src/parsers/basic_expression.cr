module Mint
  class Parser
    # NOTE: The order of the parsing is important!
    def basic_expression : Ast::Expression?
      left =
        case char
        when '@'
          documentation_directive ||
            highlight_directive ||
            format_directive ||
            inline_directive ||
            asset_directive ||
            svg_directive ||
            env
        when '-'
          unary_minus
        when '('
          parenthesized_expression ||
            inline_function
        when '!'
          negated_expression
        when '"'
          string_literal
        when '/'
          regexp_literal
        when ':'
          locale_key
        when '['
          array_literal
        when '<'
          html_expression ||
            html_component ||
            html_element ||
            here_doc ||
            html_fragment
        when '{'
          record_update ||
            record ||
            tuple_literal ||
            block
        when '.'
          member_access
        when '`'
          js
        when .ascii_number?
          number_literal
        else
          case word
          when "case"
            case_expression
          when "for"
            for_expression
          when "if"
            if_expression
          when "true", "false"
            bool_literal
          when "return"
            return_call
          when "next"
            next_call
          when "decode"
            decode
          when "encode"
            encode
          else
            enum_id || variable
          end
        end

      case left
      when Nil
        nil
      else
        # We try to chain accesses and calls until we can in this loop.
        loop do
          node =
            if word? "::"
              access(left)
            else
              case char
              when ':'
                access(left)
              when '.'
                access(left)
              when '('
                call(left)
              when '['
                array_access(left)
              end
            end

          break unless node
          left = node
        end

        left
      end
    end
  end
end
