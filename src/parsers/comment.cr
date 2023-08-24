module Mint
  class Parser
    def comment : Ast::Comment?
      parse do |start_position|
        value, type =
          if keyword "/*"
            consumed =
              gather { consume { !keyword_ahead?("*/") && !eof? } }.to_s

            next error :comment_expected_closing_tag do
              expected "the closing tag of a comment", word
              snippet self
            end unless keyword "*/"

            {consumed, Ast::Comment::Type::Block}
          elsif keyword "//"
            consumed =
              gather { consume { char != '\n' && !eof? } }.to_s

            {consumed, Ast::Comment::Type::Inline}
          else
            {nil, Ast::Comment::Type::Block}
          end

        whitespace # TODO: Figure out why is this is needed
        next unless value

        self << Ast::Comment.new(
          from: start_position,
          value: value,
          type: type,
          to: position,
          input: data)
      end
    end
  end
end
