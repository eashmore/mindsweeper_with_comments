require 'yaml'

class Tile
  attr_reader :neighbors, :location, :view, :is_bomb, :board

  def initialize(tile_options)
    @view = '*'
    @is_bomb = tile_options[:is_bomb]
    @board = tile_options[:board]
    @location = tile_options[:location]
    @magnitude = tile_options[:magnitude]
  end

  def is_bomb?
    @is_bomb
  end

  def revealed?
    @revealed
  end

  def flagged?
    @flagged
  end

  def reveal
    @revealed = true
  end

  #
  # def reveal
  #   count = neighbor_bomb_count
  #   if is_bomb
  #     @view = "X"
  #     board.lose
  #   elsif @view != '*' && @view != 'F'
  #     return
  #   elsif count == 0
  #     @view = "_"
  #     board.increment_revealed_count
  #     neighbors_array = board.get_neighbors(@neighbors)
  #     neighbors_array.each do |neighbor|
  #       neighbor.reveal
  #     end
  #   else
  #     board.increment_revealed_count
  #     @view = "#{count}"
  #   end
  # end

  def generate_neighbors
    neighbor_array = []
    [1, 0, -1].each do |i|
      [1, 0,-1].each do |j|
        neighbor_array << dot_sum_array(@location, [i, j])
      end
    end

    neighbor_array = neighbor_array.select do |coordinate|
      coordinate.all? { |location| location.between?(0, @magnitude-1) }
    end

    neighbor_array.reject { |neighbor| neighbor == @location }
  end

  def dot_sum_array(arr1, arr2)
    result = []
    arr1.each_index do |i|
      result[i] = arr1[i] + arr2[i]
    end

    result
  end

  def neighbor_bomb_count
    immediate_neighbors = board.get_neighbors(generate_neighbors)
    number_of_neighbors = 0
    immediate_neighbors.each do |neighbor|
      number_of_neighbors += 1 if neighbor.is_bomb
    end
    number_of_neighbors
  end


  def flag
    if @view == "F"
      @view = "*"
    else
      @view = "F"
    end
  end


end

class Board
  attr_reader :tiles, :game, :count, :options

  def initialize(game, options)
    @game = game
    @tiles = Array.new(options[:magnitude]) { Array.new }
    @count = 0
    @options = options
    generate_tiles(options)
  end

  def generate_tiles(options)
    total = options[:magnitude] ** 2
    bombs = options[:bombs]
    bomb = (Array.new(total - bombs) { false } + Array.new(bombs) { true }).shuffle

    (0...options[:magnitude]).each do |i|
      (0...options[:magnitude]).each do |j|
        tile_options = {
          board: self,
          location: [i, j],
          is_bomb: bomb.shift,
          magnitude: options[:magnitude]
          }
        @tiles[i][j] = Tile.new(tile_options)
        # @tiles[i][j] = Tile.new(self, [i, j], bomb.shift, options[:magnitude])
      end
    end
  end

  def render
    print_column_numbers

    row_number = 0
    @tiles.each do |row|
      print row_number
      print row.map { |tile| tile.view }
      print row_number
      puts
      row_number += 1
    end

    print_column_numbers
  end


  def print_column_numbers
    print "   "
    (0...options[:magnitude]).each do |column_number|
      print column_number
      print "    "
    end
    puts
  end


  def reveal(pos)

    # reveal the tile at this position

    # if the tile's bomb_count == 0 add to queue

    # iterate through and reveal its neighbors

    # if its neighbors have bomb_count == 0 and !revealed? add to queue

    # no matter what, reveal each neighbor

    # continue until queue is empty
  end

  def get_neighbors(arr)
    result = []
    arr.each do |coordinates|
      i, j = coordinates[0], coordinates[1]
      result << @tiles[i][j]
    end

    result
  end

  def return_tile(i,j)
    return tiles[i][j]
  end

  def lose?

  end

  def win?

  end


  def lose
    game.losing
  end

  def increment_revealed_count
    @count += 1
  end

end

class Game
  attr_reader :win, :lose, :board
  attr_accessor :saved, :options

  def initialize(board = nil, options = {})
    defaults = {
      magnitude: 9,
      bombs: 9
    }
    @options = defaults.merge(options)
    @board = Board.new(self, @options) unless board
    @lose = false
    @saved = false
  end

  # def losing
  #   puts "You Lose!"
  #   @lose = true
  # end

  def over?
    board.lose? || board.win? || @saved
  end

  # def win?
  #   board.count == options[:magnitude] ** 2 - options[:bombs]
  # end

  def run
    until over?
      board.render
      take_turn
    end
    board.render
    if win?
      puts "You Win!"
    end
  end

  def take_turn
    print "What's your move? > "
    response = gets.chomp.split(" ")
    row = response[0].to_i
    column = response[1].to_i
    tile = board.return_tile(row, column)
    if response == ["save"]
      save_game
    elsif response.length > 2
        tile.flag
    else
      tile.reveal
    end
  end

  def save_game
    @saved = true
    File.open("saved_game.yml", "w") do |f|
      f.puts self.to_yaml
    end
    puts "Game saved."
  end

end


if __FILE__ == $PROGRAM_NAME
  if ARGV.include?("load")
    until ARGV.empty?
      ARGV.shift
    end
    saved_game = YAML::load(File.readlines("saved_game.yml").join(""))
    saved_game.saved = false
    saved_game.run
  else
    options = {
      magnitude: 14,
      bombs: 10
    }
    new_game = Game.new(nil, options)
    new_game.run
  end
end
