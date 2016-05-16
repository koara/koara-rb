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
  #    private CharStream cs
  #    private char curChar
  #    private int jjnewStateCnt
  #    private int round
  #    private int matchedPos
  #    private int matchedKind
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
      return null
    end
  end

  def fillToken()
    return Token.new(@matched_kind, @cs.get_begin_line(), @cs.get_begin_column(), @cs.get_end_line(), @cs.get_end_column(), @cs.get_image())
  end

  def move_string_literal_dfa0()
    case curChar
    when 9: return start_nfa_with_states(0, TAB, 8)
    when 32: return start_nfa_with_states(0, SPACE, 8)
    when 40: return stop_at_pos(0, LPAREN)
    when 41: return stop_at_pos(0, RPAREN)
    when 42: return stop_at_pos(0, ASTERISK)
    when 45: return stop_at_pos(0, DASH)
    when 46: return stop_at_pos(0, DOT)
    when 58: return stop_at_pos(0, COLON)
    when 60: return stop_at_pos(0, LT)
    when 61: return stop_at_pos(0, EQ)
    when 62: return stop_at_pos(0, GT)
    when 73: return move_string_literal_dfa1(0x2000)
    when 91: return stop_at_pos(0, LBRACK)
    when 92: return start_nfa_with_states(0, BACKSLASH, 7)
    when 93: return stop_at_pos(0, RBRACK)
    when 95: return stop_at_pos(0, UNDERSCORE)
    when 96: return stop_at_Pos(0, BACKTICK)
    when 105: return move_string_literal_dfa1(0x2000)
    else return moveNfa(6, 0)
    end
  end
  #
  #    private int startNfaWithStates(int pos, int kind, int state) {
  #        matchedKind = kind
  #        matchedPos = pos
  #        try {
  #            curChar = cs.readChar()
  #        } catch (IOException e) {
  #            return pos + 1
  #        }
  #        return moveNfa(state, pos + 1)
  #    }
  #
  #    private int stopAtPos(int pos, int kind) {
  #        matchedKind = kind
  #        matchedPos = pos
  #        return pos + 1
  #    }
  #
  #    private int moveStringLiteralDfa1(long active) throws IOException {
  #        curChar = cs.readChar()
  #        if (curChar == 77 || curChar == 109) {
  #            return moveStringLiteralDfa2(active, 0x2000L)
  #        }
  #        return startNfa(0, active)
  #    }
  #
  #    private int moveStringLiteralDfa2(long old, long active) throws IOException {
  #        curChar = cs.readChar()
  #        if (curChar == 65 || curChar == 97) {
  #            return moveStringLiteralDfa3(active, 0x2000L)
  #        }
  #        return startNfa(1, active)
  #
  #    }
  #
  #    private int moveStringLiteralDfa3(long old, long active) throws IOException {
  #        curChar = cs.readChar()
  #        if (curChar == 71 || curChar == 103) {
  #            return moveStringLiteralDfa4(active, 0x2000L)
  #        }
  #        return startNfa(2, active)
  #    }
  #
  #    private int moveStringLiteralDfa4(long old, long active) throws IOException {
  #        curChar = cs.readChar()
  #        if (curChar == 69 || curChar == 101) {
  #            return moveStringLiteralDfa5(active, 0x2000L)
  #        }
  #        return startNfa(3, active)
  #    }
  #
  #    private int moveStringLiteralDfa5(long old, long active) throws IOException {
  #        curChar = cs.readChar()
  #        if (curChar == 58 && ((active & 0x2000L) != 0L)) {
  #            return stopAtPos(5, 13)
  #        }
  #        return startNfa(4, active)
  #    }
  #
  #    private int startNfa(int pos, long active) {
  #        return moveNfa(stopStringLiteralDfa(pos, active), pos + 1)
  #    }
  #
  #    private int moveNfa(int startState, int curPos) {
  #    	int startsAt = 0
  #        jjnewStateCnt = 8
  #        int i = 1
  #        jjstateSet[0] = startState
  #        int kind = 0x7fffffff
  #
  #        while (true) {
  #            if (++round == 0x7fffffff) {
  #                round = 0x80000001
  #            }
  #            if (curChar < 64) {
  #                long l = 1L << curChar
  #                do {
  #                    switch (jjstateSet[--i]) {
  #                    case 6:
  #                        if ((0x880098feffffd9ffL & l) != 0L) {
  #                            if (kind > 4) {
  #                                kind = 4
  #                            }
  #                            checkNAdd(0)
  #                        } else if ((0x3ff000000000000L & l) != 0L) {
  #                            if (kind > 7) {
  #                                kind = 7
  #                            }
  #                            checkNAdd(1)
  #                        } else if ((0x2400L & l) != 0L) {
  #                            if (kind > 9) {
  #                                kind = 9
  #                            }
  #                        } else if ((0x100000200L & l) != 0L) {
  #                            checkNAddStates(0, 2)
  #                        }
  #                        if (curChar == 13) {
  #                            jjstateSet[jjnewStateCnt++] = 4
  #                        }
  #                        break
  #                    case 8:
  #                        if ((0x2400L & l) != 0L) {
  #                            if (kind > 9) {
  #                                kind = 9
  #                            }
  #                        } else if ((0x100000200L & l) != 0L) {
  #                            checkNAddStates(0, 2)
  #                        }
  #                        if (curChar == 13) {
  #                            jjstateSet[jjnewStateCnt++] = 4
  #                        }
  #                        break
  #                    case 0:
  #                        if ((0x880098feffffd9ffL & l) != 0L) {
  #                            kind = 4
  #                            checkNAdd(0)
  #                        }
  #                        break
  #                    case 1:
  #                        if ((0x3ff000000000000L & l) != 0L) {
  #                            if (kind > 7) {
  #                                kind = 7
  #                            }
  #                            checkNAdd(1)
  #                        }
  #                        break
  #                    case 2:
  #                        if ((0x100000200L & l) != 0L) {
  #                            checkNAddStates(0, 2)
  #                        }
  #                        break
  #                    case 3:
  #                        if ((0x2400L & l) != 0L && kind > 9) {
  #                            kind = 9
  #                        }
  #                        break
  #                    case 4:
  #                        if (curChar == 10 && kind > 9) {
  #                            kind = 9
  #                        }
  #                        break
  #                    case 5:
  #                        if (curChar == 13) {
  #                            jjstateSet[jjnewStateCnt++] = 4
  #                        }
  #                        break
  #                    case 7:
  #                        if ((0x77ff670000000000L & l) != 0L && kind > 11) {
  #                            kind = 11
  #                        }
  #                        break
  #                    }
  #                } while (i != startsAt)
  #            } else if (curChar < 128) {
  #                long l = 1L << (curChar & 077)
  #                do {
  #                    switch (jjstateSet[--i]) {
  #                    case 6:
  #                        if (l != 0L) {
  #                            if (kind > 4) {
  #                                kind = 4
  #                            }
  #                            checkNAdd(0)
  #                        } else if (curChar == 92) {
  #                            jjstateSet[jjnewStateCnt++] = 7
  #                        }
  #                        break
  #                    case 0:
  #                        if ((0xfffffffe47ffffffL & l) != 0L) {
  #                            kind = 4
  #                            checkNAdd(0)
  #                        }
  #                        break
  #                    case 7:
  #                        if ((0x1b8000000L & l) != 0L && kind > 11) {
  #                            kind = 11
  #                        }
  #                        break
  #                    }
  #                } while (i != startsAt)
  #            } else {
  #                do {
  #                    switch (jjstateSet[--i]) {
  #                    case 6:
  #                    case 0:
  #                        if (kind > 4) {
  #                            kind = 4
  #                        }
  #                        checkNAdd(0)
  #                        break
  #                    }
  #                } while (i != startsAt)
  #            }
  #            if (kind != 0x7fffffff) {
  #                matchedKind = kind
  #                matchedPos = curPos
  #                kind = 0x7fffffff
  #            }
  #            ++curPos
  #
  #
  #            if ((i = jjnewStateCnt) == (startsAt = 8 - (jjnewStateCnt = startsAt))) {
  #                return curPos
  #            }
  #            try {
  #                curChar = cs.readChar()
  #            } catch (IOException e) {
  #                return curPos
  #            }
  #        }
  #    }
  #
  #    private void checkNAddStates(int start, int end) {
  #        do {
  #            checkNAdd(jjnextStates[start])
  #        } while (start++ != end)
  #    }
  #
  #    private void checkNAdd(int state) {
  #        if (jjrounds[state] != round) {
  #            jjstateSet[jjnewStateCnt++] = state
  #            jjrounds[state] = round
  #        }
  #    }
  #
  #    private int stopStringLiteralDfa(int pos, long active) {
  #        if (pos == 0) {
  #            if ((active & 0x2000L) != 0L) {
  #                matchedKind = 4
  #                return 0
  #            } else if ((active & 0x180000L) != 0L) {
  #                return 8
  #            } else if ((active & 0x4L) != 0L) {
  #                return 7
  #            }
  #        } else if (pos == 1 && (active & 0x2000L) != 0L) {
  #            matchedKind = 4
  #            matchedPos = 1
  #            return 0
  #        } else if (pos == 2 && (active & 0x2000L) != 0L) {
  #            matchedKind = 4
  #            matchedPos = 2
  #            return 0
  #        } else if (pos == 3 && (active & 0x2000L) != 0L) {
  #            matchedKind = 4
  #            matchedPos = 3
  #            return 0
  #        } else if (pos == 4 && (active & 0x2000L) != 0L) {
  #            matchedKind = 4
  #            matchedPos = 4
  #            return 0
  #        }
  #        return -1
  #    }
  #
  #}
end