module Mint
  class TypeChecker
    def unwind_access(node : Ast::Access, stack = [] of Ast::Node) : Array(Ast::Node)
      case item = node.expression
      when Ast::Access
        stack.unshift(item.field)
        unwind_access(item, stack)
      when Ast::Variable
        stack.unshift(node.expression)
      end

      stack
    end

    def to_function_type(node : Ast::EnumOption, parent : Ast::Enum)
      parent_type =
        resolve parent

      option_type =
        resolve node

      if node.parameters.empty?
        parent_type
      else
        parameters =
          case item = node.parameters.first?
          when Ast::EnumRecordDefinition
            item.fields.map do |field|
              type =
                resolve field.type

              type.label = field.key.value
              type
            end
          else
            option_type.parameters.dup
          end

        parameters << parent_type.as(Checkable)
        Comparer.normalize(Type.new("Function", parameters))
      end
    end

    def check(node : Ast::Access) : Checkable
      possibilities = [] of String

      result =
        case variable = node.expression
        when Ast::Access
          stack = unwind_access(node)
          target = ""
          found = nil

          loop do
            case item = stack.shift?
            when Ast::Variable
              target +=
                if target.blank?
                  item.value
                else
                  "." + item.value
                end

              possibilities.unshift target
            else
              break
            end
          end
        when Ast::Variable
          possibilities << variable.value
        end

      possibilities.each do |possibility|
        if parent = ast.enums.find(&.name.value.==(possibility))
          if option = parent.options.find(&.value.value.==(node.field.value))
            variables[node] = {option, parent}
            return to_function_type(option, parent)
          end
        end

        if entity = scope.resolve(possibility, node).try(&.node)
          if entity && possibility[0].ascii_uppercase?
            variables[node.expression] = {entity, entity}
            check!(entity)
            if target_node = scope.resolve(node.field.value, entity).try(&.node)
              variables[node] = {target_node, entity}
              variables[node.field] = {target_node, entity}
              return resolve target_node
            end
          end
        end
      end

      target =
        resolve node.expression

      error! :access_not_record do
        snippet "You are trying to access a field on an object which is not a record:", target
        snippet node
      end unless target.is_a?(Record)

      new_target = target.fields[node.field.value]?

      error! :access_field_not_found do
        block do
          text "The accessed field"
          code node.field.value
          text "does not exists on the entity:"
        end

        snippet target
        snippet "The access is here:", node
      end unless new_target

      if item = component_records.find(&.last.==(target))
        component, _ = item

        refs =
          component.refs.reduce({} of String => Ast::Node) do |memo, (variable, ref)|
            case ref
            when Ast::HtmlComponent
              component_records
                .find(&.first.name.value.==(ref.component.value))
                .try do |record|
                  memo[variable.value] = record.first
                end
            when Ast::HtmlElement
              memo[variable.value] = variable
            end

            memo
          end

        lookups[node.field] =
          (component.gets.find(&.name.value.==(node.field.value)) ||
            component.functions.find(&.name.value.==(node.field.value)) ||
            component.properties.find(&.name.value.==(node.field.value)) ||
            refs[node.field.value]? ||
            component.states.find(&.name.value.==(node.field.value))).not_nil!

        resolve lookups[node.field]
      else
        record_field_lookup[node.field] = new_target.name
      end

      new_target
    end
  end
end
