module Mint
  class Parser
    def type_id(*, track : Bool = true) : Ast::TypeId?
      parse(track: track) do |start_position|
        return unless value = identifier_type

        Ast::TypeId.new(
          from: start_position,
          value: value,
          to: position,
          file: file)
      end
    end
  end
end
