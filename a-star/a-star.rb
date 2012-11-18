module Algorithms

  module AStar
    require 'set'
    require 'curses'
    Tuple ||= Struct.new(:x, :y)
  
    # Finds a path in `area` between `start` and `goal` using the `heuristic` function
    # `area` is a 2-dimentional array containing:
    #     [.]     for available paths
    #     [_-|]   for blocked paths
    # `start` and `goal` are Tuple objects
    # `heuristic` is a Proc object with a call to the heuristic function
    def self.solve(area, start, goal, heuristic)
      i = 0
      Curses.init_screen
      self.draw(area)
      
      closed_set = Set.new        # visited nodes
      open_set = Set.new [start]  # possible nodes to visit
      came_from = {}              # used to reconstruct path from `goal` to `start`

      f_score = Hash.new {Float::INFINITY}  # Cost from `start` to `goal` using `heuristic`
      g_score = Hash.new {Float::INFINITY}  # Best cost coming from `start`
      g_score[start] = 0

      while !open_set.empty?
        current = open_set.min_by { |n| f_score[n] }
        if current == goal
          self.draw self.reconstruct_path(area.dup, came_from, current)
          Curses.getch
          Curses.close_screen
          return
        end

        open_set.delete current
        closed_set.add current
        self.neighbors(current, area).each do |neighbor|
          next if closed_set.include? neighbor

          possible_g_score = g_score[current] + 1 # this distance may be different and could be refactored to a method call
          if possible_g_score <= g_score[neighbor]
            came_from[neighbor] = current
            g_score[neighbor] = possible_g_score
            #f_score[neighbor] = g_score[neighbor] + heuristic.call(neighbor, goal)
            f_score[neighbor] = g_score[neighbor] + self.simple_heuristic(neighbor, goal)
            open_set.add neighbor
          end
          i += 1
          self.preview(area, open_set, closed_set)
        end
      end

      Curses.getch
      Curses.close_screen

      return false
    end
    
    # Straight line from `node` to `goal`
    def self.simple_heuristic(node, goal)
      x = node.x - goal.x
      y = node.y - goal.y
      Math.sqrt x**2 + y**2
    end

    # Reconstructs the path used to get to `node` using the information in `came_from`
    # Path will be displayed in `area`
    def self.reconstruct_path(area, came_from, node)
      area[node.x][node.y] = '#' unless area[node.x][node.y] =~ /[SG]/
      area = self.reconstruct_path(area, came_from, came_from[node]) if came_from[node]
      area
    end

    def self.draw(area)
      #system "clear"
      area.each_with_index do |row, x|
        row.each_with_index do |col, y|
          #print col
          Curses.setpos(x, y); Curses.addstr(col)
        end
        #puts
      end
    end
    
    def self.preview(area, open_set, closed_set)
      open_set.each { |e| Curses.setpos(e.x, e.y); Curses.addstr("o") unless area[e.x][e.y] =~ /[SG]/ }
      closed_set.each { |e| Curses.setpos(e.x, e.y); Curses.addstr("x") unless area[e.x][e.y] =~ /[SG]/ }
      Curses.refresh
      sleep 0.005
    end

    # Generates available neighbors in `area` for `current` node
    def self.neighbors(current, area)
      current_neighbors = []
      ((current.x-1)..(current.x+1)).each do |x|
        next if x < 0 or area[x].nil?
        ((current.y-1)..(current.y+1)).each do |y|
          next if y < 0 or area[x][y].nil?
          node = Tuple.new(x, y)
          current_neighbors << node unless self.blocked?(node, area)
        end
      end
      current_neighbors
    end

    # Determines whether `node` is blocked or available in `area`
    # A node is blocked when it's one of the following symbols: -, _, |
    # and free otherwise
    def self.blocked?(node, area)
      area[node.x][node.y] =~ /[-_|]/
    end
  end

end

if $0 == __FILE__
  start = Algorithms::AStar::Tuple.new(0, 0)
  goal = Algorithms::AStar::Tuple.new(5, 2)
  area = area = [[".", ".", "."],
                 [".", ".", "."],
                 [".", ".", "."],
                 [".", "-", "-"],
                 [".", ".", "."],
                 [".", ".", "."]]
  file = File.open "input.txt"
  lines = file.lines.to_a
  area = lines.map { |line| line.chomp.split('') }
  area.each_with_index { |x, i| x.each_with_index { |y, j| start = Algorithms::AStar::Tuple.new(i, j) if y == "S" } }
  area.each_with_index { |x, i| x.each_with_index { |y, j| goal  = Algorithms::AStar::Tuple.new(i, j) if y == "G" } }

  Algorithms::AStar.solve area, start, goal, 0
end

