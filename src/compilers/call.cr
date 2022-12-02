module Mint
  class Compiler
    def _compile(node : Ast::Call) : String
      case item = lookups[node.expression]?
      when Ast::EnumOption
        name =
          js.class_of(item)

        arguments =
          if node.arguments.size > 0 && node.arguments.all?(Ast::RecordField)
            _compile(Ast::Record.new(
              fields: node.arguments.select(Ast::RecordField),
              input: Ast::Data.new("", ""),
              from: 0,
              to: 2
            ))
          else
            compile node.arguments, ","
          end

        "new #{name}(#{arguments})"
      else
        expression =
          compile node.expression

        arguments =
          compile node.arguments, ", "

        case
        when node.expression.is_a?(Ast::InlineFunction)
          "(#{expression})(#{arguments})"
        else
          "#{expression}(#{arguments})"
        end
      end
    end
  end
end
