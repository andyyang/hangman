
module Words

  def load_words(words_file)
    words_data = IO.readlines(words_file) 
    puts "The count of words: #{words_data.length}"
  
    words_group_by_len = words_data.inject({}) do |groups, word| 
      word.strip!
      if word.length > 0
        groups[word.length] ||= []
        groups[word.length] << word
      end
      groups
    end
    puts "The count of words lengths: #{words_group_by_len.keys.length}"
    words_group_by_len
  end

  def get_words_group_by_alp(words)
    groups = {}
    alp = 'A'..'Z'
    alp.each { |letter| groups[letter] = [] } 
    words.each do |word|
      word.upcase!
      alp.each { |letter| groups[letter] << word if word.include? letter }
    end
    groups
  end

  def get_letters_order_by_word_frequency(words_group_by_alp)
    words_group_by_alp.sort { |x, y| y[1].length <=> x[1].length }.collect {|x| x[0]}
  end
end
