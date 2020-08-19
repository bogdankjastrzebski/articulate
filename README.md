# articulate
 The official repo of the articulate programming language!

articulate language is a multiple dispatch, jit compiled and homoiconic language.

It uses polish notation. All expressions have constant number (arity) of arguments and they are RIGHT associative:
```
f g h 3 = f (g (h 3)))

two-arg-expr f 3 g 3 = two-arg-expr (f 3) (g 3)
```
Please note, that expressions are not necessarily functions in the mathematical sense.

The language allows dispatch on expressions, which leads to full code reinterpretation based on type.

Example:
```
ep parallel (elem CudaArray arr body) {
    ;; a routine dedicated to Cuda Arrays, that does things in parallel on cuda machine for every element in an array 
    ...
}

ep parallel (elem MultiThreadedArray arr body) {
    ;; a routine dedicated to MultiThreadedArray, that spawn a thread for every element in an array
    ...
}

pr foo (arr) {  ;; pr stands from "procedure"
    parallel el in arr {  ;; "in" returns item following it.
        add-to el 1     ;; passed by reference 
    }
    return sum arr
}

vr cuda-array = cu [i for i in 1:100]    

vr multi-threaded-array = mtha [i for i in 1:100]
```

The following do different things:
```
foo cuda-array

foo multi-threaded-array
```

Explanation of the code above:
* ep - expression keyword; arity(ep) = 4, expression also takes the rest of the code as an argument.
* pr - procedure keyword; arity(pr) = 4
* vr - variable keyword; arity(vr) = 3
* { - begin a new block keyword; arity({) = 1
* } - end of the block keyword; arity(}) = 0
* return - return keyword; arity(return) = 2, it takes return value and "}"

When pr is called, its first argument "foo" is undefined and so, it has the arity of 0. () is one list or arguments. "{" appears and it simply quotes the next thing.
This next thing is "parallel" defined previously. parallel takes its arguments - elem, arr and body and last logical element - the rest of the code, as it doesn't return anything. The rest of the code is return. return takes sum, which takes 1 argument, and "}", which has arity of 0. Here, finally, "{" terminates.

Three things taken at this point by the "pr" expression are: name "foo", list of arguments and "{". The fourth thing will by the code following it, in which we can use "foo" procedure.

In articulate functions are functional, we don't allow any side effects. "functions" in computer science sense are called here "procedures". 


