//
//  Generator.swift
//  Sudoku
//
//  Created by Matthew Dillard on 5/8/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation

struct Puzzle {
	var unsolved: Sudoku
	let solution: Sudoku
	
	var difficulty: Double {
		return unsolved.difficulty
	}
	
	var liberties: Int {
		return unsolved.liberties
	}
	
	init(unsolved: Sudoku, solution: Sudoku) {
		self.unsolved = unsolved
		self.solution = solution
	}
	
	func libertyCoords(lookup: Int) -> (Int, Int) {
		return unsolved.libertyCoords(lookup)
	}
}


extension Puzzle : Comparable {}
func ==(lhs: Puzzle, rhs: Puzzle) -> Bool { return lhs.unsolved.givens == rhs.unsolved.givens }
func <(lhs: Puzzle, rhs: Puzzle) -> Bool { return lhs.unsolved.givens < rhs.unsolved.givens }

func ==(lhs: Puzzle, rhs: Int) -> Bool { return lhs.unsolved.givens == rhs }
func <(lhs: Puzzle, rhs: Int) -> Bool { return lhs.unsolved.givens < rhs }


class Generator {
	let puzzlebank: [Puzzle]
	
	init() {
		let easy1: [[UInt8]] = [[0,2,0, 4,5,6, 7,8,9],
		                        [4,5,7, 0,8,0, 2,3,6],
		                        [6,8,9, 2,3,7, 0,4,0],
		                        
		                        [0,0,5, 3,6,2, 9,7,4],
		                        [2,7,4, 0,9,0, 6,5,3],
								[3,9,6, 5,7,4, 8,0,0],
								
								[0,4,0, 6,1,8, 3,9,7],
								[7,6,1, 0,4,0, 5,2,8],
								[9,3,8, 7,2,5, 0,6,0]]
		let easy1solved: [[UInt8]] = [[1,2,3, 4,5,6, 7,8,9],
		                              [4,5,7, 1,8,9, 2,3,6],
		                              [6,8,9, 2,3,7, 1,4,5],
		                              
		                              [8,1,5, 3,6,2, 9,7,4],
		                              [2,7,4, 8,9,1, 6,5,3],
		                              [3,9,6, 5,7,4, 8,1,2],
		                              
		                              [5,4,2, 6,1,8, 3,9,7],
		                              [7,6,1, 9,4,3, 5,2,8],
		                              [9,3,8, 7,2,5, 4,6,1]]
		
		let medium1: [[UInt8]] = [[0,0,7, 8,0,3, 5,0,0],
		                          [0,3,0, 0,0,0, 0,2,0],
		                          [0,0,0, 6,0,9, 0,0,0],
		                          
		                          [0,6,9, 0,0,0, 1,4,0],
		                          [3,0,0, 0,4,0, 0,0,7],
		                          [0,4,2, 0,0,0, 3,8,0],
		                          
		                          [0,0,0, 9,0,7, 0,0,0],
		                          [0,7,0, 0,0,0, 0,6,0],
		                          [0,0,4, 5,0,1, 9,0,0]]
		
		let medium1solved: [[UInt8]] = [[4,9,7, 8,2,3, 5,1,6],
		                                [8,3,6, 4,1,5, 7,2,9],
		                                [5,2,1, 6,7,9, 4,3,8],
		                                
		                                [7,6,9, 3,5,8, 1,4,2],
		                                [3,5,8, 1,4,2, 6,9,7],
		                                [1,4,2, 7,9,6, 3,8,5],
		                                
		                                [6,1,3, 9,8,7, 2,5,4],
		                                [9,7,5, 2,3,4, 8,6,1],
		                                [2,8,4, 5,6,1, 9,7,3]]
		
		let hard1: [[UInt8]] = [[0,0,0, 6,0,0, 0,0,0],
		                        [0,7,5, 0,4,0, 0,0,0],
		                        [0,0,0, 0,0,8, 9,1,0],
		                        
		                        [0,0,2, 8,0,0, 0,0,5],
		                        [6,0,3, 0,0,0, 1,0,2],
		                        [4,0,0, 0,0,7, 6,0,0],
		                        
		                        [0,3,1, 4,0,0, 0,0,0],
		                        [0,0,0, 0,7,0, 8,4,0],
		                        [0,0,0, 0,0,1, 0,0,0]]
		let hard1solved: [[UInt8]] = [[3,9,8, 6,1,2, 7,5,4],
		                              [1,7,5, 9,4,3, 2,8,6],
		                              [2,6,4, 7,5,8, 9,1,3],
		                              
		                              [7,1,2, 8,3,6, 4,9,5],
		                              [6,8,3, 5,9,4, 1,7,2],
		                              [4,5,9, 1,2,7, 6,3,8],
		                              
		                              [8,3,1, 4,6,9, 5,2,7],
		                              [9,2,6, 3,7,5, 8,4,1],
		                              [5,4,7, 2,8,1, 3,6,9]]
		
		let mean1: [[UInt8]] = [[0,0,0, 8,0,1, 0,0,0],
		                        [0,0,0, 0,0,0, 0,4,3],
		                        [5,0,0, 0,0,0, 0,0,0],
		                        
		                        [0,0,0, 0,7,0, 8,0,0],
		                        [0,0,0, 0,0,0, 1,0,0],
		                        [0,2,0, 0,3,0, 0,0,0],
		                        
		                        [6,0,0, 0,0,0, 0,7,5],
		                        [0,0,3, 4,0,0, 0,0,0],
		                        [0,0,0, 2,0,0, 6,0,0]]
		let mean1solved: [[UInt8]] = [[2,3,7, 8,4,1, 5,6,9],
		                              [1,8,6, 7,9,5, 2,4,3],
		                              [5,9,4, 3,2,6, 7,1,8],
		                              
		                              [3,1,5, 6,7,4, 8,9,2],
		                              [4,6,9, 5,8,2, 1,3,7],
		                              [7,2,8, 1,3,9, 4,5,6],
		                              
		                              [6,4,2, 9,1,8, 3,7,5],
		                              [8,5,3, 4,6,7, 9,2,1],
		                              [9,7,1, 2,5,3, 6,8,4]]
		
		let mean2: [[UInt8]] = [[0,0,0, 7,0,0, 0,0,0],
		                        [1,0,0, 0,0,0, 0,0,0],
		                        [0,0,0, 4,3,0, 2,0,0],
		                        
		                        [0,0,0, 0,0,0, 0,0,6],
		                        [0,0,0, 5,0,9, 0,0,0],
		                        [0,0,0, 0,0,0, 4,1,8],
		                        
		                        [0,0,0, 0,8,1, 0,0,0],
		                        [0,0,2, 0,0,0, 0,5,0],
		                        [0,4,0, 0,0,0, 3,0,0]]
		let mean2solved: [[UInt8]] = [[2,6,4, 7,1,5, 8,3,9],
		                              [1,3,7, 8,9,2, 6,4,5],
		                              [5,9,8, 4,3,6, 2,7,1],
		                              
		                              [4,2,3, 1,7,8, 5,9,6],
		                              [8,1,6, 5,4,9, 7,2,3],
		                              [7,5,9, 6,2,3, 4,1,8],
		                              
		                              [3,7,5, 2,8,1, 9,6,4],
		                              [9,8,2, 3,6,4, 1,5,7],
		                              [6,4,1, 9,5,7, 3,8,2]]
		
		let mean3: [[UInt8]] = [[0,0,4, 0,8,3, 0,0,1],
		                        [0,0,0, 7,0,0, 0,0,4],
		                        [0,7,0, 0,0,0, 2,6,0],
		                        
		                        [0,0,0, 0,0,9, 0,0,0],
		                        [0,6,9, 0,0,0, 8,4,0],
		                        [0,0,0, 4,0,0, 0,0,8],
		                        
		                        [0,8,1, 0,9,0, 0,7,0],
		                        [6,3,0, 0,0,8, 0,0,0],
		                        [9,0,0, 5,2,0, 3,0,0]]
		let mean3solved: [[UInt8]] = [[2,5,4, 6,8,3, 7,9,1],
		                              [3,9,6, 7,1,2, 5,8,4],
		                              [1,7,8, 9,4,5, 2,6,3],
		                              
		                              [4,2,5, 8,6,9, 1,3,7],
		                              [7,6,9, 2,3,1, 8,4,5],
		                              [8,1,3, 4,5,7, 9,2,6],
		                              
		                              [5,8,1, 3,9,4, 6,7,2],
		                              [6,3,2, 1,7,8, 4,5,9],
		                              [9,4,7, 5,2,6, 3,1,8]]
		
		puzzlebank = [Puzzle(unsolved: Sudoku(grid: easy1), solution: Sudoku(grid: easy1solved)),
		              Puzzle(unsolved: Sudoku(grid: medium1), solution: Sudoku(grid: medium1solved)),
		              Puzzle(unsolved: Sudoku(grid: hard1), solution: Sudoku(grid: hard1solved)),
		              Puzzle(unsolved: Sudoku(grid: mean1), solution: Sudoku(grid: mean1solved)),
		              Puzzle(unsolved: Sudoku(grid: mean2), solution: Sudoku(grid: mean2solved)),
		              Puzzle(unsolved: Sudoku(grid: mean3), solution: Sudoku(grid: mean3solved))]
	}
	
