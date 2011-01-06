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

square := MagicSquare square(5)
square println
square solve
square display
square isMagic println

