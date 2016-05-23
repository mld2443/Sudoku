//
//  main.swift
//  Sudoku
//
//  Created by Matthew Dillard on 5/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation

// initialize our generator
let gen = Generator()

// set the difficulty of our puzzle; needs to be in the range (0.0, 1.0) with lower being easier
let difficulty = 0.75

// generate a puzzle...
let puzzle = gen.generate(difficulty, verbose: true)

// ...or generate a puzzle from a specific seed
//let puzzle = gen.generate(difficulty, seed: 0)
//print(puzzle)

// begin timer
let start = NSDate()

// check for uniqueness of solution
let solutions = puzzle.solveDFS()

// print our findings
print("found \(solutions) solution(s) in \(String(format: "%.3f", NSDate().timeIntervalSinceDate(start))) second(s)\n")
