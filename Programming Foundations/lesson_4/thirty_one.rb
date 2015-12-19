SUITS = ['H', 'D', 'S', 'C']
VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

def prompt(msg)
  puts "=> #{msg}"
end

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def total(cards)
  # cards = [['H', '3'], ['S', 'Q'], ... ]
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    if value == "A"
      sum += 11
    elsif value.to_i == 0 # J, Q, K
      sum += 10
    else
      sum += value.to_i
    end
  end

  # correct for Aces
  values.count { |value| value == "A" }.times do
    sum -= 10 if sum > 21
  end

  sum
end

def busted?(total)
  total > 31
end

# :tie, :dealer, :player, :dealer_busted, :player_busted
def detect_result(dealer_total, player_total)
  if player_total > 31
    :player_busted
  elsif dealer_total > 31
    :dealer_busted
  elsif dealer_total < player_total
    :player
  elsif dealer_total > player_total
    :dealer
  else
    :tie
  end
end

def display_cards(dealer_total, player_total, dealer_cards, player_cards)
  puts "=============="
  prompt "Dealer has #{dealer_cards}, for a total of: #{dealer_total}"
  prompt "Player has #{player_cards}, for a total of: #{player_total}"
  puts "=============="
end

def display_result(dealer_total, player_total)
  result = detect_result(dealer_total, player_total)

  case result
  when :player_busted
    prompt "You busted! Dealer wins!"
  when :dealer_busted
    prompt "Dealer busted! You win!"
  when :player
    prompt "You win!"
  when :dealer
    prompt "Dealer wins!"
  when :tie
    prompt "It's a tie!"
  end
end

def display_score(scores)
  prompt "Dealer score is #{scores[:dealer]}, player score is #{scores[:player]}"
end

def display_outcome(dealer_total, player_total, dealer_cards, player_cards, scores)
  display_cards(dealer_total, player_total, dealer_cards, player_cards)
  display_result(dealer_total, player_total)
  display_score(scores)
end

def champion?(scores)
  if scores[:dealer] == 5
    return 'Dealer'
  elsif scores[:player] == 5
    return 'Player'
  end
end

def play_again?
  puts "-------------"
  prompt "Do you want to play again? (y or n)"
  answer = gets.chomp
  answer.downcase.start_with?('y')
end

scores = { player: 0, dealer: 0 }

loop do
  prompt "Welcome to Thirty-One!"

  # initialize vars
  deck = initialize_deck
  player_cards = []
  dealer_cards = []

  # initial deal
  2.times do
    player_cards << deck.pop
    dealer_cards << deck.pop
  end

  dealer_total = total(dealer_cards)
  player_total = total(player_cards)

  prompt "Dealer has #{dealer_cards[0]} and ?"
  prompt "You have: #{player_cards[0]} and #{player_cards[1]}, for a total of #{total(player_cards)}."

  # player turn
  loop do
    player_turn = nil
    loop do
      prompt "Would you like to (h)it or (s)tay?"
      player_turn = gets.chomp.downcase
      break if ['h', 's'].include?(player_turn)
      prompt "Sorry, must enter 'h' or 's'."
    end

    if player_turn == 'h'
      player_cards << deck.pop
      prompt "You chose to hit!"
      prompt "Your cards are now: #{player_cards}"
      player_total = total(player_cards)
      prompt "Your total is now: #{player_total}"
    end

    break if player_turn == 's' || busted?(player_total)
  end

  if busted?(player_total)
    scores[:dealer] += 1
    display_outcome(dealer_total, player_total, dealer_cards, player_cards, scores)
    break if champion?(scores)
    play_again? ? next : break
  else
    prompt "You stayed at #{player_total}"
  end

  # dealer turn
  prompt "Dealer turn..."

  loop do
    break if busted?(dealer_total) || dealer_total >= 27

    prompt "Dealer hits!"
    dealer_cards << deck.pop
    dealer_total = total(dealer_cards)
    prompt "Dealer's cards are now: #{dealer_cards}"
  end

  if busted?(dealer_total)
    prompt "Dealer total is now: #{dealer_total}"
    scores[:player] += 1
    display_outcome(dealer_total, player_total, dealer_cards, player_cards, scores)
    break if champion?(scores)
    play_again? ? next : break
  else
    prompt "Dealer stays at #{dealer_total}"
  end

  # both player and dealer stays - compare cards and update score!
  if detect_result(dealer_total, player_total) == :dealer
    scores[:dealer] += 1
  elsif detect_result(dealer_total, player_total) == :player
    scores[:player] += 1
  end
  display_outcome(dealer_total, player_total, dealer_cards, player_cards, scores)
  break if champion?(scores)
  break unless play_again?
end

prompt "The champion is #{champion?(scores)}" if champion?(scores)
prompt "Thank you for playing Thirty-One! Good bye!"
