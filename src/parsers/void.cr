module Mint
  class Parser
    def void : Ast::Void?
      parse do |start_position|
        next unless word! "void"

        Ast::Void.new(
          from: start_position,
          to: position,
          input: data)
      end
    end
  end
end
