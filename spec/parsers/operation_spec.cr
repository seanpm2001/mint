require "../spec_helper"

describe "Operation" do
  it "parses simple operation" do
    operation =
      Mint::Parser.new("a == b", "TestFile.mint")
        .expression!(Mint::SyntaxError)
        .as(Mint::Ast::Operation)

    operation.operator.should eq "=="
    operation.left.should be_a(Mint::Ast::Value)
    operation.right.should be_a(Mint::Ast::Value)
  end

  it "honors precedence" do
    operation =
      Mint::Parser.new("a == b * c", "TestFile.mint")
        .expression!(Mint::SyntaxError)
        .as(Mint::Ast::Operation)

    operation.operator.should eq "=="
    operation.left.should be_a(Mint::Ast::Value)
    operation.right.should be_a(Mint::Ast::Operation)
  end

  it "honors precedence 2" do
    operation =
      Mint::Parser.new("a * b == c", "TestFile.mint")
        .expression!(Mint::SyntaxError)
        .as(Mint::Ast::Operation)

    operation.operator.should eq "=="
    operation.left.should be_a(Mint::Ast::Operation)
    operation.right.should be_a(Mint::Ast::Value)

    left = operation.left.as(Mint::Ast::Operation)
    left.operator.should eq "*"
    left.left.should be_a(Mint::Ast::Value)
    left.right.should be_a(Mint::Ast::Value)
  end
end
