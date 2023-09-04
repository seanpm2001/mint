module Mint
  class Parser
    def value(subject : Symbol = :all) : Ast::Variable?
      parse do |start_position|
        name = gather { ascii_letters_or_numbers(extra_char: '_') }

        next unless name

        Ast::Variable.new(
          from: start_position,
          to: position,
          file: file,
          value: name)
      end
    end
  end
end
