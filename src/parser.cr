module Mint
  class Parser
    include Errorable

    # The position of the cursor, which is at the character we are currently
    # parsing.
    getter position : Int32 = 0

    # The input which is an array of characters because this way it's faster in
    # cases where the original code contains multi-byte characters.
    getter input : Array(Char)

    # The parsed file, we save it so we can show parse errors.
    getter data : Ast::Data

    # The AST.
    getter ast = Ast.new

    def initialize(input : String, @file : String)
      @data = Ast::Data.new(input, @file)
      @input = input.chars
    end

    # Parses a thing (an ast node). Yielding the start position so the thing
    # getting parsed can use it. If the block returns nil or if there is an
    # error we rollback to the start position since it means the parsing
    # has failed.
    def parse(*, track : Bool = true, &)
      rollback = begin
        operators_size = ast.operators.size
        keywords_size = ast.keywords.size
        nodes_size = ast.nodes.size
        start_position = position

        ->{
          ast.operators.delete_at(operators_size...)
          ast.keywords.delete_at(keywords_size...)
          ast.nodes.delete_at(nodes_size...)
          @position = start_position
        }
      end

      begin
        (yield position, nodes_size).tap do |node|
          case node
          when Ast::Node
            ast.nodes << node if track
          when Nil
            rollback.call
          end
        end
      rescue error : Error
        rollback.call
        raise error
      end
    end

    # Moves the cursor forward by one character.
    def step
      @position += 1
    end

    # Returns whether or not the cursor is at the end of the file.
    def eof? : Bool
      @position == input.size
    end

    # Checks if we reached the end of the file raises an error otherwise.
    def eof! : Bool
      whitespace
      error :expected_eof { expected "the end of the file", word } unless eof?
      true
    end

    # Returns the current character.
    def char : Char
      input[position]? || '\0'
    end

    # If the character is parsed with the given block, moves the cursor forward.
    def char(& : Char -> Bool)
      step if yield char
    end

    # If the character is the current character, moves the cursor forward.
    def char!(expected : Char)
      char { |current| current == expected }
    end

    # Returns the next character.
    def next_char : Char
      input[position + 1]? || '\0'
    end

    # Returns the previous character.
    def previous_char : Char
      input[position - 1]? || '\0'
    end

    # Parses any number of ascii latters or numbers.
    def ascii_letters_or_numbers
      chars { |char| char.ascii_letter? || char.ascii_number? }
    end

    # Parses any number of ascii latters, numbers or dashs.
    def ascii_letters_numbers_or_dash
      chars { |char| char.ascii_letter? || char.ascii_number? || char == '-' }
    end

    # Parses any number of ascii latters, numbers or underscores.
    def ascii_letters_numbers_or_underscore
      chars { |char| char.ascii_letter? || char.ascii_number? || char == '_' }
    end

    # Parses any number of ascii latters, numbers or dot.
    def ascii_letters_numbers_or_dot
      chars { |char| char.ascii_letter? || char.ascii_number? || char == '.' }
    end

    # Parses any number of ascii uppercase latters, numbers or underscore and
    # must start with an uppercase letter.
    def ascii_uppercase_and_underscore
      gather do
        next unless char.ascii_uppercase?
        chars { |char| char.ascii_uppercase? || char.ascii_number? || char == '_' }
      end
    end

    # Consumes characters while the yielded value is true or we reach the end
    # of the file.
    def chars(& : Char -> Bool)
      while char != '\0' && (yield char)
        step
      end
    end

    # Consumes characters while the yielded value is in one of the given
    # characters.
    def chars(*next_chars : Char)
      chars &.in?(next_chars)
    end

    # Starts to parse something, if the cursor moved during, return the parsed
    # string.
    def gather(&) : String?
      start_position = position

      yield

      if position > start_position
        result = substring(start_position, position - start_position)
        result unless result.empty?
      end
    end

    # Consumes characters until the yielded value is true.
    def consume(& : -> Bool) : Nil
      while yield
        step
      end
    end

    # Returns the word a the cursor.
    def word : String?
      start_position = position
      word = ""

      while !(eof? || whitespace?)
        word += char
        step
      end

      @position = start_position
      word
    end

    # Returns whether or not the word is at the current position.
    def word?(word) : Bool
      word.chars.each_with_index.all? do |char, i|
        input[position + i]? == char
      end
    end

    # Consumes a word and steps the cursor forward if successful.
    def word!(expected : String) : Bool
      if word?(expected)
        if word.chars.all?(&.ascii_lowercase?) && !word.blank? && word != "or"
          @ast.keywords << {position, position + word.size}
        end

        @position += expected.size
        true
      else
        false
      end
    end

    # Returns whether the current character is a whitespace.
    def whitespace?
      char.ascii_whitespace?
    end

    # Consumes all available whitespace.
    def whitespace : Nil
      chars &.ascii_whitespace?
    end

    # Consumes all available whitespace and returns true / false whether
    # there were any.
    def whitespace!
      parse do |start_position|
        whitespace
        next false if position == start_position
        true
      end
    end

    # Consuming variables
    # ----------------------------------------------------------------------------

    def type_or_type_variable
      type || type_variable
    end

    # Parse many things separated by whitespace.
    def many(parse_whitespace : Bool = true, & : -> T?) : Array(T) forall T
      result = [] of T

      loop do
        # Using parse here will not consume the whitespace if
        # the parsing is not successfull.
        # Consume whitespace
        item = parse(track: false) do
          whitespace if parse_whitespace
          yield
        end

        # Break if the block didn't yield anything
        break unless item

        # Add item to results
        result << item
      end

      result
    end

    def list(terminator : Char?, separator : Char, & : -> T?) : Array(T) forall T
      result = [] of T

      loop do
        # Break if we reached the end
        break if char == terminator

        # Break if the block didn't yield anything
        break unless item = yield

        # Add item to results
        result << item

        # Consume whitespace before the separator
        whitespace

        # Break if there is no separator, consume it otherwise
        break unless char! separator

        # Consume whitespace
        whitespace
      end

      result
    end

    # Gets substring out of the original string
    def substring(from, to)
      @data.input[from, to]
    end

    # Returns the word a the cursor
    def word : String?
      start_position = position
      word = ""

      while !(eof? || whitespace?)
        word += char
        step
      end

      @position = start_position
      word
    end

    # Parses a raw part of the input until we reach the terminator or an
    # interpolation (if it's needed).
    def raw(terminator : Char, stop_on_interpolation : Bool = true) : String?
      gather do
        while char != '\0'
          break if previous_char != '\\' &&
                   char == terminator

          break if stop_on_interpolation &&
                   previous_char != '\\' &&
                   next_char == '{' &&
                   char == '#'

          step
        end
      end
    end

    # Parses a raw part of the input until we reach the terminator or an
    # interpolation.
    def raw(token : String) : String?
      raw { !word?(token) }
    end

    # Parses a raw part of the input until we reach the terminator or an
    # interpolation.
    def raw(& : -> Bool) : String?
      gather do
        while char != '\0' && yield
          break if previous_char != '\\' &&
                   next_char == '{' &&
                   char == '#'

          step
        end
      end
    end
  end
end
