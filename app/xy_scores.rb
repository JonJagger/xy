
# -----------------------------------------------------------------------
# Algorithm for scoring decisions played in Jerry Weinberg's XY Business Game
# Partially described in Experiential Learning: Volume 4. Sample Exercises
# Available on LeanPub:
#   https://leanpub.com/experientiallearning4sampleexercises

# -----------------------------------------------------------------------
# HERE ARE LINES YOU EDIT
# They score one round of decisions for 3 squads in a company.
# o) last line to return the overall scores
# o) one line for each squad's 5 letter decisions
#    - letter is illegal/illegible? see EXAMPLE#2
#    - more than 3 squads? see EXAMPLE#2,3
#    - letters form a word? see EXAMPLE#2,3
#    - letters are lowercase? see EXAMPLE#3
#
# If you have docker installed, and this file is called XY.rb
# and lives in the current directory, then you can run:
# $ docker run --rm --volume ${PWD}/XY.rb:/tmp/XY.rb ruby:alpine ruby /tmp/XY.rb

def xy_scores(sentence, profound, a, b, c)
  s = company_score(sentence, profound, a, b, c)
  squad_names = "ABCDEFGHIJKLMN"[0...s.size].chars
  totals = s.map{ |n| thou(sum(n)) }
  {
    "Company-score" => thou(sum(s)),
    "Squads-totals" => squad_names.zip(totals),
    "Squads-scores" => squad_names.zip(s.map{|s| thou(s)})
  }
end

# -----------------------------------------------------------------------
# EXAMPLE#1:
# Suppose there are 3 squads and their decisions are:
#
#    X X X X X        Y Y Y Y Y        X Y X Y X
#
# Edit the specified lines to:
#
#   a = blah('XXXXX')
#   b = blah('YYYYY')
#   c = blah('XYXYX')
#   company_score(sentence=false,profound=false, a,b,c)
#
# Note: we use blah() for letters that do not form a word.
# Note: we use sentence=false
# Note: we use profound=false
# Note: we pass 3 variables (a,b,c) at the end of the last line
#
# Run the program:
#
#    $ ruby XY_Scoring.rb
#
# This prints:
#
#    Company score: 61
#    Squads totals: [["A", "28"], ["B", "15"], ["C", "18"]]
#    Squads scores:
#    ["A", "[4, 8, 4, 8, 4]"]
#    ["B", "[3, 3, 3, 3, 3]"]
#    ["C", "[4, 3, 4, 3, 4]"]
#
# -----------------------------------------------------------------------
# EXAMPLE#2:
# ==========
# Suppose there are 4 squads and their decisions are:
#
#    X X X X X     Y Y Y Y Y     T H I N K     ? R R R R
#
# where ? means squad D's first letter was illegible/illegal.
# Edit the specified lines to:
#
#   a = blah('XXXXX')
#   b = blah('YYYYY')
#   c = word('THINK')
#   d = blah('?RRRR')
#   company_score(sentence=false,profound=false, a,b,c,d)
#
# Note: we use word() for C's letters as they _do_ form a word.
# Note: we use sentence=false
# Note: we use profound=false
# Note: we pass 4 variables (a,b,c,d) at the end of the last line
#
# Run the program:
#
#    $ ruby XY_Scoring.rb
#
# This prints:
#
#    Company score: 17,777
#    Squads totals: [["A", "40"], ["B", "15"], ["C", "16,700"], ["D", "1,022"]]
#    Squads scores:
#    ["A", "[8, 8, 8, 8, 8]"]
#    ["B", "[3, 3, 3, 3, 3]"]
#    ["C", "[3,200, 800, -100, 12,800, 0]"]
#    ["D", "[-2, 0, 1,024, 0, 0]"]
#
# -----------------------------------------------------------------------
# EXAMPLE#3:
# Suppose there are 4 squads and their decisions are:
#
#    w a i t s     w h i l e    w o r l d     w a r m s
#
# Edit the specified lines to:
#
#   a = word('waits')
#   b = word('while')
#   c = word('world')
#   d = word('warms')
#   company_score(sentence=true,profound=true, a,b,c,d)
#
# Note: we use word() for each squad's letters.
# Note: we use sentence=true
# Note: we use profound=true
# Note: we pass 4 variables (a,b,c,d) at the end of the last line
#
# Run the program:
#
#    $ ruby XY_Scoring.rb
#
# This prints:
#
#    Company score: 207,000,000
#    Squads totals: [["A", "51,000,000"], ["B", "2,200,000"], ["C", "153,500,000"], ["D", "300,000"]]
#    Squads scores:
#    ["A", "[51,200,000, -100,000, -100,000, 0, 0]"]
#    ["B", "[0, 800,000, -100,000, 1,600,000, -100,000]"]
#    ["C", "[51,200,000, -100,000, 102,400,000, 0, 0]"]
#    ["D", "[0, -100,000, 0, 0, 400,000]"]
#
# There are lots more examples in the tests below.
# -----------------------------------------------------------------------

