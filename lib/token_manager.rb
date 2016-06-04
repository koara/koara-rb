require_relative 'token'


class TokenManager

  EOF = 0
  ASTERISK = 1
  BACKSLASH = 2
  BACKTICK = 3
  CHAR_SEQUENCE = 4
  COLON = 5
  DASH = 6
  DIGITS = 7
  DOT = 8
  EOL = 9
  EQ = 10
  ESCAPED_CHAR = 11
  GT = 12
  IMAGE_LABEL = 13
  LBRACK = 14
  LPAREN = 15
  LT = 16
  RBRACK = 17
  RPAREN = 18
  SPACE = 19
  TAB = 20
  UNDERSCORE = 21

  def initialize(stream)
    @jj_rounds = Array.new(8,0)
    @jj_state_set = Array.new(16,0)
    @jj_next_states = [2, 3, 5]
    @cs = stream
    @round = 0
  end

  def get_next_token
    #   begin
    while true
      begin
        @cur_char = @cs.begin_token
      rescue
        @matched_kind = 0
        @matched_pos = -1
        return fill_token
      end

      @matched_kind = 2147483647
      @matched_pos = 0
      cur_pos = move_string_literal_dfa0

      if @matched_kind != 2147483647
        if (@matched_pos + 1) < cur_pos
          @cs.backup(cur_pos - @matched_pos - 1)
        end
        return fill_token
      end
    end
    #    rescue => err
    #      return nil
    #    end
  end

  def fill_token
    Token.new(@matched_kind, @cs.begin_line, @cs.begin_column, @cs.end_line, @cs.end_column, @cs.image)
  end

  def move_string_literal_dfa0
    case @cur_char.ord
      when 9
        return start_nfa_with_states(0, TAB, 8)
      when 32
        return start_nfa_with_states(0, SPACE, 8)
      when 40
        return stop_at_pos(0, LPAREN)
      when 41
        return stop_at_pos(0, RPAREN)
      when 42
        return stop_at_pos(0, ASTERISK)
      when 45
        return stop_at_pos(0, DASH)
      when 46
        return stop_at_pos(0, DOT)
      when 58
        return stop_at_pos(0, COLON)
      when 60
        return stop_at_pos(0, LT)
      when 61
        return stop_at_pos(0, EQ)
      when 62
        return stop_at_pos(0, GT)
      when 73
        return move_string_literal_dfa1(0x2000)
      when 91
        return stop_at_pos(0, LBRACK)
      when 92
        return start_nfa_with_states(0, BACKSLASH, 7)
      when 93
        return stop_at_pos(0, RBRACK)
      when 95
        return stop_at_pos(0, UNDERSCORE)
      when 96
        return stop_at_pos(0, BACKTICK)
      when 105
        return move_string_literal_dfa1(0x2000)
      else
        return move_nfa(6, 0)
    end
  end

  def start_nfa_with_states(pos, kind, state)
    @matched_kind = kind
    @matched_pos = pos
    begin
      @cur_char = @cs.read_char
    rescue
      return pos + 1
    end
    move_nfa(state, pos + 1)
  end

  def stop_at_pos(pos, kind)
    @matched_kind = kind
    @matched_pos = pos
    pos + 1
  end

  def move_string_literal_dfa1(active)
    @cur_char = @cs.read_char
    if @cur_char.ord == 77 || @cur_char.ord == 109
      return move_string_literal_dfa2(active, 0x2000)
    end
    start_nfa(0, active)
  end

  def move_string_literal_dfa2(old, active)
    @cur_char = @cs.read_char
    if @cur_char.ord == 65 || @cur_char.ord == 97
      return move_string_literal_dfa3(active, 0x2000)
    end
    start_nfa(1, active)
  end

  def move_string_literal_dfa3(old, active)
    @cur_char = @cs.read_char
    if @cur_char.ord == 71 || @cur_char.ord == 103
      return move_string_literal_dfa4(active, 0x2000)
    end
    start_nfa(2, active)
  end

  def move_string_literal_dfa4(old, active)
    @cur_char = @cs.read_char
    if @cur_char.ord == 69 || @cur_char.ord == 101
      return move_string_literal_dfa5(active, 0x2000)
    end
    start_nfa(3, active)
  end

  def move_string_literal_dfa5(old, active)
    @cur_char = @cs.read_char()
    if @cur_char.ord == 58 && ((active & 0x2000) != 0)
      return stop_at_pos(5, 13)
    end
    start_nfa(4, active)
  end

  def start_nfa(pos, active)
    move_nfa(stop_string_literal_dfa(pos, active), pos + 1)
  end

  def move_nfa(start_state, cur_pos)
    starts_at = 0
    @jj_new_state_cnt = 8
    i = 1
    @jj_state_set[0] = start_state
    kind = 0x7fffffff
    while true
      if (@round += 1) == 0x7fffffff
        @round = 0x80000001
      end
      if @cur_char.ord < 64
        l = 1 << @cur_char.ord
        loop do
          i-=1
          case @jj_state_set[i]
            when 6
              if (0x880098feffffd9ff & l) != 0
                kind = 4 if kind > 4
                check_n_add(0)
              elsif ((0x3ff000000000000 & l) != 0)
                kind = 7 if kind > 7
                check_n_add(1)
              elsif (0x2400 & l) != 0
                kind = 9 if kind > 9
              elsif (0x100000200 & l) != 0
                check_n_add_states(0, 2)
              end
              if @cur_char.ord == 13
                @jj_state_set[@jj_new_state_cnt+=1] = 4
              end
            when 8
              if ((0x2400 & l) != 0)
                kind = 9 if kind > 9
              elsif (0x100000200 & l) != 0
                check_n_add_states(0, 2)
              end
              if @cur_char.ord == 13
                @jj_state_set[@jj_new_state_cnt+=1] = 4
              end
            when 0
              if (0x880098feffffd9ff & l) != 0
                kind = 4
                check_n_add(0)
              end
            when 1
              if (0x3ff000000000000 & l) != 0
                kind = 7 if kind > 7
                check_n_add(1)
              end
            when 2
              if (0x100000200 & l) != 0
                check_n_add_states(0, 2)
              end
            when 3
              if (0x2400 & l) != 0 && kind > 9
                kind = 9
              end
            when 4
              if @cur_char.ord == 10 && kind > 9
                kind = 9
              end
            when 5
              if @cur_char.ord == 13
                @jj_state_set[@jj_new_state_cnt+=1] = 4
              end
            when 7
              if (0x77ff670000000000 & l) != 0 && kind > 11
                kind = 11
              end
          end
          break if (i == starts_at)
        end
      elsif @cur_char.ord < 128
        l = 1 << (@cur_char.ord & 077)
        loop do
          i -= 1
          case @jj_state_set[i]
            when 6
              if l != 0
                kind = 4 if kind > 4
                check_n_add(0)
              elsif @cur_char == 92
                @jj_state_set[@jj_new_state_cnt+=1] = 7
              end
            when 0
              if (0xfffffffe47ffffff & l) != 0
                kind = 4
                check_n_add(0)
              end
            when 7
              if (0x1b8000000 & l) != 0 && kind > 11
                kind = 11
              end
          end
          break if (i == starts_at)
        end
      else
        loop do
          i-=1
          case @jj_state_set[i]
            when 6
              kind = 4 if kind > 4
              check_n_add(0)
            when 0
              kind = 4 if kind > 4
              check_n_add(0)
          end
          break if (i == starts_at)
        end
      end
      if kind != 0x7fffffff
        @matched_kind = kind
        @matched_pos = cur_pos

        kind = 0x7fffffff
      end
      cur_pos += 1

      if (i = @jj_new_state_cnt) == (starts_at = 8 - (@jj_new_state_cnt = starts_at))
        return cur_pos
      end

      begin
        @cur_char = @cs.read_char
      rescue => error
        return cur_pos
      end
    end
  end

  def check_n_add_states(start, ending)
    loop do
      check_n_add(@jj_next_states[start])
      break if start == ending
      start += 1
    end
  end

  def check_n_add(state)
    if @jj_rounds[state] != @round
      @jj_state_set[@jj_new_state_cnt += 1] = state
      @jj_rounds[state] = @round
    end
  end

  def stop_string_literal_dfa(pos, active)
    if pos == 0
      if (active & 0x2000) != 0
        @matched_kind = 4
        return 0
      elsif (active & 0x180000) != 0
        return 8
      elsif (active & 0x4) != 0
        return 7
      end
    elsif pos == 1 && (active & 0x2000) != 0
      @matched_kind = 4
      @matched_pos = 1
      return 0
    elsif pos == 2 && (active & 0x2000) != 0
      @matched_kind = 4
      @matched_pos = 2
      return 0
    elsif pos == 3 && (active & 0x2000) != 0
      @matched_kind = 4
      @matched_pos = 3
      return 0
    elsif pos == 4 && (active & 0x2000) != 0
      @matched_kind = 4
      @matched_pos = 4
      return 0
    end
    -1
  end
end