	func generate(desiredDifficulty: Double, seed: UInt32 = UInt32(time(nil)), verbose: Bool = false) -> Sudoku {
		if desiredDifficulty >= 1.0 {
			print("No puzzles as hard as desired.")
			return Sudoku()
		}
		if desiredDifficulty <= 0.0 {
			print("No puzzles as easy as desired.")
			return Sudoku()
		}
		
		srandom(seed)
		
		let start = NSDate()
		
		// Create a list of all puzzles harder than desired difficulty
		var usablePuzzles = [Puzzle]()
		for puzzle in puzzlebank where puzzle.difficulty > desiredDifficulty {
			usablePuzzles.append(puzzle)
		}
		
		if usablePuzzles.isEmpty {
			print("No puzzles as hard as desired.")
			return Sudoku()
		}
		
		// Pick one at random
		var newPuzzle = usablePuzzles[random() % usablePuzzles.count]
		
		if verbose {
			print(String(newPuzzle.unsolved) + "\n\n")
		}
		
		// Make it easier until it just passes our desired difficulty
		while newPuzzle.difficulty > desiredDifficulty {
			// Check the number of liberties
			let liberties = newPuzzle.liberties
			
			// Pick a random number between 0 and that number
			let index = random() % liberties
			
			// Look up the index of that number for our grid
			let coords = newPuzzle.libertyCoords(index)
			
			// Add in the value from our solution board to the new board
			newPuzzle.unsolved.grid[coords.0][coords.1] = newPuzzle.solution.grid[coords.0][coords.1]
		}
		
		if verbose {
			print(String(newPuzzle.unsolved) + "\n\n")
		}

		// Jumble the puzzle
		newPuzzle.unsolved.jumble(false)
		
		if verbose {
			print(String(newPuzzle.unsolved) + "\n\n\(String(format: "%.3f", NSDate().timeIntervalSinceDate(start))) second(s) to generate new puzzle\n")
		}
		
		// Return puzzle
		return newPuzzle.unsolved
	}
}
