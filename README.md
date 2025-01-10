Program written in Assembly to demonstrates use of registers, low level IO procedures, string primitives, and macros. First, the program prompts the user for 10 numbers. The 
program then utilizes macros to read and write integers via string processing rather than ReadInt and WriteInt. Each integer must be able to fit into a 32-bit 
register (range of [-2147483648, 2147483647])- the sum of the integers must do the same. The program validates the user's string input, converts it into an integer, 
and stores it in an array. The sum and average are calculated, and then the integers, the sum, and the average are displayed by converting the integers into strings and using a macro to print each.

Written in Visual Studio using the Irvine32 library
