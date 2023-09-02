module Mint
  class Parser
    def html_attribute(with_dashes : Bool = true, fixed_name : String? = nil) : Ast::HtmlAttribute?
      parse do |start_position|
        name = variable track: false, extra_chars: with_dashes ? ['-', ':'] : [] of Char

        next unless name
        next if fixed_name && name.value != fixed_name

        next error :html_attribute_expected_equal_sign do
          expected "the equal sign of an HTML attribute", word
          snippet self
        end unless char! '='

        case
        when word?("<{") && (value = html_expression)
          value
        when char == '"' && (value = string_literal)
          value
        when char == '[' && (value = array_literal)
          value
        else
          value = block(
            ->{ error :html_attribute_expected_opening_bracket do
              expected "the opening bracket of an HTML attribute", word
              snippet self
            end },
            ->{ error :html_attribute_expected_closing_bracket do
              expected "the closing bracket of an HTML attribute", word
              snippet self
            end },
            ->{ error :html_attribute_expected_expression do
              expected "the expression of an HTML attribute", word
              snippet self
            end })
        end

        next unless value

        Ast::HtmlAttribute.new(
          value: value.as(Ast::Expression),
          from: start_position,
          to: position,
          file: file,
          name: name)
      end
    end
  end
end
