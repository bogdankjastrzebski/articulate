# articulate
 The official repo of the articulate programming language!

articulate language is a multiple dispatch, jit compiled and homoicoinic language.
It allows dispatch on expressions, which leads to full code reinterpretation based on type.

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

fn foo (arr) {
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
