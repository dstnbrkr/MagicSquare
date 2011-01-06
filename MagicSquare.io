
//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker@gmail.com>
//

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
  
  solve := method(
    self values := self emptyList()
    cell := Cell clone
    cell row = 0
    cell col = (self order / 2) floor
    for(i, 1, order**2,
        values at(cell row) atPut(cell col, i)
        cell = self nextCell(cell)
    )
  )

  display := method(
    for(row, 0, order - 1,
      for(col, 0, order - 1,
        self values at(row) at(col) print
        " " print
      )
      "\n" print
    )
  )
)

Cell := Object clone do (
  row := 0
  col := 0
)

MagicSquareOddOrder := MagicSquare clone do (

  wrapIndex := method(index,
    if(index == -1, 
      order - 1,
      if(index == self order, 0, index)
    )
  )

  // de la Loubère method 
  nextCell := method(cell,
    row := wrapIndex(cell row - 1)
    col := wrapIndex(cell col + 1)
  
    if(self values at(row) at(col), 
      row = cell row + 1
      col = cell col
    )
 
    cell := Cell clone
    cell row = row
    cell col = col
    cell
  )

)

square := MagicSquareOddOrder clone
square order := 3
square solve
square display

