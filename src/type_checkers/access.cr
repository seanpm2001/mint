module Mint
  class TypeChecker
    type_error AccessFieldNotFound
    type_error AccessNotRecord

    def check(node : Ast::Access) : Checkable
      target =
        resolve node.lhs

      check_access(node, target)
    end

    def check_access(node, target) : Checkable
      raise AccessNotRecord, {
        "object" => target,
        "node"   => node,
      } unless target.is_a?(Record)

      new_target = target.fields[node.field.value]?

      raise AccessFieldNotFound, {
        "field"  => node.field.value,
        "node"   => node.field,
        "target" => target,
      } unless new_target

      if item = entity_records.find(&.last.==(target))
        entity, _ = item

        y =
          case x = entity
          when Ast::Module
            x.functions.find(&.name.value.==(node.field.value))
          when Ast::Provider
            if node.field.value == "subscriptions"
              lookups[node] = x
              new_target
            else
              x.gets.find(&.name.value.==(node.field.value)) ||
                x.functions.find(&.name.value.==(node.field.value)) ||
                x.states.find(&.name.value.==(node.field.value))
            end
          when Ast::Store
            x.gets.find(&.name.value.==(node.field.value)) ||
              x.functions.find(&.name.value.==(node.field.value)) ||
              x.states.find(&.name.value.==(node.field.value))
          when Ast::Component
            refs =
              x.refs.reduce({} of String => Ast::Node) do |memo, (variable, ref)|
                case ref
                when Ast::HtmlComponent
                  entity_records
                    .find do |z|
                      case z
                      when Ast::Component
                        z.first.name == ref.component.value
                      when Ast::Module
                        z.first.name == ref.component.value
                      else
                        false
                      end
                    end
                    .try do |z|
                      memo[variable.value] = z.first
                    end
                when Ast::HtmlElement
                  memo[variable.value] = variable
                end

                memo
              end

            (x.gets.find(&.name.value.==(node.field.value)) ||
              x.functions.find(&.name.value.==(node.field.value)) ||
              x.properties.find(&.name.value.==(node.field.value)) ||
              refs[node.field.value]? ||
              x.states.find(&.name.value.==(node.field.value)))
          end

        case y
        when Ast::Node
          lookups[node.field] = y.not_nil!

          scope(entity) do
            resolve lookups[node.field]
          end
        when Type
          y
        else
          NEVER
        end
      else
        record_field_lookup[node.field] = new_target.name
      end

      new_target
    end
  end
end
