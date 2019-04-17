require "./SyntaxAnalyzer/machine_Knuth"
require "./SyntaxAnalyzer/Tree"

class Parser
  def initialize(tokens, position_token)
      @tokens = tokens
      @pos_tokens = position_token
  end

  def analizical_machine_Knuth
    address_operation = 0
    code_operation = 1
    address_true = 2
    address_false = 3
    stack = []
    tokens_stack = []

    table_index = find_address_operation("<start>")
    token_index = 0
    token_to_tree = ''
    find_error = false
    take_address = ' '
    @tree = Tree.new

    while true
      if take_address != ' '
        @tree.current_element = @tree.current_element.parent_element
      elsif $table_Knuth[table_index][code_operation][0] == '<'
        @tree.add($table_Knuth[table_index][code_operation])

        tokens_stack.push(token_index)
        stack.push(table_index)
        table_index = find_address_operation($table_Knuth[table_index][code_operation])
        next
      end

      if take_address == 'false'
        command = $table_Knuth[table_index][address_false]
        take_address = ' '
      elsif take_address == 'true'
        command = $table_Knuth[table_index][address_true]
        take_address = ' '
      elsif take_address == 'empty'
        command = $table_Knuth[table_index][address_true]
        take_address = ' '
      elsif $table_Knuth[table_index][code_operation] == 'identifier' && ($IDENTIFICATORS_TOKENS.include? get_token_by_key(@tokens[token_index]))
        command = $table_Knuth[table_index][address_true]
        token_to_tree = get_token_by_key(@tokens[token_index])
        token_index += 1
      elsif $table_Knuth[table_index][code_operation] == 'empty-block' && get_token_by_key(@tokens[token_index]) == "END"
        command = $table_Knuth[table_index][address_true]
      elsif $table_Knuth[table_index][code_operation] == 'empty' && get_token_by_key(@tokens[token_index]) == "BEGIN"
        command = $table_Knuth[table_index][address_true]
      elsif $table_Knuth[table_index][code_operation] == 'unsigned-integer' && ($DIGITS_TOKENS.include? get_token_by_key(@tokens[token_index]))
        command = $table_Knuth[table_index][address_true]
        token_to_tree = get_token_by_key(@tokens[token_index])
        token_index += 1
      elsif $table_Knuth[table_index][code_operation] == get_token_by_key(@tokens[token_index])
        command = $table_Knuth[table_index][address_true]
        token_index += 1
      else
        command = $table_Knuth[table_index][address_false]
      end


      if $table_Knuth[table_index][code_operation][0] != '<' && ($table_Knuth[table_index][code_operation] != 'empty-block' || get_token_by_key(@tokens[token_index]) == "END") && !($table_Knuth[table_index][code_operation] == 'unsigned-integer' && ($IDENTIFICATORS_TOKENS.include? get_token_by_key(@tokens[token_index])))
        if command == 'empty' || $table_Knuth[stack.last][address_false] == '  ' && get_token_by_key(@tokens[token_index]) == 'RETURN'
          @tree.add('<empty>')
        else
          @tree.add($table_Knuth[table_index][code_operation])
        end
        if token_to_tree != ''
          @tree.add(token_to_tree)
          @tree.current_element = @tree.current_element.parent_element
          token_to_tree = ''
        end
        @tree.current_element = @tree.current_element.parent_element
      end



      if command == ' '
        table_index += 1
      elsif command == '  '
        table_index += 3
      elsif command == '   '
        table_index += 2
      elsif command == 'true'
        table_index = stack.pop()
        take_address = 'true'
      elsif command == 'false'
        if !find_error && $table_Knuth[stack.last][address_false] != 'empty' && $table_Knuth[stack.last][address_false] != ' ' && $table_Knuth[stack.last][address_false] != '  '
          if $table_Knuth[table_index][code_operation] != 'unsigned-integer' && ($IDENTIFICATORS_TOKENS.include? get_token_by_key(@tokens[token_index]))
            pp $table_Knuth[stack[-2]]
            pp $table_Knuth[stack.last]
            pp $table_Knuth[table_index]
            puts "Syntax error: expected: " + $table_Knuth[table_index][code_operation] + " on row: " +  @pos_tokens[token_index][0].to_s + ", col: " + @pos_tokens[token_index][1].to_s
            find_error = true
            break
          end
        end
        table_index = stack.pop()
        take_address = 'false'
      elsif command == 'empty'
        table_index = stack.pop()
        take_address = 'true'
      elsif command == 'OK'
        puts
        puts 'program ok'
        break
      elsif command == 'Error'
        puts 'program error'
        break
      end
    end
    @tree.print_tree
  end


  def get_token_by_key(num)
    if num < 256
      token = $SEPARATORS_TOKENS.key(num)
    elsif num < 501
      token = $KEY_WORDS_TOKENS.key(num)
    elsif num < 1001
      token = $DIGITS_TOKENS.key(num)
    else
      token = $IDENTIFICATORS_TOKENS.key(num)
    end
    token
  end

  def find_address_operation(string)
    $table_Knuth.each_with_index do |line, index|
      return index if line[0] == string
    end
    nil
  end
end
