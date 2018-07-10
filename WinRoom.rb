require_relative 'Room'

class WinRoom < Room
  attr_accessor :you_win

  def initialize(hidden = true, input = [])
    super(hidden, input)
    @description = 'Get here to win'
    @you_win = true
  end

  def action(hero)
    @you_win
  end
end
