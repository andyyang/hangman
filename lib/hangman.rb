require 'net/http'
require 'json'
require File.expand_path("../words", __FILE__)

class Game
  include Words

  @@game_host = 'strikingly-interview-test.herokuapp.com'
  @@game_url = '/guess/process'
  @@user_id = 'mingwei.y@gmail.com'
  @@http_header = {'Content-Type' => 'application/json'}
  @@words_file = File.expand_path("../../data/words.txt", __FILE__)

  def initialize
    puts "Loading words file"
    @words_group_by_len = load_words @@words_file

    puts "Initiate game"
    @player = Net::HTTP.new(@@game_host)
    request_data = { action: 'initiateGame', userId: @@user_id }
    response_data = action request_data
    if response_data
      @secret_key = response_data['secret']
      @status = response_data['status']
      @number_of_words = response_data['data']['numberOfWordsToGuess']
      @number_of_guess_allowed = response_data['data']['numberOfGuessAllowedForEachWord']
    end
  end

  def play
    if @status != 200
      puts "Please initiate game!"
      return
    end

    1.upto(@number_of_words) do |word_count|
      puts "##{word_count} word"
      word, number_of_guess_allowed  = give_me_a_word
      word_matched = false
      while !word_matched && word && number_of_guess_allowed > 0
        word_matched, number_of_guess_allowed, word  = make_a_guess word
      end
   end

    get_test_result
  end

  def submit_result
    if @status != 200
      puts "Please initiate game!"
      return
    end

    request_data = { userId: @@user_id, action: 'submitTestResults', secret: @secret_key }
    response_data = action(request_data)
    if response_data && response_data['status'] == 200
      puts "Submit test result successfully"
    end
  end

  private
  
  def give_me_a_word
      request_data = { userId: @@user_id, action: 'nextWord', secret: @secret_key }
      response_data = action(request_data)
      if response_data && response_data['data']
        puts "Get a word: #{response_data['word']}"
        @possible_words = @words_group_by_len[response_data['word'].length] if response_data['word']
        @correctly_guessed_letters = [] 
        return response_data['word'], response_data['data']['numberOfGuessAllowedForThisWord'] 
      end
  end

  def make_a_guess(word)
      #guess = ('A'..'Z').to_a[Random.rand(1..26)-1]
      words_group_by_alp = get_words_group_by_alp(@possible_words)
      @possible_letters = get_letters_order_by_word_frequency(words_group_by_alp)
      #puts @possible_words.join(',')
      puts @possible_letters.join(',')
      puts '---------------------------------------'
      puts @correctly_guessed_letters.join(',') 
      guess = (@possible_letters - @correctly_guessed_letters)[0]
      puts "Make a guess: #{guess}"
      request_data = { userId: @@user_id, action: 'guessWord', secret: @secret_key, guess: guess }
      response_data = action(request_data)
      if response_data && response_data['data']
        puts "Return word: #{response_data['word']}"
        response_data['word'].upcase!
        if word == response_data['word']
          puts "Failed to guess! Letter: #{guess}"
          #puts @possible_words.join(',')
          @possible_words = @possible_words - words_group_by_alp[guess]
          #puts "--------------------------"
          #puts words_group_by_alp[guess].join(',')
        else
          puts "Successfully to guess! Letter: #{guess}"
          @correctly_guessed_letters << guess
          @possible_words = words_group_by_alp[guess].grep(Regexp.new(word.tr('*','.')))
        end
        word_matched = ! response_data['word'].include?('*')
        return word_matched, response_data['data']['numberOfGuessAllowedForThisWord'], response_data['word']
      end
  end

  def get_test_result
      request_data = { userId: @@user_id, action: 'getTestResults', secret: @secret_key }
      response_data = action(request_data)
      if response_data && response_data['data']
        puts "Get test score: #{response_data['data']['totalScore']}"
      end 
  end

  def action(request_data)
    response_data = nil
    puts "#{request_data[:action]} Request:#{request_data.to_json}"
    begin
      response = @player.post(@@game_url, request_data.to_json, @@http_header)
      response_data = JSON.parse(response.body) if response
    rescue StandardError => err
      puts err.message
    else
      puts "#{request_data[:action]} Response:#{response.message}, #{response_data}" 
    end
    response_data
  end
end



