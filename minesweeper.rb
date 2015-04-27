require 'yaml'

class Tile
  attr_reader :neighbors, :location, :view, :is_bomb, :board

  def initialize(board, location, is_bomb)
    @view = '*'
    @is_bomb = is_bomb
    @board = board
    @location = location
  end

  def is_bomb?
    @is_bomb
  end

  def reveal
    count = neighbor_bomb_count
    if is_bomb
      @view = "X"
      board.lose
    elsif @view != '*' && @view != 'F'
      return
    elsif count == 0
      @view = "_"
      board.increment_revealed_count
      neighbors_array = board.get_neighbors(@neighbors)
      neighbors_array.each do |neighbor|
        neighbor.reveal
      end
    else
      board.increment_revealed_count
      @view = "#{count}"
    end
  end

  def generate_neighbors
    neighbor_array = []
    [1, 0, -1].each do |i|
      [1, 0,-1].each do |j|
        neighbor_array << dot_sum_array(@location, [i, j])
      end
    end

    neighbor_array = neighbor_array.select do |coordinate|
      coordinate.all? { |x| x.between?(0, 8) }
    end

    @neighbors = neighbor_array.reject { |x| x == @location }
  end

  def dot_sum_array(arr1, arr2)
    result = []
    arr1.each_index do |i|
      result[i] = arr1[i] + arr2[i]
    end

    result
  end

  def neighbor_bomb_count
    generate_neighbors
    x = board.get_neighbors(@neighbors)
    count = 0
    x.each do |neighbor|
      count += 1 if neighbor.is_bomb
    end
    count
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
  attr_reader :tiles, :game, :count

  def initialize(game)
    @game = game
    @tiles = Array.new(9) { Array.new }
    @count = 0
    generate_tiles
  end


  def generate_tiles
    bomb = (Array.new(72) { false } + Array.new(9) { true }).shuffle

    (0..8).each do |i|
      (0..8).each do |j|
        @tiles[i][j] = Tile.new(self, [i, j], bomb.shift)
      end
    end
  end

  def render
    @tiles.each do |row|
      print row.map { |tile| tile.view }
      puts
    end
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

  def lose
    game.losing
  end

  def increment_revealed_count
    @count += 1
  end

end

class Game
  attr_reader :win, :lose, :board, :saved

  def initialize
    @board = Board.new(self)
    @lose = false
  end

  def losing
    puts "You Lose!"
    @lose = true
  end

  def over?
    lose || win? || saved
  end

  def win?
    board.count == 72
  end

  def run
    board.render
    until over?
      take_turn
      board.render
    end
    if win?
      puts "You Win!"
    end
  end

  def take_turn
    print "What's your move? > "
    response = gets.chomp.split(" ")
    i = response[0].to_i
    j = response[1].to_i
    tile = board.return_tile(i, j)
    if response == ["save"]
      @saved == true
      File.open("saved_game.yml", "w") do |f|
        f.puts self.to_yaml
      end
    elsif response.length > 2
        tile.flag
    else
      tile.reveal
    end
  end

end

new_game = Game.new
new_game.run
