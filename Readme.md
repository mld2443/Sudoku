# SUDOKU GENERATION
![Swift 2.2.1](https://img.shields.io/badge/Swift-2.2.1-orange.svg?style=flat)

## Execution

Technically, the executable is runnable on any Mac running OS X 10.11 but if you wish to see the code compile and run, you will need to use XCode 7.3. The project is included, just open it and run.

## First Approach

I initially wanted to generate puzzles by a genetic algorithm, but when I saw the time it takes to calculate the uniqueness of a solution, I decided I didn't have enough time to test this given that such a calculation might need to go into a fitness function. I went with a jumbling approach. The idea is simple:

1. Create a bank of initial puzzles, and their solutions
  * The solutions are pretty much only for the hard puzzles since it's unreasonable to brute force the solution
2. The difficulty measure will be a combination of two metrics:
  1. The number of clues given to the player
  2. The time it takes to solve with my solver
3. The user inputs the desired dificulty on some scale
4. The generator will pick a puzzle at random, then try to adapt it to the desired difficulty setting:
  * It will add clues from the solution until the difficulty criteria are met.
5. Jumble the puzzle and present it to the player.

### Methodolgy

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

With the jumblers, I create what are essentially caesar ciphers, (I call them as much in code). The different total configurations begin to get much larger when you add in each of the 8 operations. The number of unique configurations is exactly 1,254,113,280 (this is computed by multiplying them all together, save one of the mirrorings, since altogether with the mirroring and rotations there's really only 8 unique permutationsinstead of 16). A number as large as that would see the end of your lifetime before you were likely to see the same configuration twice (assuming you were actually solving them), and that's only for one puzzle on one difficulty setting.

Another interesting consequence of the uniqueness of puzzle solutions, is that if two puzzles are not in the same family of puzzles, (meaning there is no way to permute their final solutions such that they are identical), then there is also no way to permute their unsolved counterparts such that they become identical. If you could permute the unsolved clues of two different puzzles to be identical, that implies the solutions are permutations of each other too. This means that with each unique final solution put into the database, I get more than 1 billion possible puzzles, guaranteed, without even talking about changing up the difficulty.

#### Difficulty Metric

The difficulty metric I use is converted measured against two metrics of difficulty, a measure based on the number of liberties, (open cells), and measurement of time to search for solution.

To compute the metric for liberties, I first note the maximum number of liberties possible is 64, (81 total cells, minus 17 givens as the minimum number of clues for a unique puzzle, [1]). I then put the number of actual liberties (`L`) of a given puzzle through the following formula:

D<sub>L</sub> = (L / 64)<sup>2</sup>

I then perform the search, with a timeout of 4 seconds. Anything longer than 4 seconds is negligably harder. Here's the formula for the metric based on the time (`T`) to complete the search:

D<sub>T</sub> = (√T / 2)

The results would be multiplied together.

There are indeed more metrics that could be used to judge the difficulty of a Sudoku puzzle, which I explore below.

##### On the Subject of difficulty

It isn't quite correct to say that a puzzle with `x` clues, and the same puzzle with an additional `x + 1` clue added are necessarily different puzzles. But there is something ot be said about the techniques used when mentally solving a puzzle and getting a clue handed to you that you would normally have to infer much later along the process of solving. Such a clue does change the way the puzzle appears to be solved. Still, I did not include that in the final tally, because It felt a little unnecessary, I had proven my point.

## Analysis

My method is fairly similar to the one described in the prompt. I formalize the values, generate the random puzzle *p* of difficulty harder than ∂, then I lower the difficulty gradually until it meets the criteria. Never do I discard *p* and start over.

### Continuousness

Even though I did not get the difficulty implemented *exactly* how I wanted, theoretically it can support any arbitrary descrete or analog value, making it functionally continuous.

### Results

Using Swift has its downsides. I really enjoy programming in the language, but there's not as much documentation on it as I would like, and since the language is still new and evolving, some of what is there is outdated.

I struggled to find a way to implemt my measure of difficulty as I would have liked. It comes down to the fact that I wanted to run a search on the puzzle for the number of solutions, but have a timeout of a few seconds in case it took too long.  
This timeout proved much more difficult to implement as I would have hoped, thus I left the "Time to solve" metric out of my measure of difficulty.

The measure is still on an analog scale, however. If I could find a way around the timeout problem, (or write a better search, like the one I discuss below), or think of a new metric, I could very quickly incorporate it into the existing code.

Even as it is, a user would be hard hard pressed to know how the system works from just generating a bunch of puzzles.

### Conclusion

I'm fairly pleased with how it's turned out. With only one metric considered in the measure of difficulty, the actual difficulty of the puzzles might not scale as nicely; but short of running a user study, I have a hunch even just what's there is probably pretty close.

#### What I Would Do Differently

If I were to start over, there are three other approaches I might consider.

##### A Genetic Algorithm

Probably not practical, but worth mentioning.

Generate a population of unsolved sudoku puzzles with a set number of clues each and with no care as to the difficulty of the puzzle, or the uniqueness of the solution.

Breeding might involve creating a random bitmask of some kind, and then applying it to the a pair of puzzles to create a new one. We then equalize the new board, adding random clues or removing random clues to reach a desired tolerance of number of clues. Mutations would occur as part of the equalization process. (This is just a rough idea, might need to be changed).

The fitness function would be the closeness to the desired difficulty. This might be the speed in which a good search algorithm is able to complete the puzzle; it could also be the number of clues given. A secondary fitness function is needed to tell when the algorithm can terminate: the number of unique solutions.

Genetic algorithms can be very time consuming, and I have little idea how to really speed this up, all parts involved include costly operations.

##### Hole Digging

This is pretty much exactly as described (albeit poorly) in [2]. Generate a legal solution board, then dig holes in a pattern following criteria that specifies how not to make the game unsolvable. This approach will require the guesswork and difficulty measurement described in the question prompt, as far as I can tell.

##### Inverse Constraint Satisfaction

A different kind of hole digging approach. The idea here is to use something similar to [4] where I would formalize legal moves and perform the search for possiblities to remove in such a way that they would not compromise the unique solution of the configuration.  
I call it Inverse because (I could be wrong about this) each possible legal move to remove a piece of the puzzle would theoretically map to a kind of logic inference technique needed to deduce that cells value once removed.  
Here the difficulty can be controlled by assigning each of those legal moves with a difficulty rating, and when the user wishes for an easier puzzle, exclude the harder difficulty moves from the search.

## Other Thoughts

### Another Solver

When building my database of sudoku puzzles, I played around with [3] and in order to both generate my solutions and satisfy my curiosity. The website can present you with a puzzle from what appears to be a pool of pre-generated graded puzzles, but more interestingly, it can solve them, or any arbitrary puzzle, very quickly. It can also verify a valid puzzle, tell you a solution exists, and once solved, coach the player on the steps it took to solve the puzzle (showing the estimated difficulty of each step i.e. simple, easy, intermediate, hard), again even for puzzles you provide to it.

But the coaching isn't perfect, it breaks down on what it determines are harder puzzles. This leads me to believe that its solver is also a search rather than a constraint satisfaction method, otherwise the coaching wouldn't break down after several steps in the harder puzzles.  
But the loose end here is that it can analyze the difficulty of puzzles you input into the system. A Search can't really do that, but a constraint satisfaction solver could.

#### Grading Difficulty

This is speculation, but they clearly use two solvers, a search of some kind (which is faster than mine) and a constraint satisfier algorithm which is how they determine the difficulty of an arbitrary puzzle. I suspect the grading works like this:

- The constraint solver has sets of moves that it can perform to solve a sudoku puzzle
  - Each kind of move has an assigned difficulty value, presumably based on the amount of thought needed to keep track of it, difficulty of spotting said move, etc.
  - Of all the puzzles I have had it solve, I have never seen it rate a move as hard, (even though it claims such a rating exists)
- Puzzles which cannot be solved by the constraints solver are given the hardest difficulty rating.
- Puzzles which can be solved by the constraints solver are given a difficulty rating equivalent to the hardest move it needed to perform.
  - If there is an exceptional number of one type of move, it might rate the puzzle a little harder.

Following those guidelines, it could explain the behavior I have observed using the site.

##### Continuousness

Obviously these are discrete values of difficulty. At best it would be a very weak indication of how long it takes to solve the puzzle. Using these values, however and other metrics, I believe a stronger indication could be estimated.

We could, for example, estimate time to completion by the moves provided by the constraints solver, (giving each type it's own estimated time it takes to complete).  
For any puzzle not solvable by the constraints solver, we have a contingency. For such puzzles, the website posts the moves it finds up until it cannot find any more. This is what I propose:

1. Solve as far as you can with the constraints solver
2. Then perform the Search solver to solve the rest of the puzzle
  - This search needs to have some optimization to select the most likely next move
3. Assume the next move is a "hard" for the constraints solver and add it to the list
4. Repeat 1-3 until puzzle is solved using the constraints solver.
5. Assign an estimated time value to each "hard" move based on the number of open cells available at the time, how long the search took, etc.

This would require some fine tuning, but I feel it could work.

#### An Aside about the Search Solver

I am led to speculate on how their search is better than mine, and I do have a guess. My search is a naïve DFS:

1. It starts at the top left and scans the rows until it finds the first empty cell
2. It finds all the possible solutions for that cell, excluding those in it's cluster, row, and column
3. For each possibility it creates a new board with that value filled in
4. It recursively searches until it reaches a board state that is full, where it will return 1
  * If it should find that the first blank cell has no valid moves, it returns 0. This is a dead end.
5. those 1s trickle upward and notify the primary caller with the number of possible solutions found

This may seem slow, but on certain configurations, it's very fast. The key to terminating quicker is to reach the dead ends quicker, and this happens by random chance with my solver. The same puzzle jumbled randomly can sometimes vary wildly between time to solve, (one of the biggest variances I have seen is 0.435 seconds, and 15.6 seconds).  
Like any search, we can speed it up by limiting it's branching factor. Instead of expanding the tree by finding the first empty cell, we could instead represent our board with the expansions inhenrent in the empty cells.

One such representation would be:

- Each cell is a single 9-bit value, with one bit for each possible value.
 - The value of `0x1FF` would mean that that cell could be anything.
 - The value of `0x150` would mean it could only be 5, 7, or 9.
 - `0x020` would mean that the cell is exactly 6.

The new algorithm would be as follows. To prepare a sudoku puzzle to be solved:

1. Create a blank board with each cell being the value `0x1FF`
2. Insert in the values of the puzzle's clues into their appropriate cells, using the binary representation.
3. Perform a propogation algorithm to update the non-specific clues:
  1. Iterate over every cell
  2. For every cell we find a concrete value, remove that possibility from every other cell in the same row, column and cluster
  3. Repeat this propogation until we get a propogation in which no change is made.

Now we perform the search:

1. We iterate over every cell in the grid:
  1. If any cell has a value of `0x000`, return a zero
  2. For all cells which have more than one value we insert them into a priority queue, smallest numbers at the top
2. If our queue is empty, return a one
3. Pull the most promising candidate cell from the top of the queue
  - If memory usage is a concern, we can delete the queue here before recursion happens
4. for each possible value in the candidate cell:
  1. Copy the current board to a new board and fill in the possible value in the cell
  2. Propogate this new cell's value across its row, column, and cluster
  3. Recurse, adding the returned value to the running total

This algorithm should be much faster in theory.

### PDDL

It occurs to me that a PDDL Sudoku solver might be an interesting (and likely extremely tedious) exercise to implement.

## References

1. [Gary McGuire, Bastian Tugemann, Gilles Civario. "There is no 16-Clue Sudoku: Solving the Sudoku Minimum Number of Clues Problem" Jan 1st, 2012](http://www.math.ie/McGuire_V1.pdf)
2. [Sudoku Puzzles Generating: from Easy to Evil](http://zhangroup.aporc.org/images/files/Paper_3485.pdf)<sup>*</sup>
3. [Online Sudoku generator, grader, and solver](http://www.sudoku-solutions.com/)
4. [Bahare Fatemi, Seyed Mehran Kazemi, Nazanin Mehrasa. "Rating and Generating Sudoku Puzzles Based On Constraint Satisfaction Problems" In: *International Science Index, Computer and Information Engineering Vol:8, No:10*, 2014](http://waset.org/publications/9999524/rating-and-generating-sudoku-puzzles-based-on-constraint-satisfaction-problems)

\* I could not find a better copy of this. It has no authors listed, but I ultimately used their description of the sudoku solver, if only slightly improved.
