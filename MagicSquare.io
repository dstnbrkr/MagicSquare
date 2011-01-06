//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker@gmail.com>
//


  Cell := Object clone do (
    row := 0
    col := 0
  )

MagicSquare := Object clone do(

  order := 0
  values := list()

  emptyList := method(
    values := list()
    for(row, 1, order,
      values append(list())
      for(col, 1, order,
        values last append(nil)
      )
    )
    values
  )

  // de la Loubère method 
  nextCellOddOrder := method(cell, 
    row := (cell row - 1) % order
    col := (cell col + 1) % order
  
    if(at(row, col), 
      row = cell row + 1
      col = cell col
    )
 
    cell := Cell clone
    cell row = row
    cell col = col
    cell
  )

  nextCellDoubleEvenOrder := method(cell,
    
  )

  selectNextCellAlgorithm := method(
    if(order % 2 != 0,                  // odd
      self getSlot("nextCellOddOrder"),
      if ((order / 2) % 2 == 0,           // double even
        self getSlot("nextCellDoubleEvenOrder"),
        nil
      )
    )
  )
  
  solve := method(
    // select algorithm
    nextCell := self selectNextCellAlgorithm()

    self values := self emptyList()
    cell := Cell clone
    cell row = 0
    cell col = (self order / 2) floor
    for(i, 1, order**2,
        values at(cell row) atPut(cell col, i)
        cell = nextCell(cell)
    )
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

square := MagicSquare clone
square order := 4
square solve
square display

