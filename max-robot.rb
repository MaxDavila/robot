require 'mechanize'
require 'open-uri'
require "pry"

class AI
  @@exit_words = ["exit", "quit", "q", "asdf"]
  @@robot_names = ["Lucile", "RTD2", "Rupert", "Bush", "Gwen", "Bruno", "C3PO"]
  @@question_words = ["why", "what", "?", "who", "how", "where"]
  @@help_words = ["help", "help!", "this sucks", "fuck you", "man", "you suck"]
  
  def initialize
    @name = @@robot_names[rand(4)]
    @human_input = nil
    @answer = nil
  end

  def greet
    puts "Hi my name is #{@name} ask me something interesting"
  end
  
  def converse
    
    begin
    @human_input = gets.chomp
    parse_input


    end while stop? != true
  end



  def stop?
    @@exit_words.each do |word|
      return true if @human_input == word
    end
  end
  

  def parse_input
    if input_include_question?
      puts 
      puts "Choose a topic by number"
      get_answer.each_with_index do |option, index|
        puts "#{index + 1}.- #{option}"
      end
      
    elsif input_include_help_word?
      display_help
    elsif include_option?
      navigate_to_option
    else
      try_again
    end
  end

  def include_option?
    @human_input.to_i > 0 && @human_input.to_i < 11
  end

  def navigate_to_option
    parser_result = @answer.links[@human_input.to_i - 1].click
    #binding.pry
    puts parser_result.parser.css('p').inner_text
  end
  def input_include_help_word?
    @@help_words.each do |word|
      return true if @human_input.include?(word) && @human_input.length < 10
    end
    false
  end

  def display_help
    puts "Press exit or quit anytime to exit"
  end

  def input_include_question?
    @@question_words.each do |word|
      return true if @human_input.include?(word) && @human_input.length > 8
    end
    false
  end

  def get_answer
    puts "you asked a question, good for you"
    puts 
    @answer = Knowledge.new(@human_input)
    @answer.show_results
  end


  def try_again
    puts "Please make sure to write full sentences so #{@name} can understand you"
  end
end




class Knowledge
  attr_reader :links
  def initialize(question)
    @question = question
    @agent = Mechanize.new
    @links = nil
  end

  def show_results
    @agent.get("http://www.google.com")
    @agent.page.form["q"] = @question
    @agent.page.form.submit
    @links = @agent.page.links.find_all { |l| l.attributes.parent.name == 'h3' }
    @agent.page.parser.css('.r > a').map { |link| link.inner_text }
  end
  
end

# know = Knowledge.new("what is the meaning of life?")

rtd2 = AI.new
rtd2.greet
rtd2.converse
#=> What do you want to talk about?
# => list a bunch of topics from Fark.com
# user selects topic 
# scrapes the selected website to gain knowledge 
# user asks questions about the topic
# AI responds with random paragraphs
