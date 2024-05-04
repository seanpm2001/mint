module Mint
  class Formatter
    def format(node : Ast::Record, multiline = false) : String
      body =
        format node.fields

      if node.fields.size >= 2 || multiline || body.any? do |string|
           replace_skipped(string).includes?('\n')
         end
        "{\n#{indent(list(node.fields.zip(body), ","))}\n}"
      else
        body =
          body.join(", ").presence.try { |v| " #{v} " } || " "

        "{#{body}}"
      end
    end
  end
end