def company_score(is_sentence, is_profound, *decisions)
  letters,are_words = decisions.transpose
  exit_unless_well_formed(letters)
  letters.map!{ |word| word.chars }
  multipliers = squad_multipliers(letters, are_words, is_sentence, is_profound)
  squad_scores(*letters).zip(multipliers).map do |scores,multiplier|
    scores.map{ |score| score * multiplier }
  end
end

def exit_unless_well_formed(letters)
  letters.each do |word|
    unless word.is_a?(String) && word.size === 5
      puts "word: #{word} is not a String with exactly 5 letters"
      exit(4)
    end
  end
end

def squad_scores(*company_decisions)
  scores,n = [],0
  company_decisions = marked(company_decisions)
  company_decisions.each do |squad_decisions|
    score,n = squad_score(n, squad_decisions, company_decisions)
    scores << score
  end
  scores
end

def squad_score(n, squad_decisions, company_decisions)
   scores = []
   (0..4).each do |i|
     score,n = letter_score(n, squad_decisions[i], ith(company_decisions,i))
     scores << score
   end
   [ scores, n ]
end

def ith(all, i)
  all.map{ |a| a[i] }
end

def letter_score(n, squad_decision, company_decisions)
  # Initial XY Scoring Table is as follows:
  #                       X Y
  # All squads play Y     0 5
  # One squad plays Y     8 3
  # Two+ squads play Y    4 3
  #
  # The important property of this table is that for
  # a company of 3 or more squads choosing all Y's gives
  # the biggest company score.
  #
  # 3 squads
  #    0X,3Y ==   0 + 3*5 == 0+15 == 15 <===
  #    1X,2Y == 1*8 + 2*3 == 8+6  == 14
  #    2X,1Y == 2*4 + 1*3 == 8+3  == 11
  #    3X,0Y == 3*4 +   0 == 12+0 == 12
  # 4 squads
  #    0X,4Y ==   0 + 4*5 == 0+20 == 20 <===
  #    1X,3Y == 1*8 + 3*3 == 8+9  == 17
  #    2X,2Y == 2*4 + 2*3 == 8+6  == 14
  #    3X,1Y == 1*4 + 3*3 == 4+9  == 13
  #    4X,0Y == 4*4 +   0 == 16+0 == 16
  # 5 squads
  #    0X,5Y ==   0 + 5*5 == 0+25 == 25 <===
  #    1X,4Y == 1*8 + 4*3 == 8+12 == 20
  #    2X,3Y == 2*4 + 3*3 == 8+9  == 17
  #    3X,2Y == 3*4 + 2*3 == 12+6 == 18
  #    4X,1Y == 4*4 + 1*3 == 16+3 == 19
  #    5X,0Y == 5*4 +   0 == 20+0 == 20
  # 6 squads
  #    0X,6Y ==   0 + 6*5 == 0+30 == 30 <===
  #    1X,5Y == 1*8 + 5*3 == 8+15 == 23
  #    2X,4Y == 2*4 + 4*3 == 8+12 == 20
  #    3X,3Y == 3*4 + 3*3 == 12+9 == 21
  #    4X,2Y == 4*4 + 2*3 == 16+6 == 22
  #    5X,1Y == 5*4 + 1*3 == 20+3 == 23
  #    6X,0Y == 6*4 +   0 == 24+0 == 24
  if invalid_or_illegal?(squad_decision)
    score,n = -2,0
  elsif vowel?(squad_decision)
    score = -1 # See vowel? notes [*]
  elsif unscoring_consonant?(squad_decision)
    score = 0
  elsif squad_decision === 'X'
    score = xy_score(0,8,4,company_decisions)
  elsif squad_decision === 'Y'
    score = xy_score(5,3,3,company_decisions)
  else
    score = BIG_FISH_TABLE[n][squad_decision]
    n = (n + 1) % 6
  end
  [ score, n ]
