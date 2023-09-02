module Mint
  class Parser
    def enum_record : Ast::EnumRecord?
      parse do |start_position, _, error_position|
        fields =
          list(
            terminator: ')',
            separator: ','
          ) { record_field }

        if error_position < @errors.size
          @errors.delete_at(error_position...)
          next
        end

        next if fields.empty?

        Ast::EnumRecord.new(
          from: start_position,
          fields: fields,
          to: position,
          input: data)
      end
    end
  end
end
