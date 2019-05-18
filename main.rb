require "./LexicalAnalyzer/lexer"
require "./SyntaxAnalyzer/parser"
require "./CodeGenerator/generator"

program = Lexer.new('input.txt')
tokens = program.parser
program.print_lexem

if $error.length == 0
  parse = Parser.new(tokens, $position_token)
  tree = parse.analizical_machine_Knuth
  tree.print_tree
  code = CodeGenerator.new(tree) if $error.length == 0
  code.generate if $error.length == 0
  puts
  puts $error
end
