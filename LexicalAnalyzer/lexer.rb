require "./LexicalAnalyzer/print"

class Lexer
  def initialize(file_name)
    @file = file_name
  end

  def parser
    white_space = [32, 13, 12, 11, 10, 9]
    digits = (48..57).to_a
    chars = (65..90).to_a
    separators = ($SEPARATORS_TOKENS.keys).to_a
    key_words = ($KEY_WORDS_TOKENS.keys).to_a
    @lex_list = []
    @position_lex = []
    @col = 0
    @row = 1
    read_next = true
    constant_counter = 501
    ident_counter = 1001

    file = File.open(@file, 'r')

    while true do
      if read_next
        s = file.getc
        @col += 1
      end
      break if !s
      read_next = true

      if s == "\n"
        @row += 1
        @col = 0
      end

      if white_space.include? s.ord
        next
      end

      if separators.include? s

        if s == '('
          complete = can_be_comment(file)
          comment = complete[1]
          if complete.first != nil && !comment
            @lex_list.push($SEPARATORS_TOKENS[s])
            @position_lex.push([@row, @col])
            # puts "find token - "+ s + " on row: " + @row.to_s + "  col: " + @col.to_s
            @col += 1
            read_next = false
            s = complete.first
          end
          #cur, false
        else
          @lex_list.push($SEPARATORS_TOKENS[s])
          @position_lex.push([@row, @col])
          # puts "find token - " + s + " on row: " + @row.to_s + "  col: " + @col.to_s
        end

      elsif chars.include? s.ord

        complete = word_indicate(file, chars, digits, s)
        complete_word = complete.first
        s = complete[1]
        read_next = false

        if key_words.include? complete_word
          @lex_list.push($KEY_WORDS_TOKENS[complete_word])
          @position_lex.push([@row, @col - complete_word.to_s.length])
          # puts "find token - " + complete_word + " on row: " + @row.to_s + "  col: " + (@col - complete_word.length).to_s
        else
          if $IDENTIFICATORS_TOKENS.keys().include? complete_word
            @lex_list.push($IDENTIFICATORS_TOKENS[complete_word])
            @position_lex.push([@row, @col - complete_word.to_s.length])
            # puts "find token - " + complete_word + " on row: " + @row.to_s + "  col: " + (@col - complete_word.length).to_s
          else
            $IDENTIFICATORS_TOKENS[complete_word] = ident_counter
            # puts "find token - " + complete_word + " on row: " + @row.to_s + "  col: " + (@col - complete_word.length).to_s
            @lex_list.push(ident_counter)
            @position_lex.push([@row, @col - ident_counter.to_s.length - 1])
            ident_counter += 1
          end
        end

      elsif digits.include? s.ord

        complete = digit_indicate(file, digits, s)
        complete_digit = complete.first
        s = complete[1]
        read_next = false

        if $DIGITS_TOKENS.keys().include? complete_digit
          @lex_list.push($DIGITS_TOKENS[complete_digit])
          @position_lex.push([@row, @col - complete_digit.to_s.length])
          # puts "find token - " + complete_digit + " on row: " + @row.to_s + "  col: " + (@col - complete_digit.length).to_s
        else
          $DIGITS_TOKENS[complete_digit] = constant_counter
          @lex_list.push(constant_counter)
          @position_lex.push([@row, @col - constant_counter.to_s.length])
          # puts "find token - " + complete_digit + " on row: " + @row.to_s + "  col: " + (@col - complete_digit.length).to_s
          constant_counter += 1
        end

      else
        $error.push("Lexem error: unknow symbol on row: " + @row.to_s + ", col: " + @col.to_s)
        puts $error.last
      end
    end

    def print_lexem()
      printTokens()
      pp "Lexer list - " + @lex_list.to_s
    end
    $position_token = @position_lex
    @lex_list
  end

  private

  def can_be_comment(file)
    cur = file.getc

    if cur == '*'
      @col += 1
      open_comment = true
      # puts "Comment open", @col, @row
      cur = file.getc
      @col += 1
      while cur
        if cur == '*'
          cur = file.getc
          @col += 1
          if cur == ')'
            open_comment = false
            # puts "Comment closed", @col, @row
            break
          end
        else
          cur = file.getc
          @col += 1
        end
        if cur == "\n"
          @row += 1
          @col = 0
        end
      end
      if open_comment
        $error.push("Lexem errer: Unclosed comment!")
        puts $error.last
      end
      return [nil, true]
    else
      return [cur, false]
    end
  end

  def word_indicate(file, chars, digits, string)
    cur = file.getc
    @col += 1
    if (chars.include? cur.ord) || (digits.include? cur.ord)
      string << cur
      word_indicate(file, chars, digits, string)
    else
      return [string, cur]
    end
  end

  def digit_indicate(file, digits, string)
    cur = file.getc
    @col += 1
    if digits.include? cur.ord
      string << cur
      digit_indicate(file, digits, string)
    else
      return [string, cur]
    end
  end
end
