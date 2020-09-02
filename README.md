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

# Update

The syntax is to be discussed. This section will elaborate on a novel type system.

# Type system

The expression problem is often described as a trade-off between functional and objective programming languages. In one paradigm, we can easily add functionality to an existing type, but it's difficult to reuse code. On the contrary, the other makes the former problem difficult to solve and the latter simple.

```
       
|----------------------------|-----------------------------------------------|
|                           FUN     add functionality to an existing type    |   
|------- OOP ----------------|-----------------------------------------------|
|   add new types to         |  
|  an existing functionality |
|----------------------------|

```


Adding methods outside the class definition is a well known solution to OOP problem. To make it work, language must follow with defining a proper type system.

What about the missing part of the Fig. above? Adding a new functionality to a new type is of course possible, however, we can interpret the missing right lower square differently: adding existing functionality to an existing type. Keep that in mind, because julia language, that aimed to solve the expression problem doesn't address that case.

The strength of julia is not only it's multiple dispatch itself, but an intentional side-effect it carries on with. The code of julia libraries is largely untyped. That allows for calling a function on a new type - polimorphism. However, once we need to add an alternative method, the code becomes typed. Now the only option to use a particular implementation is to make ones new type a subtype of what it has been dispatched on. Consider the following example:

```julia

function foo(x::A)
   # do something
   return something
end

function foo(x::B)
   # do something
   return something
end

struct MyStruct <: B
   # something
end
```

This however can be problematic for two reasons. Firstly, we want our struct to be in a different place of the hierarchy tree. Secondly, if we don't have access to type definition, e.g. when using popular type from different package, we have to create new type. This basically becomes the next OOP. 

Allowing a struct to be of many types, would solve the first problem, however, it would produce type ambiguities in runtime. The second problem can be solved moving "hierarchy statement" out of a struct definition:

```julia
struct MyStruct
 # something
end

let Mystruct <: B
```

There's also a problem with terminal states, because if B is a struct and not an abstract type, this means we can't create a subtype of it or equivalent.

Understanding types as a hierarchy is problematic. It doesn't model properly what types are mathematically. For instance, a vector space consist a field and a abelian group inside, and so it's more specific in respect to both, i.e. is a subtype of both. Types could be represented via preorder.

I propose a different solution. Let M be a set of method symbols (simply methods), P a set of procedures and T a set of type symbols (simply types). We want to connect methods with types with procedures. We do it with a statement: let $methodA(typeB) = procedureC$, where $methodA \in M, typeB \in T, procedureC \in P$. This statement makes every time a methodA is called on typeB evaluate procedureC. We can now bind methodA with other type. Most importantly, we can use procedureC with totally different method and type. This allows for more code reuse and provides an elegant solution to the "expression problem".

Our code should look like this:

```

# Structs

struct MyStruct
   # something
end

# Procedures

function A(x)
   do something
end

function B(x)
   do something
end

# Methods

there's a method called foo # here we can do something else later, when we consider adding arity to expression - method.

# Binding
let foo(MyStruct): A

```








