//
//  Grid.swift
//  Sudoku
//
//  Created by Matthew Dillard on 5/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation


/// Holds a Sudoku grid and many useful operations for that grid
struct Sudoku {
	var grid = [[UInt8]](count: 9, repeatedValue:[UInt8](count: 9, repeatedValue:0))
	
	var emptySpaces: Int {
		var count = 0
		
		for row in grid {
			for value in row where value == 0 {
				count = count + 1
			}
		}
		
		return count
	}
	
	func getCluster(x: Int, _ y: Int) -> [UInt8] {
		var cluster = [UInt8]()
		
		cluster.append(grid[3*x+0][3*y+0])
		cluster.append(grid[3*x+1][3*y+0])
		cluster.append(grid[3*x+2][3*y+0])
		cluster.append(grid[3*x+0][3*y+1])
		cluster.append(grid[3*x+1][3*y+1])
		cluster.append(grid[3*x+2][3*y+1])
		cluster.append(grid[3*x+0][3*y+2])
		cluster.append(grid[3*x+1][3*y+2])
		cluster.append(grid[3*x+2][3*y+2])
		
		return cluster
	}
}


// For checking the unique solution of the puzzle
extension Sudoku {
	/// - returns: Number of unique solutions in the current puzzle configuration
	@warn_unused_result
	func solveDFS() -> Int {
		/// - returns: An array of all valid values for a given empty space in the grid
		/// - note: this func assumes there are no duplicates
		@warn_unused_result
		func getValidMovesFor(position: (row: Int, col: Int)) -> Set<UInt8> {
			func getValidMovesFor(group: [UInt8]) -> Set<UInt8> {
				var valid: Set<UInt8> = [1,2,3,4,5,6,7,8,9]
				
				for value in group where value > 0 {
					valid.remove(value)
				}
				
				return valid
			}
			
			let rowValid = getValidMovesFor(grid[position.row])
			let colValid = getValidMovesFor(grid.map({$0[position.col]}))
			let clusterValid = getValidMovesFor(getCluster(position.row / 3, position.col / 3))
			
			return rowValid.intersect(colValid.intersect(clusterValid))
		}
		
		var solutions = 0
		var moves = Set<UInt8>()
		var coords = (0, 0)
		var completed = true
		
		// Search for the first empty space
		for row in 0..<(9*9) where grid[row/9][row%9] == 0 {
			completed = false
			coords = (row/9, row%9)
			moves = getValidMovesFor(coords)
			break
		}
		
		// We have found a configuration that is a solution
		if completed {
			return 1
		}
		
		// We have found a configuration with no reachable solution
		if moves.isEmpty {
			return 0
		}
		
		// Copy the current grid to make an addition
		var newGrid = grid
		
		// Check each possible move in this empty position recursively
		for move in moves {
			newGrid[coords.0][coords.1] = move
			let guess = Sudoku(grid: newGrid)
			
			solutions += guess.solveDFS()
		}
		
		return solutions
	}
}

extension Sudoku {
	/// - returns: `True` if the puzzle configuration does not violate any Sudoku rules
	var checkValidity: Bool {
		/// Helper function to check groups for duplicate values
		func checkGroup(group: [UInt8]) -> Bool {
			var seen = [Bool](count: 9, repeatedValue: false)
			
			for value in group where value > 0 {
				let index = Int(value - 1)
				
				if seen[index] {
					return true
				}
				
				seen[index] = true
			}
			
			return false
		}
		
		// Check the rows
		for index in 0...8 {
			let row = grid[index]
			
			if checkGroup(row) {
				return false
			}
		}
		
		// Check the columns
		for index in 0...8 {
			let col = grid.map({$0[index]})
			
			if checkGroup(col) {
				return false
			}
		}
		
		// Check the clusters
		for y in 0...2 {
			for x in 0...2 {
				let cluster = getCluster(x, y)
				
				if checkGroup(cluster) {
					return false
				}
			}
		}
		
		return true
	}
}


/// For printing out the puzzle
extension Sudoku : CustomStringConvertible {
	var description : String {
		var descriptor = ""
		
		for row in 0...8 {
			if row % 3 == 0 && row > 0 {
				descriptor += "\n"
			}
			
			for col in 0...8 {
				if col % 3 == 0 && col > 0 {
					descriptor += " "
				}
				
				let value = grid[row][col]
				
				descriptor += (value > 0) ? String(value) : "-"
				
				if col < 8 {
					descriptor += " "
				}
			}
			
			if row < 8 {
				descriptor += "\n"
			}
		}
		
		return descriptor
	}
}