end

def xy_score(zero, one, two_or_more, decisions)
  case decisions.count('X')
  when 0 then zero
  when 1 then one
  else two_or_more
  end
end

def big_fish_values(b,g,f,s,h,l,t,p,n,d,w,r)
  { 'B' => b, 'G' => g, 'F' => f, 'S' => s, 'H' => h,
    'L' => l, 'T' => t, 'P' => p, 'N' => n, 'D' => d,
    'W' => w, 'R' => r
  }
end

BIG_FISH_TABLE = {
                     # B  G  F  S  H  L  T  P   N   D   W    R
  0 => big_fish_values(1, 1, 2, 4, 0, 0,32, 0,  0,  0,512,   0),
  1 => big_fish_values(1, 1, 2, 4, 8,16, 0,64,  0,  0,  0,1024),
  2 => big_fish_values(1, 1, 2, 0, 8, 0,32, 0,128,  0,  0,   0),
  3 => big_fish_values(1, 1, 2, 4, 0,16, 0, 0,  0,  0,  0,   0),
  4 => big_fish_values(1, 1, 2, 4, 8, 0,32,64,  0,  0,  0,   0),
  5 => big_fish_values(1, 1, 0, 0, 8,16, 0, 0,128,256,  0,   0),
}

def marked(company_decisions)
  company_decisions.map do |squad_decisions|
    squad_decisions.map do |decision|
      if invalid_or_illegal?(decision)
        marker_for(:invalid_or_illegal)
      elsif vowel?(decision) || scoring_consonant?(decision)
        decision.upcase
      else
        marker_for(:unscoring_consonant)
      end
    end
  end
end

MARKERS = {
  # Jerry's version uses X* for illegal or illegible decisions
  # and Y* for unscoring consonants. I have changed these to
  # '?' and '0' respectively as using single chars simplifies
  # the program, specifically the ability to write
  #    word.chars
  # to get the 5 decision-letters from a 5 character word.
  :invalid_or_illegal => '?',
  :unscoring_consonant => '0'
}

def marker_for(symbol)
  MARKERS[symbol]
end

def invalid_or_illegal?(decision)
  decision === marker_for(:invalid_or_illegal)
end

def unscoring_consonant?(decision)
  decision === marker_for(:unscoring_consonant)
end

def scoring_consonant?(decision)
  'XYBGFSHLTPNDWR'.include?(decision.upcase)
end

def vowel?(decision)
  # [*] Jerry's version scores a vowel as zero.
  # I decided to try a vowel scoring a small negative number.
  # This creates a nice tension since you need vowels to create
  # words. Viz, to get the best score for 5 decisions you need
  # to choose at least one decision that scores badly.
  # Do you want to optimize the parts or the whole?
  'AEIOU'.include?(decision.upcase)
end

