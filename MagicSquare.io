#!/usr/bin/env io

//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker (at) gmail (dot) com>
//

MagicSquare := Object clone do(

  values := list()
  order := 0

  equals := method(square,
    square != nil and self values flatten == square values flatten
  )

  square := method(order,
    square := if(order % 2 != 0,          // odd
      MagicSquareOddOrder clone,
      if ((order / 2) % 2 == 0,           // double even
        MagicSquareDoubleEvenOrder clone,
        nil
      )
    )
    
    square order = order
    square solve
    square
  )
  
  solve := method(
    rows := list()
    for(i, 0, order - 1,
      row := list()
      for(j, 0, order - 1,
        row append(computeValueAt(i, j))
      )
      rows append(row)
    )
    self values = rows
  )

  at := method(row, col,
    self values at(row) at(col)
  )

  display := method(
    for(row, 0, order - 1,
      for(col, 0, order - 1,
        self at(row, col) print
        " " print
      )
      "\n" print
    )
  )

  row := method(i, 
    self values at(i)
  )

  col := method(j,
    col := list()
    for(i, 0, self order - 1,
      col append(self at(i, j))
    )
    col
  )

  diagonal := method(direction,
    diagonal := list()
    if (direction == 0,
      // northwest to southeast
      for(i, 0, self order - 1, 1,
        diagonal append(self at(i,i))
      ),

      // southwest to northeast
      for(i, self order - 1, 0, -1,
        diagonal append(self at(i, self order - 1 - i))
      )
    
    )
    diagonal 
  )

  magicNumber := method(
    n := self order
    sum := n * (n ** 2 + 1) / 2
  )
 
  sums := method(
    sums := list()
    
    sums append(self diagonal(0) sum)
    sums append(self diagonal(1) sum)
   
    for (i, 0, self order - 1,
      sums append(self row(i) sum)
      sums append(self col(i) sum)
    )
    sums  
  )
 
  isMagic := method(
    m := self magicNumber
 
    d1 := self diagonal(0) sum
    d2 := self diagonal(1) sum

    if(d1 != m or d2 != m, return false)
   
    for (i, 0, self order - 1,
      s1 := self row(i) sum
      s2 := self col(i) sum
      if(s1 != m or s2 != m, return false)
    )

    true
  )

  main := method(
    order := System args at(1)

    genetic := System args at(2)

    if (order isNil,
      "Usage: MagicNumber.io <order>\n(order must be a odd or double even positive integer)" println,
      order := order asNumber
      if (genetic == nil and (order < 1 or (order % 2 == 0 and (order / 2) % 2 != 0)),
        "Input either an odd or a double even positive integer." println
        exit(-1),
       
        if (genetic == nil, 
          square := MagicSquare square(order)
          square display
          ,
          // genetic flag set
          s := MagicSquareGenome clone
          s order = order
          s search() display
        )
      )
    )
  )

)

MagicSquareOddOrder := MagicSquare clone do(
  computeValueAt := method(i, j,
    i = i + 1
    j = j + 1
    n := self order
    n * ((i + j - 1 + (n / 2) floor) % n) + ((i + 2 * j - 2) % n) + 1 
  ) 
)

MagicSquareDoubleEvenOrder := MagicSquare clone do(

  // FIXME: cache truth table
  truthTable := method(i, j,
    table := list()
    for(i, 0, self order - 1,
      row := list()
      for(j, 0, self order - 1,
        row append( if(j == i or j == (self order - i - 1), 1, 0))
      )
      table append(row)
    )
    table 
  )

  computeValueAt := method(i, j,
    if(truthTable at(i) at(j) == 1,
      i * self order + 1 + j,
      (self order ** 2) - (j + i * self order) 
    )
  )
)

