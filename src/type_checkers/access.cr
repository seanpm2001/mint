module Mint
  class TypeChecker
    def check(node : Ast::Access) : Checkable
      case variable = node.expression
      when Ast::Variable
        if variable.value[0].ascii_uppercase?
          if entity = lookup(variable)
            variables[variable] = {entity, entity, [] of Artifacts::Node}
            check!(entity)
            if target_node = @scope2.resolve(node.field.value, entity).try(&.node)
              variables[node] = {target_node, entity, [] of Artifacts::Node}
              variables[node.field] = {target_node, entity, [] of Artifacts::Node}
              return resolve target_node
            end
          end
        end
      end

      target =
        resolve node.expression

      error :access_not_record do
        snippet "You are trying to access a field on an object which is not a record:", target
        snippet node
      end unless target.is_a?(Record)

      new_target = target.fields[node.field.value]?

      error :access_field_not_found do
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
