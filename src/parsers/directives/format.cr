module Mint
  class Parser
    def format_directive : Ast::Directives::Format?
      parse do |start_position|
        next unless word! "@format"
        whitespace

        content =
          code_block2(
            ->{ error :format_directive_expected_opening_bracket do
              expected "the opening bracket of a format directive", word
              snippet self
            end },
            ->{ error :format_directive_expected_closing_bracket do
              expected "the closing bracket of a format directive", word
              snippet self
            end },
            ->{ error :format_directive_expected_body do
              expected "body of a format directive", word
              snippet self
            end })

        next unless content

        Ast::Directives::Format.new(
          from: start_position,
          content: content,
          to: position,
          file: file)
      end
    end
  end
end
