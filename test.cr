require "./src/all"

source = <<-A
  component Main {
    fun render : Html {
      <div/>
    }
  }
A

ast = Mint::Parser.parse(source, "source.mint")
artifacts = Mint::TypeChecker.check(ast)
compiler = Mint::Compiler2.new(artifacts)

item = compiler.compile(ast.components.first)
pp item

jsc = Mint::Compiler2::JsCompiler.new
puts jsc.compile(item)
