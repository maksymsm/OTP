require "./LexicalAnalyzer/lexer"
require "./SyntaxAnalyzer/parser"

program = Lexer.new('input.txt')
tokens = program.parser
program.print_lexem

if $error.length == 0
  parse = Parser.new(tokens, $position_token)
  parse.analizical_machine_Knuth
end