MagicSquareGenome := MagicSquare clone do(

  brute := method(
    genome := self random()
    while (genome isMagic() == false,
      genome := self random()
      genome display
      "fitness: " print
      genome fitness print
      ", isMagic: " print
      genome isMagic println
      "" println
    )
  )

  breedSelection := method(genomes,
    offspring := list()
    for(i, 0, genomes size - 1,
      for(j, 0, genomes size - 1,
        offspring append(self breed(genomes at(i), genomes at(j)))
      )
    )
    offspring flatten // flatten pairs returned by breed
  )

  search := method(

    // initial population
    genomes := list()
    for(i, 0, 100,
      genome := self random()
      genomes append(genome)
    )
 
    ngenerations   := 0
    ngenomes       := 0
    improvements   := list()
    // 3 consecutive improvements of 0 will cause the loop to exit
    for (i, 0, 3,
      improvements append(0)
    )
    bestfitness    := 0

    // while population does not contain solution
    while(genomes detect(genome, genome isMagic) == nil,
      ngenomes = ngenomes + genomes size

      genomes = genomes sortBy(block(a, b,
        a fitness < b fitness)
      )
    
      // check for convergence 
      if (ngenerations > 0,
        improvements removeFirst()
        improvements push (bestfitness - genomes at(0) fitness)
        avg := improvements average

        if (improvements average == 0,
          "Population converged without finding solution." println
          self break()
        )
      )
      bestfitness = genomes at(0) fitness

      // output generation stats
      "generation #{ngenerations}, best fitness: #{bestfitness}, improvement: #{improvements last()}" interpolate() println()

      // breed next generation
      ngenerations = ngenerations + 1
      genomes = self breedSelection(genomes slice(0, 19))
    )

    "Generated " print
    ngenomes print
    " magic squares in " print
    ngenerations print
    " generations." println

    genomes at(0)
  )

  breed := method(square1, square2,
    child1 := square1 copy
    child2 := square2 copy
    ncrossovers := Random value(1, ((self order ** 2) / 2) floor) floor
    for (i, 0, ncrossovers, 
      self crossover(child1, child2)
    )
    child1 mutate()
    child2 mutate()
    list(child1, child2)
  )

  mutate := method(
    i1 := Random value(0, self order - 1) floor
    j1 := Random value(0, self order - 1) floor
    i2 := Random value(0, self order - 1) floor
    j2 := Random value(0, self order - 1) floor
   
    v1 := self at(i1, j1)
    v2 := self at(i2, j2)

    self values at(i1) atPut(j1, v2)
    self values at(i2) atPut(j2, v1)
  )

  crossover := method(square1, square2,
    index := Random value(0, self order ** 2 - 1)
    i := (index / self order) floor
    j := index % self order
    v1 := square1 at(i, j)
    v2 := square2 at(i, j)

    // get index of soon-to-be duplicate value
    index1 := square1 values flatten indexOf(v2)
    index2 := square2 values flatten indexOf(v1)

    i1 := (index1 / self order) floor
    j1 := index1 % self order

    i2 := (index2 / self order) floor
    j2 := index2 % self order

    square1 values at(i) atPut(j, v2)   // swap in value from square2
    square1 values at(i1) atPut(j1, v1) // reconcile duplicate 

    square2 values at(i) atPut(j, v1)
    square2 values at(i2) atPut(j2, v2)
  )

  display := method(
    super(display) 
    "fitness: " print
    self fitness print
    ", isMagic: " print
    self isMagic println
    "" println
  )

  fitness := method(
    m := self magicNumber
    diffs := self sums map(sum,
      (m - sum) abs
    )
    diffs average
  )

  randomValues := method(
    n := self order ** 2
    range := Range clone
    range setRange(1, n)
    rvalues := range asList()
    // FIXME: use shuffle
    for(i, 0, n - 1,
      j := Random value(0, n)
      tmp := rvalues at(j)
      rvalues atPut(j, rvalues at(i))
      rvalues atPut(i, tmp)
    )
    rvalues 
  )

  random := method(
    rvalues := self randomValues()

    rows := list()
    for(i, 0, self order - 1,
      row := list() 
      for(j, 0, self order - 1,
        row append(rvalues at(i * self order + j))
      )
      rows append(row)
    )

    square := MagicSquareGenome clone
    square order = self order // FIXME redundant with setting values
    square values = rows
    square
  )

  copy := method(
    square := MagicSquareGenome clone
    square order = self order
    rows := list()
    for(i, 0, self order - 1,
      row := list()
      for(j, 0, self order - 1, 
        row append(self at(i,j))
      )
      rows append(row)
    )
    square values = rows
    square
  )
  
)


MagicSquare main()