def squad_multipliers(letters, are_words, is_sentence, is_profound)
  are_words.map do |is_word|
    squad_multiplier(all_lower?(letters), is_word, is_sentence, is_profound)
  end
end

def all_lower?(letters)
  letters.flatten.all?{ |letter| letter === letter.downcase }
end

def squad_multiplier(are_lower, is_word, is_sentence, is_profound)
  multiplier = 1
  if are_lower
    multiplier = 10
    if is_word
      multiplier = 100
      if is_sentence
        multiplier = 10000
        if is_profound
          multiplier = 100000
        end
      end
    end
  end
  multiplier
end

# - - - - - - - - - - - - - - - - - - - - - - - -
# Helper functions for scoring a round.

def sum(scores)
  scores.flatten.reduce(0,:+)
end

def word(s)
  [ s, true ]
end

def blah(s)
  [ s, false ]
end

def thou(n)
  # n as string with thousands separated by commas
  n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def print_scores
  s = scores
  squad_names = "ABCDEFGHIJKLMN"[0...s.size].chars
  totals = s.map{ |n| thou(sum(n)) }
  puts
  puts "Company score: #{thou(sum(s))}"
  puts "Squads totals: #{squad_names.zip(totals)}"
  puts "Squads scores:"
  squad_names.zip(s.map{|s| thou(s)}).each {|ss| p ss}
end

# - - - - - - - - - - - - - - - - - - - - - - - -
# tests

def assert_equal(expected, actual, msg = '')
  if !(expected === actual)
    puts "ERROR:#{msg}"
    puts "expected: #{expected.inspect}"
    puts "  actual: #{actual.inspect}"
    exit(42)
  end
end

def assert_sums(expected, scores)
  scores.size.times do |i|
    assert_equal(expected[i], sum(scores[i]))
  end
end

def test_invalid_entry
  a,b,c,d = blah('XXYYY'), blah('XYYXX'), blah('XYYXY'), blah('?YYXX')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[4,8,5,3,3],[4,3,5,4,4],[4,3,5,4,3],[-2,3,5,4,4]], scores)
  assert_sums([23, 20, 19, 14], scores)
  assert_equal(total=76, sum(scores))
  total
end

def test_all_Xs_and_Ys
  a,b,c,d = blah('XXYYY'), blah('XYYXX'), blah('XYYXY'), blah('XYYXX')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[4,8,5,3,3],[4,3,5,4,4],[4,3,5,4,3],[4,3,5,4,4]], scores)
  assert_sums([23, 20, 19, 20], scores)
  assert_equal(total=82, sum(scores))
  total
end

def test_letters_from_heading
  a,b,c,d = blah('BigFi'), blah('shLit'), blah('tlePo'), blah('ndWaR')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[1,-1,1,2,-1],[4,8,16,-1,32],[0,0,-1,0,-1],[0,256,512,-1,1024]], scores)
  assert_sums([2, 59, -2, 1791], scores)
  assert_equal(total=1850, sum(scores))
  total
end

def test_only_lowercase_letters_from_heading
  a,b,c,d = blah('bigfi'), blah('shlit'), blah('tlepo'), blah('ndwar')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[10,-10,10,20,-10],[40,80,160,-10,320],[0,0,-10,0,-10],[0,2560,5120,-10,10240]], scores)
  assert_sums([20, 590, -20, 17910], scores)
  assert_equal(total=18500, sum(scores))
  total
end

def test_only_lowercase_consonants_from_heading
  a,b,c,d = blah('bgfsh'), blah('lttlp'), blah('ndwrb'), blah('gfshl')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[10,10,20,40,80],[160,320,0,0,0],[0,2560,5120,10240,10],[10,20,0,0,160]], scores)
  assert_sums([160, 480, 17930, 190], scores)
  assert_equal(total=18760, sum(scores))
  total
end

