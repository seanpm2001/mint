require "./spec_helper"

path = ENV["EXAMPLE"]? || "./spec/compilers2/**/*"

Dir
  .glob(path)
  .select! { |file| File.file?(file) }
  .sort!
  .each do |file|
    it file do
      begin
        contents = File.read(file)
        expected = {} of String => String
        position = 0
        sample = ""

        contents.scan(/^\-+([\w._]+)?/m) do |match|
          text = contents[position, match.begin - position]

          if match[1]?
            expected[match[1]] = text
          else
            sample = text
          end

          position = match.end
        end

        # Parse the sample
        ast = Mint::Parser.parse(sample, file)
        ast.class.should eq(Mint::Ast)

        artifacts =
          Mint::TypeChecker.check(ast)

        modules =
          Mint::Compiler2.compile(artifacts)

        jsc =
          Mint::Compiler2::JsCompiler.new

        expected.each do |path, contents|
          begin
            result = jsc.compile(modules.find!(&.path.==(path)))
          rescue error : Mint::Error
            fail error.to_terminal.to_s
          end

          begin
            result.should eq(contents.strip)
          rescue error
            fail diff(contents, result)
          end
        end
      rescue error : Mint::Error
        fail error.to_terminal.to_s
      end
    end
  end
