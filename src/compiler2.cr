module Mint
  class Compiler2
    include Helpers

    class JsNode
    end

    class JsSkip < JsNode
    end

    class JsVariable < JsNode
    end

    class JsDummy < JsNode
    end

    class JsString < JsNode
      getter value

      def initialize(@value : String)
      end
    end

    class JsArray < JsNode
      getter items

      def initialize(@items : Array(JsNode))
      end
    end

    class JsObject < JsNode
      getter fields

      def initialize(@fields : Hash(String, JsNode))
      end
    end

    class JsReturn < JsNode
      getter value

      def initialize(@value : JsNode)
      end
    end

    class JsModule < JsNode
      getter body, imports, path

      def initialize(@body : Array(JsNode),
                     @imports : Imports,
                     @path : String)
      end
    end

    class JsCall < JsNode
      getter arguments, target

      def initialize(@target : JsNode, @arguments : Array(JsNode))
      end
    end

    class JsClass < JsNode
      getter extends, named, body

      def initialize(@body : Array(JsNode), @extends : JsNode, @named : Bool)
      end
    end

    class JsAsyncIIF < JsNode
      getter body

      def initialize(@body : Array(JsNode))
      end
    end

    class JsIIF < JsNode
      getter body

      def initialize(@body : Array(JsNode))
      end
    end

    class JsStatements < JsNode
      getter items

      def initialize(@items : Array(JsNode))
      end
    end

    class JsDestructuring < JsNode
      getter items

      def initialize(@items : Array(JsNode))
      end
    end

    class JsIf < JsNode
      getter condition, thruthy

      def initialize(@condition : JsNode, @thruthy : JsNode)
      end
    end

    class JsOperation < JsNode
      getter operator, left, right

      def initialize(@operator : String, @left : JsNode, @right : JsNode)
      end
    end

    class JsFunction < JsNode
      getter arguments, body, async, name

      def initialize(@arguments : Array(JsNode), @body : Array(JsNode), @async : Bool, @name : String?)
      end
    end

    class JsAssignment < JsNode
      getter target, value

      def initialize(@target : JsNode, @value : JsNode)
      end
    end

    class JsConstant < JsNode
      getter target, value

      def initialize(@target : JsNode, @value : JsNode)
      end
    end

    class JsAccess < JsNode
      getter target, field

      def initialize(@target : JsNode, @field : JsNode)
      end
    end

    class JsValue < JsNode
      getter value

      def initialize(@value : String)
      end
    end

    class JsId < JsNode
      getter value

      def initialize(@value : JsNode)
      end
    end

    class JsInterpolation < JsNode
      getter value

      def initialize(@value : JsNode)
      end
    end

    class JsExpression < JsNode
      getter? await
      getter value

      def initialize(@value : JsNode, @await : Bool)
      end
    end

    class JsTemplateLiteral < JsNode
      getter items

      def initialize(@items : Array(JsNode))
      end
    end

    class JsExport < JsNode
      getter? default
      getter target

      def initialize(@target : JsNode, @default : Bool = false)
      end
    end

    getter mapping : Hash(Ast::Node, JsNode) = {} of Ast::Node => JsNode
    getter artifacts

    getter runtime_exports : Hash(Symbol, JsVariable) = {} of Symbol => JsVariable
    getter runtime : JsModule = JsModule.new([] of JsNode, Imports.new, "runtime.js")

    alias Imports = Set({from: JsModule, what: JsNode})

    def initialize(@artifacts : TypeChecker::Artifacts)
      runtime_exports[:component] = JsVariable.new
      runtime_exports[:tag] = JsVariable.new

      # runtime_exports.each do |_, value|
      #   runtime.exports[value] = JsDummy.new
      # end
    end

    def self.compile(artifacts : TypeChecker::Artifacts)
      compiler = new(artifacts)
      compiler.compile
    end

    def compile : Array(JsModule)
      compile(artifacts.ast.components) +
        compile(artifacts.ast.modules)
    end

    def compile(node : Ast::Node) : JsModule
      if node.in?(artifacts.checked)
        resolve(node)
      else
        raise "WTF"
      end
    end

    def compile(nodes : Array(Ast::Node)) : Array(JsModule)
      nodes.map { |item| resolve(item) }
    end

    def compile(nodes : Array(Ast::Node), imports : Imports) : Array(JsNode)
      nodes.map { |item| compile(item, imports).as(JsNode) }
    end

    def compile(node : Ast::Node, imports : Imports) : JsNode
      case node
      when Ast::Variable
        puts node.value
      end
      if item = mapping[node]?
        return item
      else
        if node.in?(artifacts.checked)
          resolve(node, imports).tap do |item|
            mapping[node] = item
          end
        else
          JsSkip.new
        end
      end
    end

    def resolve(node : Ast::Component) : JsModule
      imports = Imports.new
      imports.add({from: runtime, what: runtime_exports[:component]})

      body =
        compile(node.functions, imports)

      klass =
        JsClass.new(
          extends: runtime_exports[:component],
          named: true,
          body: body)

      JsModule.new([
        klass,
        JsAssignment.new(
          target: JsAccess.new(JsId.new(klass), JsValue.new("displayName")),
          value: JsString.new(node.name.value)),
        JsExport.new(klass, default: true),
      ] of JsNode, imports, node.name.value.underscore + ".mjs")
    end

    def resolve(node : Ast::Module) : JsModule
      imports = Imports.new

      body =
        compile(node.functions, imports)

      exports =
        body.map do |function|
          JsExport.new(function).as(JsNode)
        end

      JsModule.new(body + exports, imports, node.name.value.underscore + ".mjs")
    end

    def resolve(node : Ast::Node, imports : Imports) : JsNode
      puts "NO RESOLVER FOR: #{node.class.name}"
      JsSkip.new
    end

    class JsCompiler
      getter classPool : NamePool(JsNode, JsNode) = NamePool(JsNode, JsNode).new('A'.pred.to_s)
      getter pool : NamePool(JsNode, JsNode) = NamePool(JsNode, JsNode).new

      def id(what : JsNode, from : JsModule)
        # puts({what, from.path})
        case what
        when JsClass
          classPool.of(what, from)
        else
          pool.of(what, from)
        end
      end

      def compile(nodes : Array(JsNode), parent : JsNode, separator : String? = nil, end_token : String? = nil) : String
        result = nodes.join(separator) { |item| compile(item, parent) }
        result += end_token if end_token && !result.ends_with?(end_token)
        result
      end

      def compile(node : JsNode, parent : JsModule) : String
        puts node.class
        case node
        when JsReturn
          "return #{compile(node.value, parent)}"
        when JsString
          %("#{node.value}")
        when JsObject
          if node.fields.empty?
            "{}"
          else
            fields =
              node.fields.each do |key, value|
                "#{key}: #{compile(value, parent)}"
              end
            "{\n#{fields}\n}"
          end
        when JsCall
          arguments =
            compile node.arguments, parent, ", "

          "#{compile(node.target, parent)}(#{arguments})"
        when JsExport
          if node.default?
            "export default #{id(node.target, parent)}"
          else
            "export #{id(node.target, parent)}"
          end
        when JsFunction
          body =
            compile node.body, parent, ";\n", ";"

          name =
            node.name || id(node, parent)

          "#{name}() {\n#{body.indent}\n}"
        when JsStatements
          compile node.items, parent, ";\n", ";"
        when JsTemplateLiteral
          '`' + compile(node.items, parent, "") + '`'
        when JsClass
          body =
            compile node.body, parent, "\n\n"

          name =
            if node.named
              " #{id(node, parent)}"
            end

          "class#{name} extends #{id(node.extends, parent)} {\n#{body.indent}\n}"
        when JsSkip
          "SKIIIIIIIIIIIIIIIIP"
        when JsAccess
          "#{compile(node.target, parent)}.#{compile(node.field, parent)}"
        when JsAssignment
          "#{compile(node.target, parent)} = #{compile(node.value, parent)}"
        when JsConstant
          "const #{compile(node.target, parent)} = #{compile(node.value, parent)}"
        when JsIIF
          "(() => {})()"
        when JsValue
          node.value
        when JsId
          id(node.value, parent)
        else
          puts "NO JS COMPILER FOR: #{node.class.name}"
          "asdasd"
        end
      end

      def compile(node : JsModule) : String
        # We group imports by module and compile the import declaration.
        imports =
          unless node.imports.empty?
            node.imports.group_by { |item| item[:from] }.map do |from, items|
              bindings =
                items.map do |item|
                  external = id(item[:what], from)
                  internal = id(item[:what], node)

                  if external == internal
                    external
                  else
                    "#{external} as #{internal}"
                  end
                end.join(", ")

              %(import { #{bindings} } from "#{from.path}")
            end.join(";\n") + ";\n\n"
          end

        body =
          compile node.body, node, ";\n\n", ";"

        "#{imports}#{body}"
      end
    end
  end
end
