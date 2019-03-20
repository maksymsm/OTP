require "./lexer"

program = Lexer.new('input.txt')
program.parser
program.print_lexem
