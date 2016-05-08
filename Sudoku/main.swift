//
//  main.swift
//  Sudoku
//
//  Created by Matthew Dillard on 5/7/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation

let easy: [[UInt8]] = [[0,2,0, 4,5,6, 7,8,9],
                       [4,5,7, 0,8,0, 2,3,6],
                       [6,8,9, 2,3,7, 0,4,0],
                       
                       [0,0,5, 3,6,2, 9,7,4],
                       [2,7,4, 0,9,0, 6,5,3],
                       [3,9,6, 5,7,4, 8,0,0],
                       
                       [0,4,0, 6,1,8, 3,9,7],
                       [7,6,1, 0,4,0, 5,2,8],
                       [9,3,8, 7,2,5, 0,6,0]]

let hard: [[UInt8]] = [[0,0,0, 6,0,0, 0,0,0],
                       [0,7,5, 0,4,0, 0,0,0],
                       [0,0,0, 0,0,8, 9,1,0],
                       
                       [0,0,2, 8,0,0, 0,0,5],
                       [6,0,3, 0,0,0, 1,0,2],
                       [4,0,0, 0,0,7, 6,0,0],
                       
                       [0,3,1, 4,0,0, 0,0,0],
                       [0,0,0, 0,7,0, 8,4,0],
                       [0,0,0, 0,0,1, 0,0,0]]

let mean: [[UInt8]] = [[0,0,0, 8,0,1, 0,0,0],
                       [0,0,0, 0,0,0, 0,4,3],
                       [5,0,0, 0,0,0, 0,0,0],
                       
                       [0,0,0, 0,7,0, 8,0,0],
                       [0,0,0, 0,0,0, 1,0,0],
                       [0,2,0, 0,3,0, 0,0,0],
                       
                       [6,0,0, 0,0,0, 0,7,5],
                       [0,0,3, 4,0,0, 0,0,0],
                       [0,0,0, 2,0,0, 6,0,0]]

var test = Sudoku(grid: hard)

print(test)

test.jumble()

print("\nAfter jumbling:")
print(test)

print()
print(test.checkValidity)

print()

let start = NSDate()

let solutions = test.solveDFS()

print("found \(solutions) solution(s) in \(NSDate().timeIntervalSinceDate(start)) second(s)")
print()