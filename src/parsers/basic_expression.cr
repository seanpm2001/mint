module Mint
  class Parser
    # NOTE: The order of the parsing is important!
    def basic_expression : Ast::Expression?
      case left =
        format_directive ||
          highlight_directive ||
          documentation_directive ||
          svg_directive ||
          asset_directive ||
          inline_directive ||
          env ||
          locale_key ||
          here_doc ||
          string_literal ||
          regexp_literal ||
          bool_literal ||
          number_literal ||
          unary_minus ||
          array ||
          record_update ||
          record ||
          tuple_literal ||
          code_block ||
          html_element ||
          html_expression ||
          html_component ||
          html_fragment ||
          member_access ||
          constant_access ||
          module_access ||
          decode ||
          encode ||
          if_expression ||
          for_expression ||
          next_call ||
          return_call ||
          case_expression ||
          parenthesized_expression ||
          inline_function ||
          enum_id ||
          negated_expression ||
          js ||
          void ||
          variable
      when Nil
        nil
      else
        # We try to chain accesses and calls until we can in this loop.
        loop do
          node =
            if keyword_ahead? "::"
              access(left)
            else
              case char
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
