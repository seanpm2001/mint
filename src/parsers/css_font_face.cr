module Mint
  class Parser
    def css_font_face : Ast::CssFontFace?
      parse do |start_position|
        next unless word! "@font-face"
        whitespace

        definitions =
          brackets(
            ->{ error :css_font_face_expected_opening_bracket do
              expected "the opening bracket of a CSS font-face rule", word
              snippet self
            end },
            ->{ error :css_font_face_expected_closing_bracket do
              expected "the closing bracket of a CSS font-face rule", word
              snippet self
            end }) do
            items = many { comment || css_definition }

            next error :css_font_face_expected_definitions do
              expected "the definitions of a CSS font-face rule", word
              snippet self
            end if items.empty?

            items
          end

        next unless definitions

        Ast::CssFontFace.new(
          definitions: definitions,
          from: start_position,
          to: position,
          file: file)
      end
    end
  end
end
