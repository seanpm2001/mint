module Mint
  class Parser
    def css_nested_at : Ast::CssNestedAt?
      parse do |start_position|
        next unless char! '@'

        name = gather { word!("media") || word!("supports") }

        next unless name
        next unless whitespace?

        content =
          gather { chars { char != '{' } }.presence.try(&.strip)

        next error :css_nested_at_expected_condition do
          expected "the condition of a CSS at rule", word
          snippet self
        end unless content

        body =
          brackets(
            ->{ error :css_nested_at_expected_opening_bracket do
              expected "the opening bracket of a CSS at rule", word
              snippet self
            end },
            ->{ error :css_nested_at_expected_closing_bracket do
              expected "the closing bracket of a CSS at rule", word
              snippet self
            end }) { css_body }

        next unless body

        next error :css_nested_at_expected_body do
          expected "the body of a CSS at rule", word
          snippet self
        end if body.empty?

        Ast::CssNestedAt.new(
          from: start_position,
          content: content,
          to: position,
          file: file,
          name: name,
          body: body)
      end
    end
  end
end
