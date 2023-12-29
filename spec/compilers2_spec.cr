require "./spec_helper"

Dir
  .glob("./spec/compilers2/**/*")
  .select! { |file| File.file?(file) }
  .sort!
  .each do |file|
    next if File.basename(file).starts_with?("route")
    next if File.basename(file).starts_with?("static_component")
    it file do
      begin
        # Read and separate sample from expected
        sample, expected = File.read(file).split("-" * 80)

        # Parse the sample
        ast = Mint::Parser.parse(sample, file)
        ast.class.should eq(Mint::Ast)

        artifacts =
          Mint::TypeChecker.check(ast)

        config =
          Mint::Compiler2::Config.new(
            runtime_path: "runtime",
            css_prefix: nil,
            relative: false,
            optimize: false,
            build: true)

        result =
          Mint::Compiler2
            .spec(artifacts, config)
            .strip

        begin
          result.should eq(expected.strip)
        rescue error
          fail diff(expected, result)
        end
      rescue error : Mint::Error
        fail error.to_terminal.to_s
      end
    end
  end
