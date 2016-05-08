//
//  Grid.swift
//  Sudoku
//
//  Created by Matthew Dillard on 5/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation


/// Holds a Sudoku grid and many useful operations for that grid
public struct Sudoku {
	var grid = [[UInt8]](count: 9, repeatedValue:[UInt8](count: 9, repeatedValue:0))
}


// Permutations to a board
extension Sudoku{
	public mutating func jumble(seed: UInt32 = UInt32(time(nil))) {
		srandom(seed)
		
		jumbleInnerRows()
		jumbleOuterRows()
		jumbleInnerColumns()
		jumbleOuterColumns()
		jumbleNumbers()
		
		rotateClockwise(random() % 4)
		
		if random() % 2 == 1 {
			mirrorHorizontal()
		}
		
		if random() % 2 == 1 {
			mirrorVertical()
		}
	}
	
	public mutating func jumbleNumbers() {
		var cipher = createCipher(9)
		cipher.insert(0, atIndex: 0)
		
		var newGrid = [[UInt8]]()
		
		for row in grid {
			var newRow = [UInt8]()
			for entry in row {
				newRow.append(UInt8((entry > 0) ? cipher[Int(entry)] + 1 : 0))
			}
			newGrid.append(newRow)
		}
		
		grid = newGrid
	}
	
	public mutating func jumbleInnerRows() {
		let cipher1 = createCipher(3)
		let cipher2 = createCipher(3)
		let cipher3 = createCipher(3)
		
		var newGrid = [[UInt8]](count: 9, repeatedValue: [UInt8]())
		
		for index in 0...2 {
			newGrid[index + 0] = grid[cipher1[index] + 0]
			newGrid[index + 3] = grid[cipher2[index] + 3]
			newGrid[index + 6] = grid[cipher3[index] + 6]
		}
		
		grid = newGrid
	}
	
	public mutating func jumbleInnerColumns() {
		let cipher1 = createCipher(3)
		let cipher2 = createCipher(3)
		let cipher3 = createCipher(3)
		
		var newGrid = [[UInt8]]()
		
		for row in grid {
			var newRow = [UInt8](count: 9, repeatedValue: 0)
			
			for index in 0...2 {
				newRow[index + 0] = row[cipher1[index] + 0]
				newRow[index + 3] = row[cipher2[index] + 3]
				newRow[index + 6] = row[cipher3[index] + 6]
			}
			
			newGrid.append(newRow)
		}
		
		grid = newGrid
	}
	
	public mutating func jumbleOuterRows() {
		let cipher = createCipher(3)
		
		var newGrid = [[UInt8]](count: 9, repeatedValue: [UInt8]())
		
		for index in 0...2 {
			newGrid[3 * index + 0] = grid[3 * cipher[index] + 0]
			newGrid[3 * index + 1] = grid[3 * cipher[index] + 1]
			newGrid[3 * index + 2] = grid[3 * cipher[index] + 2]
		}
		
		grid = newGrid
	}
	
	public mutating func jumbleOuterColumns() {
		let cipher = createCipher(3)
		
		var newGrid = [[UInt8]]()
		
		for row in grid {
			var newRow = [UInt8](count: 9, repeatedValue: 0)
			
			for index in 0...2 {
				newRow[3 * index + 0] = row[3 * cipher[index] + 0]
				newRow[3 * index + 1] = row[3 * cipher[index] + 1]
				newRow[3 * index + 2] = row[3 * cipher[index] + 2]
			}
			
			newGrid.append(newRow)
		}
		
		grid = newGrid
	}
	