def test_only_lowercase_consonants_near_end_of_heading
  a,b,c,d = blah('rrrrr'), blah('rrrrr'), blah('rrrrr'), blah('rrrrr')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[0,10240,0,0,0],[0,0,10240,0,0],[0,0,0,10240,0],[0,0,0,0,10240]], scores)
  assert_sums([10240, 10240, 10240, 10240], scores)
  assert_equal(total=40960, sum(scores))
  total
end

def test_unconnected_lowercase_5_letter_words
  a,b,c,d = word('dwarf'), word('rules'), word('knife'), blah('wwwww')
  scores = company_score(sentence=false, profound=false, a,b,c,d)
  assert_equal([[0,0,-100,0,200],[0,-100,1600,-100,400],[0,0,-100,200,-100],[0,0,0,5120,0]], scores)
  assert_sums([100, 1800, 0, 5120], scores)
  assert_equal(total=7020, sum(scores))
  total
end

def test_sentence_of_lowercase_5_letter_words
  a,b,c,d = word('wrong'), word('words'), word('score'), word('small')
  scores = company_score(sentence=true, profound=false, a,b,c,d)
  assert_equal([[5120000,10240000,-10000,1280000,10000],[0,-10000,0,0,40000],[0,0,-10000,0,-10000],[40000,0,-10000,160000,0]], scores)
  assert_sums([16640000, 30000, -20000, 190000], scores)
  assert_equal(total=16840000, sum(scores))
  total
end

def test_better_sentence_of_lowercase_5_letter_words
  a,b,c,d = word('wrote'), word('wrong'), word('wrote'), word('wrath')
  scores = company_score(sentence=true, profound=false, a,b,c,d)
  assert_equal([[5120000,10240000,-10000,320000,-10000],[0,0,-10000,1280000,10000],[0,0,-10000,0,-10000],[0,0,-10000,320000,80000]], scores)
  assert_sums([15660000, 1280000, -20000, 390000], scores)
  assert_equal(total=17310000, sum(scores))
  total
end

def test_profound_sentence_of_lowercase_5_letter_words
  a,b,c,d = word('waits'), word('while'), word('world'), word('warms')
  scores = company_score(sentence=true, profound=true, a,b,c,d)
  assert_equal([[51200000,-100000,-100000,0,0],[0,800000,-100000,1600000,-100000],[51200000,-100000,102400000,0,0],[0,-100000,0,0,400000]], scores)
  assert_sums([51000000, 2200000, 153500000, 300000], scores)
  assert_equal(total=207000000, sum(scores))
  total
end

def test_example_with_only_3_squads
  a,b,c = word('waits'), word('while'), word('world')
  scores = company_score(sentence=true, profound=true, a,b,c)
  assert_equal([[51200000,-100000,-100000,0,0],[0,800000,-100000,1600000,-100000],[51200000,-100000,102400000,0,0]], scores)
  assert_sums([51000000, 2200000, 153500000], scores)
  assert_equal(total=206700000, sum(scores))
  total
end

def sorted?(array)
  array.each_cons(2).all? { |a, b| (a <=> b) < 0 }
end

def test_scores_increase_as_cookies_are_unlocked
  s0 = test_invalid_entry
  s1 = test_all_Xs_and_Ys
  s2 = test_letters_from_heading
  s3 = test_only_lowercase_letters_from_heading
  s4 = test_only_lowercase_consonants_from_heading
  s5 = test_only_lowercase_consonants_near_end_of_heading
       test_unconnected_lowercase_5_letter_words # scores can get worse :-)
  s6 = test_sentence_of_lowercase_5_letter_words
  s7 = test_better_sentence_of_lowercase_5_letter_words
  s8 = test_profound_sentence_of_lowercase_5_letter_words
  assert_equal(true, sorted?([s0,s1,s2,s3,s4,s5,s6,s7,s8]), 'not sorted!')
end

#test_example_with_only_3_squads
#test_scores_increase_as_cookies_are_unlocked
#print_scores
