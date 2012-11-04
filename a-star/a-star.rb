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
      end
    end
    
  end

end
