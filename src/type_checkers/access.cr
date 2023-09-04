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

    def check(node : Ast::Access) : Checkable
      result =
        case variable = node.expression
        when Ast::Access
          stack = unwind_access(node)
          possibilities = [] of String
          target = ""

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

          found = nil
          possibilities.each do |target| # ameba:disable Lint/ShadowingOuterLocalVar
            break if found = scope.resolve(target, node).try(&.node)
          end

          {found, target}
        when Ast::Variable
          {lookup(variable), variable.value}
        end

      if result
        entity, entity_name = result

        if entity && entity_name[0].ascii_uppercase?
          variables[node.expression] = {entity, entity}
          check!(entity)
          if target_node = scope.resolve(node.field.value, entity).try(&.node)
            variables[node] = {target_node, entity}
            variables[node.field] = {target_node, entity}
            return resolve target_node
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
