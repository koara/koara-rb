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
    @jjrounds = Array.new(8)
    @jjstateSet = Array.new(16)
    @jjnextStates = [ 2, 3, 5 ]
    @cs = stream
  end

  def get_next_token()
    begin
      cur_pos = 0
      while (true)
        begin
          @cur_char = cs.begin_token()
        rescue => err
          @matched_kind = 0
          @matched_pos = -1
          return fill_token()
        end

        @matched_kind = 2147483647
        @matched_pos = 0
        @cur_pos = move_string_literal_dfa0()
        if (matchedKind != 2147483647)
          if (matchedPos + 1 < curPos)
            @cs.backup(curPos - matchedPos - 1)
          end
          return fill_token()
        end
      end
    rescue => err
      return nil
    end
  end

  def fillToken()
    return Token.new(@matched_kind, @cs.get_begin_line(), @cs.get_begin_column(), @cs.get_end_line(), @cs.get_end_column(), @cs.get_image())
  end

  def move_string_literal_dfa0()
    case curChar
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
      return stop_at_Pos(0, BACKTICK)
    when 105
      return move_string_literal_dfa1(0x2000)
    else return moveNfa(6, 0)
    end
  end

  def startNfaWithStates(pos, kind, state)
    @matched_kind = kind
    @matched_pos = pos
    begin
      @cur_char = @cs.read_char()
    rescue  => err
      return pos + 1
    end
    return move_nfa(state, pos + 1)
  end

  def stop_at_pos(pos, kind)
    @matched_kind = kind
    @matched_pos = pos
    return pos + 1
  end

  def move_string_literal_dfa1(active)
    @cur_char = @cs.read_char()
    if (@cur_char.to_i == 77 || @cur_char.to_i == 109)
      return move_string_literal_dfa2(active, 0x2000)
    end
    return start_nfa(0, active)
  end

  def move_string_literal_dfa2(old, active)
    @cur_char = @cs.readChar()
    if (@cur_char.to_i == 65 || @cur_char.to_i == 97)
      return move_string_literal_dfa3(active, 0x2000)
    end
    return start_nfa(1, active)
  end

  def move_string_literal_dfa3(old, active)
    @cur_char = @cs.readChar()
    if (@cur_char.to_i == 71 || @cur_char.to_i == 103)
      return move_string_literal_dfa4(active, 0x2000)
    end
    return start_nfa(2, active)
  end

  def moveStringLiteralDfa4(old, active)
    @cur_char = @cs.readChar()
    if (@cur_char.to_i == 69 || @cur_char.to_i == 101)
      return move_string_literal_dfa5(active, 0x2000)
    end
    return start_nfa(3, active)
  end

  def move_string_literal_dfa5(old, active)
    @cur_char = @cs.read_char()
    if (@cur_char.to_i == 58 && ((active & 0x2000) != 0))
      return stop_at_pos(5, 13)
    end
    return start_nfa(4, active)
  end

  def start_nfa(pos, active)
    return move_nfa(stop_string_literal_dfa(pos, active), pos + 1)
  end

  def move_nfa(startState, curPos)
    starts_at = 0
    @jj_new_state_cnt = 8
    i = 1
    @jj_state_set[0] = start_state
    kind = 0x7fffffff

    while (true)
      if ((@round += 1) == 0x7fffffff)
        @round = 0x80000001
      end
      if (@cur_char.to_i < 64)
        l = 1 << @cur_char.to_i
        loop do
          case @jj_state_set[i-=1]
          when 6
            if ((0x880098feffffd9ff & l) != 0)
              if (kind > 4)
                kind = 4
              end
              checkNAdd(0)
            elsif ((0x3ff000000000000 & l) != 0)
              if (kind > 7)
                kind = 7
              end
              check_n_add(1)
            elsif ((0x2400 & l) != 0)
              if (@kind > 9)
                @kind = 9
              end
            elsif ((0x100000200 & l) != 0)
              checkNAddStates(0, 2)
            end
            if (@cur_char == 13)
              @jj_state_set[@jj_new_state_cnt+=1] = 4
            end
            break
          when 8
            if ((0x2400 & l) != 0)
              if (@kind > 9)
                @kind = 9
              end
            elsif ((0x100000200 & l) != 0)
              check_n_add_states(0, 2)
            end
            if (@cur_char.to_i == 13)
              @jj_state_set[@jj_new_state_cnt+=1] = 4
            end
            break
          when 0
            if ((0x880098feffffd9ff & l) != 0)
              @kind = 4
              check_n_add(0)
            end
            break
          when 1
            if ((0x3ff000000000000 & l) != 0)
              if (@kind > 7)
                @kind = 7
              end
              check_n_add(1)
            end
            break
          when 2
            if ((0x100000200 & l) != 0)
              check_n_add_states(0, 2)
            end
            break
          when 3
            if ((0x2400 & l) != 0 && @kind > 9)
              @kind = 9
            end
            break
          when 4
            if (@cur_char.to_i == 10 && @kind > 9)
              @kind = 9
            end
            break
          when 5
            if (@cur_char.to_i == 13)
              @jj_state_set[@jj_new_state_cnt+=1] = 4
            end
            break
          when 7
            if ((0x77ff670000000000 & l) != 0 && @kind > 11)
              kind = 11
            end
            break

          end
          break if(i == startsAt)
        end
      elsif (@cur_char.to_i < 128)
        l = 1 << (@cur_char.to_i & 077)
        loop do
          case jjstateSet[i-=1]
          when 6
            if (l != 0)
              if (@kind > 4)
                @kind = 4
              end
              check_n_add(0)
            elsif (curChar == 92)
              @jj_state_set[jjnewStateCnt+=1] = 7
            end
            break
          when 0
            if ((0xfffffffe47ffffff & l) != 0)
              @kind = 4
              check_n_add(0)
            end
            break
          when 7
            if ((0x1b8000000 & l) != 0 && @kind > 11)
              @kind = 11
            end
            break
          end
          break if (i == startsAt)
        end
      else
        loop do
          case @jj_state_set[i-=1]
          when 6
            if (@kind > 4)
              @kind = 4
            end
            check_n_add(0)
            break
          when 0
            if (@kind > 4)
              @kind = 4
            end
            check_n_add(0)
            break
          end
          break if (i == startsAt)
        end
      end
      if (@kind != 0x7fffffff)
        @matched_kind = kind
        @matched_pos = curPos
        @kind = 0x7fffffff
      end
      @cur_pos += 1

      if ((i = @jj_new_state_cnt) == (@starts_at = 8 - (@jj_new_state_cnt = @starts_at)))
        return @cur_pos
      end
      begin
        @cur_char = @cs.read_char()
      rescue => err
        return curPos
      end
    end
  end

  def check_n_add_states(start, ending)
    loop do
      check_n_add(@jj_next_states[start])
      break if(start +1 == ending)
    end
  end

  def checkNAdd(state)
    if (@jj_rounds[state] != @round)
      @jj_state_set[@jj_new_stateCnt+=1] = state
      @jj_rounds[state] = @round
    end
  end

  def stop_string_literal_dfa(pos, active)
    if (pos == 0)
      if ((active & 0x2000) != 0)
        @matched_kind = 4
        return 0
      elsif ((active & 0x180000) != 0)
        return 8
      elsif ((active & 0x4) != 0)
        return 7
      end
    elsif (pos == 1 && (active & 0x2000) != 0)
      @matched_kind = 4
      @matched_pos = 1
      return 0
    elsif (pos == 2 && (active & 0x2000) != 0)
      @matched_kind = 4
      @matched_pos = 2
      return 0
    elsif (pos == 3 && (active & 0x2000) != 0)
      @matched_kind = 4
      @matched_pos = 3
      return 0
    elsif (pos == 4 && (active & 0x2000) != 0)
      @matched_kind = 4
      @matched_pos = 4
      return 0
    end
    return -1
  end
end