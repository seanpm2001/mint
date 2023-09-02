module Mint
  class Parser
    def enum_record_definition : Ast::EnumRecordDefinition?
      parse do |start_position, _, error_position|
        fields =
          list(
            terminator: ')',
            separator: ','
          ) { record_definition_field }

        # TODO: Get rid of this at some point
        if error_position < @errors.size
          @errors.delete_at(error_position...)
          next
        end

        next if fields.empty?

        Ast::EnumRecordDefinition.new(
          from: start_position,
          fields: fields,
          to: position,
          file: file)
      end
    end
  end
end
