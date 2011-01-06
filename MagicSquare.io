//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker@gmail.com>
//

MagicSquare := Object clone do(

  values := list()
  order := 0

  square := method(order,
    square := if(order % 2 != 0,          // odd
      MagicSquareOddOrder clone,
      if ((order / 2) % 2 == 0,           // double even
        MagicSquareDoubleEvenOrder clone,
        nil
      )
    )
    square order = order
    square
  )
  
  solve := method(
    cols := list()
    for(i, 0, order - 1,
      row := list()
      for(j, 0, order - 1,
        row append(computeValueAt(i, j))
      )
      cols append(row)
    )
    self values = cols
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
)

MagicSquareOddOrder := MagicSquare clone do(
  computeValueAt := method(i, j,
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

square := MagicSquare square(4)
square println
square solve
square display

