module Mint
  class TypeChecker
    type_error CallArgumentSizeMismatch
    type_error CallArgumentTypeMismatch
    type_error CallTypeMismatch
    type_error CallNotAFunction

    def check(node : Ast::Call)
      function_type =
        resolve node.expression

      if item = enum_constructor_data[node.expression]?
        check_enum_record node, item
      else
        check_call(node, function_type)
      end
    end

    def check_enum_record(node : Ast::Call, item : {Record, Type})
      option_type, parent_type =
        item

      parameters =
        resolve node.arguments

      resolved_type =
        Type.new(option_type.name, parameters)

      unified =
        Comparer.compare_raw(option_type, resolved_type)

      raise CallTypeMismatch, {
        "got"      => resolved_type,
        "expected" => option_type,
        "node"     => node,
      } unless unified

      extracted =
        extract_variables unified

      final_parameters =
        parent_type.parameters.map do |param|
          case param
          when Variable
            extracted[param.name]? || param
          else
            param
          end
        end

      Type.new(parent_type.name, final_parameters)
    end

    def check_call(node, function_type) : Checkable
      raise CallNotAFunction, {
        "node" => node,
      } unless function_type.name == "Function"

      argument_size =
        function_type.parameters.size - 1

      required_argument_size =
        case function_type
        when TypeChecker::Type
          argument_size - function_type.optional_count
        else
          argument_size
        end

      parameters =
        [] of Checkable

      raise CallArgumentSizeMismatch, {
        "call_size" => node.arguments.size.to_s,
        "size"      => argument_size.to_s,
        "node"      => node,
      } if node.arguments.size > argument_size ||       # If it's more than the maxium
           node.arguments.size < required_argument_size # If it's less then the minimum

      node.arguments.each_with_index do |argument, index|
        argument_type =
          resolve argument

        function_argument_type =
          function_type.parameters[index]

        raise CallArgumentTypeMismatch, {
          "index"    => ordinal(index + 1),
          "expected" => function_argument_type,
          "got"      => argument_type,
          "function" => function_type,
          "node"     => node,
        } unless Comparer.compare(function_argument_type, argument_type)

        parameters << argument_type
      end

      if (optional_param_count = argument_size - node.arguments.size) > 0
        parameters.concat(function_type.parameters[-2, optional_param_count])
      end

      call_type =
        Type.new("Function", parameters + [function_type.parameters.last])

      result =
        Comparer.compare(function_type, call_type)

      raise CallTypeMismatch, {
        "expected" => function_type,
        "got"      => call_type,
        "node"     => node,
      } unless result

      resolve_type(result.parameters.last)
    end

    def extract_variables(node : Checkable) : Hash(String, Checkable)
      extracted = {} of String => Checkable

      case node
      when Type
        node.parameters.each do |param|
          extracted.merge!(extract_variables(param))
        end
      when Variable
        extracted[node.name] = Comparer.prune(node)
      end

      extracted
    end
  end
end