	public mutating func rotateClockwise(rotations: Int = 1) {
		let xRotations = [{(y: Int, x: Int) in x}, {(y: Int, x: Int) in y}, {(y: Int, x: Int) in 8 - x}, {(y: Int, x: Int) in 8 - y}]
		let yRotations = [{(y: Int, x: Int) in y}, {(y: Int, x: Int) in 8 - x}, {(y: Int, x: Int) in 8 - y}, {(y: Int, x: Int) in x}]
		
		let mutX = xRotations[rotations % 4]
		let mutY = yRotations[rotations % 4]
		
		var newGrid = [[UInt8]](count: 9, repeatedValue:[UInt8](count: 9, repeatedValue:0))
		
		for y in 0...8 {
			for x in 0...8 {
				newGrid[y][x] = grid[mutY(y,x)][mutX(y,x)]
			}
		}
		
		grid = newGrid
	}
	
	public mutating func mirrorHorizontal() {
		var newGrid = [[UInt8]](count: 9, repeatedValue:[UInt8](count: 9, repeatedValue:0))
		
		for y in 0...8 {
			for x in 0...8 {
				newGrid[y][x] = grid[y][8 - x]
			}
		}
		
		grid = newGrid
	}
	
	public mutating func mirrorVertical() {
		var newGrid = [[UInt8]](count: 9, repeatedValue:[UInt8](count: 9, repeatedValue:0))
		
		for y in 0...8 {
			for x in 0...8 {
				newGrid[y][x] = grid[8 - y][x]
			}
		}
		
		grid = newGrid
	}
}


// For checking the unique solution of the puzzle
extension Sudoku {
	/// - returns: Number of unique solutions in the current puzzle configuration
	@warn_unused_result
	public func solveDFS() -> Int {
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


// For checking properties of a configuration
extension Sudoku {
	/// - returns: `True` if the puzzle configuration does not violate any Sudoku rules
	public var checkValidity: Bool {
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
	
	/// - returns: number of empty spaces remaining in the puzzle
	public var emptySpaces: Int {
		var count = 0
		
		for row in grid {
			for value in row where value == 0 {
				count = count + 1
			}
		}
		
		return count
	}
	
	/// - returns: number of taken spaces remaining in the puzzle
	public var takenSpaces: Int {
		var count = 0
		
		for row in grid {
			for value in row where value > 0 {
				count = count + 1
			}
		}
		
		return count
	}
}


// For printing the puzzle
extension Sudoku : CustomStringConvertible {
	public var description : String {
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


// Private functions
extension Sudoku {
	/// - returns: A ceaser cipher of requested size
	private func createCipher(size: Int) -> [Int] {
		var cipher = [Int](count: size, repeatedValue: 0)
		
		for range in (0..<size).reverse() {
			var index = 0, position = random() % (range + 1)
			
			while index <= position {
				if cipher[index] > 0 {
					position = position + 1
				}
				
				index = index + 1
			}
			
			cipher[position] = range
		}
		
		return cipher
	}
	
	/// - parameters:
	///   - Int: row of the 3x3 desired cluster
	///   - Int: column of the 3x3 desired cluster
	/// - returns: The group of values in the specified Cluster
	@warn_unused_result
	private func getCluster(x: Int, _ y: Int) -> [UInt8] {
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
	
	/// - returns: An array of all valid values for a given empty space in the grid
	/// - note: this func assumes there are no duplicates
	@warn_unused_result
	public func getValidMovesFor(position: (row: Int, col: Int)) -> Set<UInt8> {
		func getValidMovesForGroup(group: [UInt8]) -> Set<UInt8> {
			var valid: Set<UInt8> = [1,2,3,4,5,6,7,8,9]
			
			for value in group where value > 0 {
				valid.remove(value)
			}
			
			return valid
		}
		
		let rowValid = getValidMovesForGroup(grid[position.row])
		let colValid = getValidMovesForGroup(grid.map({$0[position.col]}))
		let clusterValid = getValidMovesForGroup(getCluster(position.row / 3, position.col / 3))
		
		return rowValid.intersect(colValid.intersect(clusterValid))
	}
	
	/// Helper function to check groups for duplicate values
	private func checkGroup(group: [UInt8]) -> Bool {
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
}
