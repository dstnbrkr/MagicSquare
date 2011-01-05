
//
// Simple n x n Magic Square solver
// Dustin Barker <dustin.barker@gmail.com>

MagicSquare := Object clone do(

  order := 0

  values := method(
    values := list()
    i := 1
    while(i <= order**2,
      values append(i)
      i = i + 1
    )
    values
  )
)

square := MagicSquare clone
square order := 4
square values println

