#!/usr/bin/env io

//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker (at) gmail (dot) com>
//

List standardDeviation := method(
  avg := self average()
  (self map(v, (v - avg) ** 2) sum() / self size()) ** (1/2)
)

MagicSquare := Object clone do(

  order := 0
  magicNumber := 0
  at := nil

  display := method(
    for(row, 0, order - 1,
      for(col, 0, order - 1,
        self at(row, col) print
        " " print
      )
      "\n" print
    )
  )

  valueList := method(func,
    result := list()
    for(i, 0, order - 1,
      index := func call(i);
      result append(self at((index / order) floor, 
                            index % order));
    )
    result
  )

  row := method(i,
    self valueList(block(n, i * order + n));
  )

  col := method(i,
    self valueList(block(n, n * order + i));
  )

  diagonal1 := method(
    self valueList(block(n, n * order + n));
  )
  
  diagonal2 := method(
    self valueList(block(n, (n + 1) * order - n - 1));
  )
 
  isMagic := method(
    m := self magicNumber

    if(self diagonal1 sum != m, return false);
    if(self diagonal2 sum != m, return false);
   
    for (i, 0, self order - 1,
      s1 := self row(i) sum
      s2 := self col(i) sum
      if(s1 != m or s2 != m, return false)
    )

    true
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

  search := method(initialpop, selectedpop,
    // initial population
    genomes := list()
    for(i, 0, initialpop,
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
    magic := nil
    while(magic == nil,
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
      genomes = self breedSelection(genomes slice(0, selectedpop))
      magic = genomes detect(genome, genome isMagic)
    )

    "Generated " print
    ngenomes print
    " magic squares in " print
    ngenerations print
    " generations." println

    magic
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
    index1 := square1 values indexOf(v2)
    index2 := square2 values indexOf(v1)

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
  
  sums := method(
    sums := list()
   
    sums append(self diagonal1 sum)
    sums append(self diagonal2 sum)
   
    for (i, 0, self order - 1,
      sums append(self row(i) sum)
      sums append(self col(i) sum)
    )
    sums  
  )

  fitness := method(
    m := self magicNumber
    diffs := self sums map(sum,
      (m - sum) abs
    )
    diffs average() + diffs standardDeviation()
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
    square order = self order
    square magicNumber = self magicNumber
    square values = rows
    square
  )

  copy := method(
    square := MagicSquareGenome clone
    square order = self order
    square magicNumber = self magicNumber
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

makeMagicSquareDoubleEven := method(square,

  square do (
    truthTable := Object clone;
    truthTable order := order;
    truthTable at := method(i, j,
      if(j == i or j == (self order - i - 1), 1, 0);
    )
   
    at = method(i, j,
      if(self truthTable at(i, j) == 1,
        i * order + 1 + j,
        (order ** 2) - (j + i * self order) 
      )
    )
  )
)

makeMagicSquareOdd := method(square,
  square do (
    at = method(i, j,
      i = i + 1;
      j = j + 1;
      n := self order;
      n * ((i + j - 1 + (n / 2) floor) % n) + ((i + 2 * j - 2) % n) + 1;
    )
  )
)

makeMagicSquareGenetic := method(square,
  square do (
    solve := method(
      s := MagicSquareGenome clone;
      s order = order;
      s magicNumber = magicNumber;
      return s search(100, 20);
    )
  )
);

makeMagicSquare := method(order, genetic,

  square := MagicSquare clone
  square order = order
  square magicNumber := order * (order ** 2 + 1) / 2;

    if (genetic,
      makeMagicSquareGenetic(square);
    );

    if ((order / 2) % 2 == 0,
      makeMagicSquareDoubleEven(square);
    );

    if (order % 2 != 0,
      makeMagicSquareOdd(square, order);
    );

    return square;
);

main := method( 
  order := System args at(1);
  genetic := System args at(2);

  if (order isNil,
    "Usage: MagicNumber.io <order>" println
    return -1;
  );
  
  square := makeMagicSquare(order asNumber(), genetic);
  square display();
  return 0;
)

main();

