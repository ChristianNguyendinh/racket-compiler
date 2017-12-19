# CMSC 430 Racket Compiler

### Project Description:
This project is the combined result of multiple projects from the Fall 2017 CMSC430 UMD course, taught by Professor Thomas Gilray. The combined result is a compiler that will take scheme code, and compile it to an executable binary. 
The compiler has the following phases:

**1. Top level:** Adds explicit begins, quotes datums, desugars defines, quasiquotes/unquotes, and match statements

**2. Desugar:** Desugars the output of top level into a smaller core language. Desugars things like letrec\*/letrec, guard/raise, promises, cond, case, etc...

**3. Simplify IR:** Simplifies the intermediate representation produced by desugar and performs some optimizations, to make future passes easier. For example, (+) => 0, (+ 2) => 2, (+ 1 2 3 4) => (+ 1 (+ 2 (+ 3 4))

**4. Assignment Convert:** Removes set! mutations by boxing all mutable variables inside of a size 1 vector

**5. Alphatize:** Makes all binding names unique, removing shadowing.

**6. ANF Convert:** Flattens let forms with multiple bindings into nested lets. Removes all subexpressions by hoisting them to let bindings. This phase, combined with Alphatize, and Assignment Convert, give us an IR that is in Static Single Assigment (SSA) forms, in preparation for later phases

**7. CPS Convert:** Converts our IR to continuation passing style, where no function call returns, and instead the current continuation is invoked. This makes it so that points that would have extended the stack are now closures (with an environment for free variable references), and we pass forward callback functions that will be called in tail position, eliminating the need for a stack

**8. Closure Convert:** Removes all lambdas, replaces them with closures, with appropriate environment references, lifts variable references to let bindings, and removes variadic lambdas - by having all lambda take in one parameter of a list of arguments, then extracting the original expected arguments from that list. The phase outputs a list of procedure abstracts, with a minimal language

**9. LLVM:** With our IR now being in SSA, with continuation passing style, we can use the LLVM backend to compile our IR into executable bytecode. This phase takes the procedure output from the previous phase, and outputs strings of LLVM code that will produce an equivalent LLVM IR. This LLVM string is then concatenated to a LLVM compiled C++ header file (which contains some helper functions for things like primative operations and printing), and then compiled via clang++ into an executable bytecode file (default named bin).

---

### Supported Primative Operations:
\*All Primatives may be called with the apply function in the form (apply &lt;prim&gt; &lt;list of args&gt;). Where the first argument to apply is the primative name, the second is the list of arguments to be passed into the primative.

| Primative | # Params | Param Type | Effect |
| --- |:---:|:---:| --- |
| print | 1 | Any | Prints that argument out to stdout |
| vector | Any | Any... | Returns a vector of the passed in arguments, with each element initialized in the order they are passed in.|
| make-vector | 2 | Int, Any | Returns a vector of given length, with each element initialized to the given initial value |
| vector-ref | 2 | Vec, Int | Returns the value at given index in given vector. |
| vector-set | 3 | Vec, Int, Any | Sets the value at the given index in the given vector to be the given new value. |
| void | Any | Any... | Ignores all arguments given. Returns the constant \#<void\> |
| eq? | 2 | Any, Any | Returns #t if the two passed in arguments refer to the same object, #f otherwise. |
| number? | 1 | Any | Returns #t if the argument refers to a number. #f otherwise |
| integer? | 1 | Any | turns #t if the argument refers to an integer. #f otherwise. |
| void? | 1 | Any |  Returns #t if the argument is the constant \#<void\>. #f otherwise |
| procedure? | 1 | Any |  Returns #t if the argument is the a procedure. #f otherwise |
| null? | 1 | Any |  Returns #t if the argument is the empty list '(). #f otherwise |
| cons? | 1 | Any |  Returns #t if the argument is a cons (a pair). #f otherwise |
| cons | 2 | Any, Any | Returns a pair with the first element being a, and the second b. |
| car | 1 | Cons | Returns the first element in the given pair argument. |
| cdr | 1 | Cons | Returns the second element in the given pair argument. |
| \+ | Any | Int... | Adds all the arguments together and returns the sum. |
| \- | Any | Int... | Subtracts all the arguments, starting with the first argument minus by the second argument, then the result minus by the third argument, etc. Returns the difference. |
| \* | Any | Int... | Multiplies all the arguments together and returns the result. |
| / | Any | Int... | Divides all the arguments, starting with the first argument divided by the second argument, then the result divided by the third argument, etc. Returns the result. |
| = | Any | Int... | Returns #t if all the numbers given are equal, #f otherwise. |
| < | Any | Int... | Returns #t if all the numbers given are in strictly increasing order, #f otherwise. |
| <= | Any | Int... | Returns #t if all the numbers given are in increasing or equal order, #f otherwise. |
| \> | Any | Int... | Returns #t if all the numbers given are in strictly decreasing order, #f otherwise. |
| \>= | Any | Int... | Returns #t if all the numbers given are in decreasing or equal order, #f otherwise. |
| not | 1 | Any | Returns #t if the argument is #f, returns #f otherwise. |
| append | Any | List... | Returns a single list consisting of all the elements of the given argument lists, in the given order. |
| promise? | 1 | Any | Returns #t if the argument is a promise, #f otherwise. |
| string | Any | Char... | Returns a string of all the characters concatenated in order. |
| string->list | 1 | Str | Returns a list of every character in that string, in order. |
| string-ref | 2 | Str, Int | Returns the character at the given parameter index in the given string. |
| substring | 3 | Str, Int, Int | Returns a string, starting at the second parameter index, and ending before the third parameter index, of the passed in string. |
| string-append | Any | Str... | Returns a string, consisting of the concatenation of all the parameter strings, in order. |

---

### Run Time Exceptions:
##### 1. Divide by 0: 
Originally, if we try to divide by 0, we get a ambiguous LLVM "Floating Point Exception". To fix this, in header.cpp, we modify the / prim (prim__47), to check if its second parameter is a 0. If so, the program halts with the message: "Error: Division by Zero"

##### 2. Not Enough Function Arguments: 
Originally, if we don't provide enough arguments for a function, we get a message telling us that the program "Expected a cons value", not very helpful to the end user. Looking at the code of remove-varargs in closure-convert.rkt, we see this is because to extract the arguments from a function's argument list (all functions take one parameter of an argument list after changes made to remove variable argument lambdas), a series of cars and cdrs are used to extract from, and update the passed in argument list. The expected cons error occurs when we try to car and empty list. To fix this, before each car, we add a check to see if the argument list is null. If it is, too few arguments were provided, so we halt with the error message: "Error: Function &lt;function name&gt; was provided too few arguments", if not, we continue as normal.

##### 3. Too Many Function Arguments: 
Originally, if we provide too many arguments for a function, the function runs normally, with the extra arguments ignored. Now, if we provide too many arguments for a function, the program halts when executing that function with "Error: Function &lt;function name&gt; was provided too many arguments". In remove-varargs in closure-convert.rkt, at a function definition, the code extracts the arguments from the passed in argument list. To see if too many arguments were provided, after we extract the arguments, we check to see if there is anything left over in the list, if there is, too many arguments were provided, so we halt with the error, if not, we continue with the normal function execution. 

##### 4. Incorrect Number of Primative Function Arguments: 
Originally, if we provide an incorrect number of function arguments, we fail at the LLVM runtime stage, with a LLVM function signature mismatch error. To fix this, in closure-convert.rkt, if a primative is provided an incorrect number of arguments, we halt, saying "Error: Invalid Number of Arguments Passed to a Primative". We do this by including a hash called prim-params that map the primative LLVM function names (strings) to the number of arguments that they must take (integers). Then in proc->llvm, at each prim application, we check to see if the number of arguments being passed in, matches the expected number of parameters, if not, we halt the program there with the error message. 

##### 5. Non-function value is applied:
Originally, if we try to apply a non-function value, we usually segmentation fault. Now, before each function application, we run a check in closure-convert.rkt to see if the value being applies returns #t after being passed into the primative procedure?. If it returns #t, it is a function, so we proceed as normal. If it returns #f, we halt the program with the error message: "Error: Tried to Apply Non-Function".

##### Notes:
Since we use a halt to "throw" these errors and end the program, if the program never executes the code section that these errors appear in, no errors will be thrown. From what I've seen, Racket is similar in this sense, so I believe it is okay, as these are runtime errors afterall. I also believe that all of the error messages are sufficient; the incorrect number of function argument errors have the associated llvm function name, which the user can look at in the llvm output; the incorrect number of primative argument errors and non-function application produce a halt that has a comment at the line the program is halting at to point them in the right direction; and divide by zero is pretty self explanatory.

##### Testing:
To test we hardcode the expected string for each test, and matching on the test name, we check to see if the test is correct. We only do this for test files that end in .err. Things got a bit (very) hacky with the error messages that return the names of llvm functions. We include 2 tests for each of the errors above, each ending with .err.

---

### New Feature - Strings:
The new feature I chose to add was Strings and Characters (with character datums), supporting the primatives: string, string->list, string-ref, substring, and string-append.
Here are a descriptions of the modifications I made to implement this new feature.

* Added character to be datums inside utils.rkt

* Modified header.cpp to have tagging and a const init function for characters, similar to int, cons, and other datums. Also added character support for the print functions (prim_print and prim_print_aux).

* In closure-convert.rkt, when outputting LLVM code, we add a case for a let binding of a character datum, which outputs a call to const_init_char with the numerical value of the character as the argument.

* Added support for the prim string-append. Added the prim_string_45append function in header.cpp, that takes two tagged string parameters and concatenates them using string functions from the C++ standard library and returns the concatenated tagged string. Modfied simplify-ir in utils.rkt to adjust the function call for a dynamic number of parameters, by nesting calls so that each passing in two arguments.
Ex. (string-append "a" "b" "c" "d") => (string-append "a" (string-append "b" (string-append "c" "d")))

* Added support for the prim string. Added the prim_string function in header.cpp, that takes one tagged character parameter, and returns a tagged string of that character followed by a null byte. Modfied simplify-ir in utils.rkt to adjust the function call for a dynamic number of parameters, by running string-append on the result of running string on each character.
Ex. (string #\a #\b #\c) => (string-append (string #\a) (string #\b) (string #\c)) =>* "abc"

* Added support for the prim string-ref. Added the prim_string_45ref function in header.cpp, that takes one tagged string parameter, and a second tagged integer i parameter. It returns the tagged character at given integer argument i inside the given argument string. 0 based indexing.

* Added support for the prim string->list. Added the prim_string_45_62list function in header.cpp that takes in one tagged string parameter. It returns the tagged characters in order in a list, by looping through the string and performing cons after tagging each character.

* Added support for the prim substring. Added the prim_substring function in header.cpp that takes in one tagged string parameter, a second tagged integer parameter, and a third tagged integer parameter. It returns a tagged string, of the sub string starting from the second integer parameter argument, and ending before the third integer parameter argument. It does not support an optional third argument like in Racket, because I ran out of time.

Like the other primatives, these new primatives can be used with apply.

---

### Boehm Garbage Collector
Implementation of the Boehm Garbage Collector has been omitted, and left as a exercise to the reader ;)

---

### University of Maryland Academic Integrity Declaration:
> I, Christian Nguyendinh, pledge on my honor that I have not given or received any unauthorized assistance on this assignment.

Code for this project was taken from Professor Thomas Gilray's [assignment reference solutions](https://www.cs.umd.edu/class/fall2017/cmsc430/)
Considering putting all this together is our final exam project, I wanted the extra safety and insurance that the code for each part that I was building off of was worked correctly.
In the future (after the project is graded), I may change compiler passes to my solutions instead of the reference solutions.

---




