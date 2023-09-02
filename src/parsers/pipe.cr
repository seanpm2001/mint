module Mint
  class Parser
    # This method rolls an operation where the operator is "|>" into a single
    # call. Every other operation is passed trough.
    def rollup_pipe(operation : Ast::Operation) : Ast::Pipe | Ast::Operation?
      return operation unless operation.operator == "|>"

      expression = operation.right
      argument = operation.left

      argument =
        case argument
        when Ast::Operation
          rollup_pipe(argument)
        else
          argument
        end

      Ast::Pipe.new(
        expression: expression,
        argument: argument,
        from: argument.from,
        to: expression.to,
        file: file)
    end

    def rollup_pipe(operation : Nil) : Ast::Pipe | Ast::Operation?
      nil
    end
  end
end
