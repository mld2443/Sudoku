#SUDOKU GENERATION
![Swift 2.2.1](https://img.shields.io/badge/Swift-2.2.1-orange.svg?style=flat)

##Execution

Technically, the executable is runnable on any Mac running OS X 10.11 but if you wish to see the code compile and run, you will need to use XCode 7.3. The project is included, just open it and run.

##First Approach

I initially wanted to generate puzzles by a genetic algorithm, but when I saw the time it takes to calculate the uniqueness of a solution, I decided I didn't have enough time to test this given that such a calculation might need to go into a fitness function. I went with a jumbling approach. The idea is simple:

1. Create a bank of initial puzzles, and their solutions
  * The solutions are pretty much only for the hard puzzles since it's unreasonable to brute force the solution
2. The difficulty measure will be a combination of two metrics:
  1. The number of clues given to the player
  2. The time it takes to solve with my solver
3. The user inputs the desired dificulty on some scale
4. The generator will pick a puzzle at random, then try to adapt it to the desired difficulty setting:
  * It will add clues from the solution until the difficulty criteria are met.
5. Then it will jumble the puzzle and present it to the player.

###Methodolgy

* Puzzles that have a unique solution can be rearranged and permuted while keeping their unique solution using the following 8 operations:
  1. Jumbling the inner rows of each of the 3x3 clusters (`3 * 3!` number of configurations)
  2. Jumbling the outer rows, the rows of the 3x3 clusters themselvs (`3!` configurations)
  3. Jumbling the inner columns (`3 * 3!`)
  4. Jumbling the outer columns (`3!`)
  5. Jumbling the numbers (e.g. all 6s become 4s, all 3s become 8s, etc.) (`9!`)
  6. Arbitrarily rotating the grid (`4`)
  7. Mirroring accross the horizontal axis (`2`)
  8. Mirroring down the vertical axis (`2`)
* The generator never takes away from the original clues when making puzzles easier, so it always preserves the unique solution as well.

With the jumblers, I create what are essentially caesar ciphers, (I call them as much in code). The different total configurations begin to get much larger when you add in each of the 8 operations. The number of unique configurations is exactly 1,254,113,280 (this is computed by multiplying them all together, save one of the mirrorings, since altogether with the mirroring and rotations there's really only 8 unique permutationsinstead of 16).  
A number as large as that would see the end of your lifetime before you were likely to see the same configuration twice (assuming you were actually solving them), and that's only for one puzzle on one difficulty setting.  
Another interesting consequence of the uniqueness of puzzle solutions, is that if two puzzles are not in the same family of puzzles, (meaning there is no way to permute their final solutions such that they are identical), then there is also no way to permute their unsolved counterparts such that they become identical. If you could permute the unsolved clues of two different puzzles to be identical, that implies the solutions are permutations of each other too.  
This means that with each unique final solution put into the database, I get more than 1 billion possible puzzles, guaranteed, without even talking about changing up the difficulty.

#####On the Subject of difficulty

It isn't quite correct to say that a puzzle with `x` clues, and the same puzzle with an additional `x + 1` clue added are necessarily different puzzles. But there is something ot be said about the techniques used when mentally solving a puzzle and getting a clue handed to you that you would normally have to infer much later along the process of solving. Such a clue does change the way the puzzle appears to be solved. Still, I did not include that in the final tally, because It felt a little unnecessary, I had proven my point.

##References

1. [Gary McGuire, Bastian Tugemann, Gilles Civario. "There is no 16-Clue Sudoku: Solving the Sudoku Minimum Number of Clues Problem" Jan 1st, 2012](http://www.math.ie/McGuire_V1.pdf)
2. [Sudoku Puzzles Generating: from Easy to Evil](http://zhangroup.aporc.org/images/files/Paper_3485.pdf)<sup>*</sup>
3. [Bahare Fatemi, Seyed Mehran Kazemi, Nazanin Mehrasa. "Rating and Generating Sudoku Puzzles Based On Constraint Satisfaction Problems" In: *International Science Index, Computer and Information Engineering Vol:8, No:10*, 2014](http://waset.org/publications/9999524/rating-and-generating-sudoku-puzzles-based-on-constraint-satisfaction-problems)

\* I could not find a better copy of this. It has no authors listed, but I ultimately used their description of the sudoku solver, if only slightly improved.
