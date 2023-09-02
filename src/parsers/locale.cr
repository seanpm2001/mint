module Mint
  class Parser
    def locale : Ast::Locale?
      parse do |start_position|
        comment = self.comment

        next unless word! "locale"
        whitespace

        next error :locale_expected_language do
          expected "the language code of the locale", word
          snippet self
        end unless language = identifier_variable
        whitespace

        fields =
          brackets(
            ->{
              error :locale_expected_opening_bracket do
                expected "the opening bracket of a locale", word
                snippet self
              end
            },
            ->{
              error :locale_expected_closing_bracket do
                expected "the opening bracket of a locale", word
                snippet self
              end
            }
          ) do
            list(terminator: '}', separator: ',') { record_field }
          end

        next unless fields

        Ast::Locale.new(
          from: start_position,
          language: language,
          comment: comment,
          fields: fields,
          to: position,
          file: file)
      end
    end
  end
end
