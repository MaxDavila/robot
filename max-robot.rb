require 'mechanize'
require 'open-uri'
require "pry"

EXIT_WORDS = ["exit", "quit", "q", "asdf"]
ROBOT_NAMES = ["Lucile", "RTD2", "Rupert", "Bush", "Gwen", "Bruno", "C3PO"]
QUESTION_WORDS = ["why", "what", "?", "who", "how", "where"]
HELP_WORDS = ["help", "help!", "this sucks", "fuck you", "man", "you suck"]

class AI
  def initialize
    @name = ROBOT_NAMES[rand(ROBOT_NAMES.length)]
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

  def show_train
    system('sl')
  end

  def stop?
    EXIT_WORDS.include?(@human_input)
  end

  def parse_input
    if input_include_question?
      puts
      puts "you asked a question, good for you"
      puts
      if get_fact_answer
        #show_train
        get_fact_answer.each_with_index do |item, index|
          puts "Searching for #{item}....." if index.zero?
          puts item
          puts
        end
      else
        #show_train
        puts "Choose a topic by number"
        get_answer.each_with_index do |option, index|
          puts "#{index + 1}.- #{option}"
        end
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
    HELP_WORDS.each do |word|
      return true if @human_input.include?(word) && @human_input.length < 10
    end
    false
  end

  def display_help
    puts "Press exit or quit anytime to exit"
  end

  def input_include_question?
    QUESTION_WORDS.each do |word|
      return true if @human_input.include?(word) && @human_input.length > 8
    end
    false
  end

  def get_answer

    @answer = GoogleKnowledge.new(@human_input)
    @answer.show_results
  end

  def get_fact_answer
    @answer = WolframKnowledge.new(@human_input)
    @answer.show_results

  end


  def try_again
    puts "Please make sure to write full sentences so #{@name} can understand you"
  end
end


class WolframKnowledge
  attr_reader :question, :xml_doc
  def initialize(question)
    @question = URI::encode(question)
    @xml_doc = Nokogiri::XML(open("http://api.wolframalpha.com/v2/query?input=#{@question}&appid=WWE2HH-VQ2K68XL88"))

  end

  def show_results
    @xml_doc.css("plaintext").map { |element| element.inner_text } if success?
  end

  def get_result_title
    @xml_doc.css("pod").map { |title| element.get_attribute("title") }
  end

  def success?
    @xml_doc.css("queryresult")[0].get_attribute("success") == "true" &&
    @xml_doc.css("queryresult")[0].get_attribute("error") == "false"
  end
end




class GoogleKnowledge
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
