$KEY_WORDS_TOKENS = {"PROCEDURE" => 401, "BEGIN" => 402, "END" => 403, "RETURN" => 404}
$SEPARATORS_TOKENS = {";" => 59, "," => 44, "(" => 40, ")" => 41}
$IDENTIFICATORS_TOKENS = {}
$DIGITS_TOKENS = {}
$position_token = []
$error = []

def printTokens
  puts
  puts "Key words = " + $KEY_WORDS_TOKENS.to_s
  puts "Separators = " + $SEPARATORS_TOKENS.to_s
  puts "My identifiers = " + $IDENTIFICATORS_TOKENS.to_s
  puts "My digits = " + $DIGITS_TOKENS.to_s
  puts
end
