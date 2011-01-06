
//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker@gmail.com>
//

MagicSquare := Object clone do(

  order := 0
  
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

  values := method(
    nil
  )

)

MagicSquareOddOrder := MagicSquare clone do (

  wrapIndex := method(index,
    // FIXME: should be if/else
    wIndex := index clone
    if(index == -1, wIndex = order - 1)
    if(index == self order, wIndex = 0)
    wIndex
  )
  
  // de la Loubère method 
  values := method(
    values := self emptyList() 
    row := 0
    col := (self order / 2) floor
    for(i, 1, order**2,
      values at(row) atPut(col, i)
      
      // new vars, might need original values 
      nextrow := wrapIndex(row - 1)
      nextcol := wrapIndex(col + 1)
  
      if(values at(nextrow) at(nextcol), 
        nextrow = row + 1
        nextcol = col
      )
  
      row = nextrow
      col = nextcol
    )
    values
  )

)

square := MagicSquareOddOrder clone
square order := 3
square values println

