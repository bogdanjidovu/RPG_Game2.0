binpath = File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path(File.join(binpath, '..'))
require 'require_file'
require 'io_interface'
require 'hero'
require 'cursor'
require 'map'
require 'io_terminal'
require 'random_creator'
require 'random_map'
require 'custom_map'
require 'stats'

# class that manages a game
class Game
  def initialize(device)
    @device = device
    @hero_cursor = Cursor.new(Position.new(0, 0))
    @hero_position = Position.new(0, 0)
  end

  def start_game
    game_setup
    run_game
    stop_game
  end

  private
  def set_hero
    @device.clear
    @device.puts_string 'Input the hero name'
    stats = Stats.new(attack: 5, defence: 4, hp: 50, coins: 25)
    Hero.new(stats, nil, @device.input.chomp)
  end

  def set_difficulty
    @device.clear
    option = 0
    loop do
      @device.puts_string 'Input dificulty - between 0 to 10'
      option = @device.input.to_i
      break if (0..10).include? option
      @device.clear
    end
    option
  end

  def set_map(difficulty)
    map = RandomMap.new.create_map @hero, difficulty
    map.size.times do |i|
      map.size.times do |j|
        map.slots[i][j].set_device @device
      end
    end
    map
  end

  def game_setup
    @hero = set_hero
    difficulty = set_difficulty
    @map = set_map(difficulty)
  end

  def run_game
    game_over = false
    until game_over
      @device.clear
      @device.print_map(@map, @hero_cursor)
      @device.print_string(@hero.description)
      @device.next_line
      game_over = do_move
    end
  end

  def stop_game
    @device.clear
    @device.puts_string 'End of the game. Here are your stats'
    @device.print_hero @hero
  end

  def do_move
    option = parse
    return true if option == 'exit'
    direction = option
    next_position = @hero_cursor.next direction
    return false unless @map.valid_position? next_position
    @hero_cursor.position = @hero_cursor.move direction
    position = @hero_cursor.position
    room = @map.room position
    room.action @hero
  end

  def parse
    # TODO: replace with a menu
    loop do
      @device.print_string "Input 'left' to go left, 'right' to go right,"\
                         "'down' to go down, 'up' to go up or 'exit' to quit.\n"
      input = @device.input.chomp
      return 'up' if %w[up u].include? input
      return 'down' if %w[down d].include? input
      return 'left' if %w[left l].include? input
      return 'right' if %w[right r].include? input
      return 'exit' if %w[exit e].include? input
    end
  end
end
