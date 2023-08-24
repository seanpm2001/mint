module Mint
  class Parser
    def html_style : Ast::HtmlStyle?
      parse do |start_position|
        name = parse do
          next unless keyword "::"
          next unless value = variable track: false, extra_chars: ['-']
          value
        end

        next unless name

        arguments = [] of Ast::Node

        if char! '('
          whitespace

          arguments = list(terminator: ')', separator: ',') { expression }

          whitespace
          next error :html_style_expected_closing_parenthesis do
            expected "the closing parenthesis of an HTML style", word
            snippet self
          end unless char! ')'
        end

        Ast::HtmlStyle.new(
          arguments: arguments,
          from: start_position,
          to: position,
          input: data,
          name: name)
      end
    end
  end
end
