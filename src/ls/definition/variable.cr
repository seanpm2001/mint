module Mint
  module LS
    class Definition < LSP::RequestMessage
      def definition(node : Ast::Variable, workspace : Workspace, stack : Array(Ast::Node))
        lookup = workspace.type_checker.variables[node]?

        if lookup
          case {lookup[0], lookup[1]}
          when {Ast::Variable, _}
            variable_lookup_parent(node, lookup[0].as(Ast::Variable), workspace)
          when {Ast::ConnectVariable, Ast::Node}
            connect =
              workspace.ast.nodes
                .select(Ast::Connect)
                .find(&.keys.find(&.==(lookup[0].as(Ast::ConnectVariable))))
                .not_nil!

            key =
              lookup[0].as(Ast::ConnectVariable)

            location_link node, key.name || key.variable, connect
          else
            variable_lookup(node, lookup[0])
          end
        else
          variable_record_key(node, workspace, stack) ||
            variable_next_key(node, workspace, stack)
        end
      end

      def variable_lookup_parent(node : Ast::Variable, target : TypeChecker::Artifacts::Node, workspace : Workspace)
        case target
        when Tuple(String, TypeChecker::Checkable, Ast::Node)
          case variable = target[2]
          when Ast::Variable
            # For some variables in the .variables` cache, we only have access to the
            # target Ast::Variable and not its containing node, so we must search for it
            return unless parent = workspace
                            .ast
                            .nodes
                            .select { |other| other.is_a?(Ast::EnumDestructuring) || other.is_a?(Ast::Statement) || other.is_a?(Ast::For) }
                            .select(&.input.file.==(variable.input.file))
                            .find { |other| other.from < variable.from && other.to > variable.to }

            location_link node, variable, parent
          end
        end
      end

      def variable_lookup_parent(node : Ast::Variable, variable : Ast::Variable, server : Server, workspace : Workspace)
        # For some variables in the .variables` cache, we only have access to the
        # target Ast::Variable and not its containing node, so we must search for it
        return unless parent = workspace
                        .ast
                        .nodes
                        .select { |other| other.is_a?(Ast::EnumDestructuring) || other.is_a?(Ast::Statement) || other.is_a?(Ast::For) }
                        .select(&.input.file.==(variable.input.file))
                        .find { |other| other.from < variable.from && other.to > variable.to }

        location_link server, node, variable, parent
      end

      def variable_lookup(node : Ast::Variable, target : Ast::Node | TypeChecker::Checkable)
        case item = target
        when Ast::Node
          name = case item
                 when Ast::Property,
                      Ast::Constant,
                      Ast::Function,
                      Ast::State,
                      Ast::Get,
                      Ast::Argument
                   item.name
                 else
                   item
                 end

          location_link node, name, item
        end
      end

      def variable_record_key(node : Ast::Variable, workspace : Workspace, stack : Array(Ast::Node))
        case field = stack[1]?
        when Ast::RecordField
          return unless record_name = workspace.type_checker.record_field_lookup[field]?

          return unless record_definition_field = workspace
                          .ast
                          .records
                          .find(&.name.value.==(record_name))
                          .try(&.fields.find(&.key.value.==(node.value)))

          location_link node, record_definition_field.key, record_definition_field
        end
      end

      def variable_next_key(node : Ast::Variable, workspace : Workspace, stack : Array(Ast::Node))
        case next_call = stack[3]?
        when Ast::NextCall
          return unless parent = workspace.type_checker.lookups[next_call]

          return unless state = case parent
                                when Ast::Provider, Ast::Component, Ast::Store
                                  parent.states.find(&.name.value.==(node.value))
                                end

          location_link node, state.name, state
        end
      end
    end
  end
end
