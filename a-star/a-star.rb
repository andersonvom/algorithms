module Algorithms

  module AStar
    require 'set'
  
    # Finds a path in `area` between `start` and `goal` using the `heuristic` function
    # `area` is a 2-dimentional array containing:
    #     [.]     for available paths
    #     [_-|]   for blocked paths
    def solve(area, start, goal, heuristic)
      closed_set = Set.new        # visited nodes
      open_set = Set.new [start]  # possible nodes to visit
      came_from = {}              # used to reconstruct path from `goal` to `start`

      f_score = Hash.new {0}      # Cost from `start` to `goal` using `heuristic`
      g_score = Hash.new {0}      # Best cost coming from `start`
      g_score[start] = 0

      while !open_set.empty?
        current = open_set.min_by { |n| f_score[n] }
        return if current == goal

        open_set.delete current
        closed_set.add current
        neighbors(current).each do |neighbor|
          next if closed_set.include? neighbor
        end
      end
    end
    
    def neighbors(current, area)
      current_neighbors = []
      ((current.x-1)..(current.x+1)).each do |x|
        next if x < 0
        ((current.y-1)..(current.y+1)).each do |y|
          next if y < 0
          node = OpenStruct.new
          node.x = x
          node.y = y
          next unless area[node.x][node.y] # outside of area
          current_neighbors << node unless blocked?(node, area)
        end
      end
      current_neighbors
    end

    def blocked?(node, area)
      area[node.x][node.y] =~ /[-_|]/
    end
  end

end
