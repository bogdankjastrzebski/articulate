
# Proposal: Homoiconic, with explicit eval

# Absraction: expr x (something with x in braces)
# Evaluation: eval expr ... ... (something to put in place of x)
# Brackets quote: (...) -> literal ...

using Match
using Base.Iterators

function Quote!(tokens)
    i = 1
    ret = []
    while true
        ft = popfirst!(tokens)
        @match ft begin
            "(" => begin i += 1 end
            ")" => begin i -= 1 end
        end
        if i == 0 break end
        push!(ret, ft)
    end
    return ret
end

function Replace(expr, arg)
    acc = []
    for e in expr[2]
        if e == expr[1][1]
            for a in arg
                push!(acc, a)
            end
        else
            push!(acc, e)
        end
    end
    return acc
end

function printinplace(x)
    println(x)
    x
end



function Eval!(tokens)
    ft = popfirst!(tokens)
    # println(join(tokens, " "))
    @match ft begin
        "eval" => Eval!(prepend!(tokens, Replace(Eval!(tokens),Eval!(tokens))))
        "expr" => [Eval!(tokens), Eval!(tokens)]
        #"let"  => Eval!(Replace([Eval!(tokens), tokens], Eval!(tokens)))
        "("    => Quote!(tokens)
        token  => [token]
    end
end

function to_tokens(str)
    mask = zeros(Bool, length(str))
    switch = true
    for i in 1:length(str)
        s = str[i] == '#'
        switch = s ? ~switch : switch
        mask[i] = switch && ~s
    end
    str = join(split(str, "")[mask])
    str = replace(str, ":" => " : ")
    str = replace(str, "(" => " ( ")
    str = replace(str, ")" => " ) ")
    return String.(split(str))
end

function Interpret(str)
    Eval!(to_tokens(str))
end

# function Eval!(tokens)
#     println(join(tokens, " "))
#     ft = popfirst!(tokens)
#     @match ft begin
#         "eval" => begin
#             ex = Eval!(tokens)
#             ar = Eval!(tokens)
#
#             ret = Eval!(vcat(Replace(ex, ar), tokens))
#             println("""
#             ----------------------
#             Evaluating:
#                 name : $(ex[1][1])
#                 body : $(ex[2])
#                 arg  : $ar
#                 ret  : $ret""")
#             ret
#         end
#         "expr" => [Eval!(tokens), Eval!(tokens)]
#         "("    => Quote!(tokens)
#         token  => [token]
#     end
# end

# function Eval!(tokens)
#     while true
#         println(join(tokens, " "))
#         ft = popfirst!(tokens)
#         @match ft begin
#             "eval" => begin
#                 ex = Eval!(tokens)
#                 ar = Eval!(tokens)
#
#                 dd = Replace(ex, ar)
#
#                 println(vcat(dd, tokens))
#                 prepend!(tokens,dd)
#                 println(tokens)
#             end
#             "expr" => begin return [Eval!(tokens), Eval!(tokens)] end
#             "("    => begin return Quote!(tokens) end
#             token  => begin return [token] end
#         end
#     end
# end
