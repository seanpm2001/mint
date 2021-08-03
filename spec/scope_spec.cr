require "./spec_helper"

Dir
  .glob("./spec/scope/**/*")
  .select! { |file| File.file?(file) }
  .sort!
  .each do |file|
    it file do
      source, location, variables = File.read(file).partition(/^\-+(\d+):(\d+)/m)

      line, column = /^\-+(\d+):(\d+)/.match(location).try(&.captures) || [] of String

      ast =
        Mint::Parser.parse(source, "source.mint")

      node =
        ast.nodes.find(&.location.contains?((line || 0).to_i32, (column || 0).to_i32))

      raise "No node!" unless node

      scope =
        Mint::TypeChecker::Scope2.new(ast)

      resolved =
        scope.resolve(node)

      variables.scan(/^(\w+)\s->\s(\w+)/m) do |match|
        resolved[match.captures[0]].class.name.should eq("Mint::Ast::#{match.captures[1]}")
      end
    end
  end
