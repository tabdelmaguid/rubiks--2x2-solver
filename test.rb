# description = up, forward, down, back, right, left
# rotations, counter clockwise, from the top = 0, 1, 2, 3
# all blocks start from up, 0 position.
# positions are (0, 0, 0) -> (1, 1, 1)

#movements: right side front
#           forward side right
#           bottom side counter clockwise

# for each movement
#   move
#   test end position
#   test repeated pattern

# right side front:
  # up -> f, f->d, d->b, b->u, right, and left the same
#
# use directions of up, and left

require 'Set'

class Dir
  U, F, D, B, R, L = 0, 1, 2, 3, 4, 5
end

class MoveType
  RSF, FSR, BSCC = 'RSF', 'FSR', 'BSCC'

  def self.all_moves
    [RSF, FSR, BSCC]
  end
end

MAX_DEPTH = 40

class Cube
  attr_reader :top, :left
  def initialize(top, left)
    @top, @left = top, left
  end

  # clockwise on x axis
  def forward
    top, left = move_forward(@top), move_forward(@left)
    Cube.new(top, left)
  end

  # counter clockwise on y axis
  def right
    top, left = to_right(@top), to_right(@left)
    Cube.new(top, left)
  end

  # clockwise on z axis
  def cc
    top, left = rotate_cc(@top), rotate_cc(@left)
    Cube.new(top, left)
  end

  def to_s
    "(#{@top}, #{@left})"
  end

  def id
    "#{@top}#{@left}"
  end

  private

  def move_forward(dir)
    (dir < 4) ? (dir + 1) % 4 : dir
  end

  def to_right dir
    right_map = { Dir::U => Dir::R,
                  Dir::D => Dir::L,
                  Dir::R => Dir::D,
                  Dir::L => Dir::U }
    right_map[dir] or dir
  end

  def rotate_cc(dir)
    cc_map = { Dir::F => Dir::L,
               Dir::B => Dir::R,
               Dir::R => Dir::F,
               Dir::L => Dir::B }
    cc_map[dir] or dir
  end

end

class Position
  def initialize(cubes = nil)
    if cubes
      @cubes = cubes
    else
      @cubes = Array.new
      (0..7).each do |index|
        @cubes[index] = Cube.new(0, 5)
      end
    end
  end

  def with_cube(cube, x, y, z)
    cubes = @cubes.clone
    cubes[index_of(x, y, z)] = cube
    cubes
  end

  def to_s
    "[#{@cubes.join(', ')}]"
  end

  def rsf
    cubes = @cubes.clone
    cubes[index_of(1, 1, 0)] = @cubes[index_of(1, 0, 0)].forward
    cubes[index_of(1, 1, 1)] = @cubes[index_of(1, 1, 0)].forward
    cubes[index_of(1, 0, 0)] = @cubes[index_of(1, 0, 1)].forward
    cubes[index_of(1, 0, 1)] = @cubes[index_of(1, 1, 1)].forward
    Position.new cubes
  end

  def fsr
    cubes = @cubes.clone
    cubes[index_of(1, 1, 0)] = @cubes[index_of(0, 1, 0)].right
    cubes[index_of(1, 1, 1)] = @cubes[index_of(1, 1, 0)].right
    cubes[index_of(0, 1, 0)] = @cubes[index_of(0, 1, 1)].right
    cubes[index_of(0, 1, 1)] = @cubes[index_of(1, 1, 1)].right
    Position.new cubes
  end

  def bscc
    cubes = @cubes.clone
    cubes[index_of(1, 0, 1)] = @cubes[index_of(0, 0, 1)].cc
    cubes[index_of(1, 1, 1)] = @cubes[index_of(1, 0, 1)].cc
    cubes[index_of(0, 0, 1)] = @cubes[index_of(0, 1, 1)].cc
    cubes[index_of(0, 1, 1)] = @cubes[index_of(1, 1, 1)].cc
    Position.new cubes
  end

  def make_move move
    case move
      when MoveType::RSF
        rsf
      when MoveType::FSR
        fsr
      else # BSCC
        bscc
    end
  end

  def id
    @cubes.map(&:id).join
  end

  def ==(other)
    id == other.id
  end

  def hash
    id.hash
  end

  private

  def index_of(x, y, z)
    x + 2 * y + 4 * z
  end

  def by_index(x, y, z)
    @cubes[index_of(x, y, z)]
  end

end

NULL_POSITION = Position.new

def is_solution?(position)
  position == NULL_POSITION
end

@positions_visited = Set.new

def visited?(position)
  @positions_visited.include? position.id
end

def find_solution_depth_first(position, depth = 0)
  if is_solution?(position)
    puts "Solution found!, depth = #{depth}"
    return true
  end
  return false if (depth > MAX_DEPTH) or visited?(position)
  @positions_visited << position.id

  moves = MoveType.all_moves
  moves.each do |move|
    new_position = position.make_move move
    if find_solution_depth_first(new_position, depth + 1)
      #print "#{move} <<"
      return false
    end
  end
  false
end

##################### breadth first

class Node
  @@count = 0

  attr_reader :position, :parent, :depth
  attr_accessor :next_node

  def initialize(position, move, parent, depth, positions_visited = Set.new)
    @position, @move, @parent, @depth = position, move, parent, depth
    @positions_visited = positions_visited
    visit position

    @@count += 1
    puts "count = #{@@count}, depth = #{@depth}, visited = #{@positions_visited.size}" if @@count % 5000 == 0
  end

  def visited?(position)
    @positions_visited.include? position.id
  end

  def visit(position)
    @positions_visited << position.id
  end

  def print_moves
    print " #{@move} "
    parent.print_moves if parent
  end

  def add_child(move, last_node)
    new_position = position.make_move move
    if is_solution?(new_position)
      print "Last move: #{move}"
      print_moves
      return nil
    elsif visited? new_position
      return last_node
    elsif depth == MAX_DEPTH
      visit position
      return last_node
    end

    child = Node.new(new_position, move, self, depth + 1, @positions_visited)
    last_node.next_node = child
    child
  end

  def make_moves(last_node_in)
    last_node = last_node_in
    MoveType.all_moves.each do |move|
      last_node = add_child(move, last_node)
      return nil unless last_node
    end
    last_node
  end

end

def find_solution(position)
  return true if is_solution?(position)
  node = last_node = Node.new(position, nil, nil, 0)

  while node
    last_node = node.make_moves last_node
    return true unless last_node
    node = node.next_node
  end

  puts 'No solutions found.'
end

#####################


p = Position.new
#find_solution_depth_first(p.rsf.rsf.fsr)
#puts p.rsf.rsf.fsr.fsr.fsr.fsr.rsf.rsf
# puts @positions_visited.size
p1 = p.fsr.fsr.fsr
#find_solution(p1)
#find_solution p.rsf.rsf.fsr
#state = [[Dir::U, Dir::L], [Dir::U, Dir::L], [Dir::U, Dir::L], [Dir::U, Dir::L],
#         [Dir::U, Dir::L], [Dir::U, Dir::L], [Dir::B, Dir::D], [Dir::B, Dir::U]]
state = [[Dir::U, Dir::L], [Dir::U, Dir::L], [Dir::U, Dir::L], [Dir::U, Dir::L],
         [Dir::R, Dir::U], [Dir::L, Dir::D], [Dir::U, Dir::L], [Dir::U, Dir::L]]

cubes = state.map { |pair| Cube.new pair[0], pair[1]}
find_solution Position.new cubes

