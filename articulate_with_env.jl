
# Proposal: Homoiconic, with explicit eval

# Absraction: expr x (something with x in braces)
# Evaluation: eval expr ... ... (something to put in place of x)
# Brackets quote: (...) -> literal ...

using Match
using Base.Iterators

function Quote!(tokens, env)
    i = 1
    ret = []
    while true
        ft = popfirst!(tokens)
        @match ft begin
            "(" => begin i += 1 end
            ")" => begin i -= 1 end
            token, if token in env end => begin
                prepend!(tokens, env(token))
                continue
            end
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

# function Replace(expr, rule)
#     acc = []
#     i = 1
#     while i <= length(expr[2])
#         @match e begin
#             "expr" => begin
#                 if expr[1][1] == first(rule)
#                     i += 1
#                     # TODO
#                 end
#             end
#         end
#         i += 1
#     end
#     return acc
# end

#--- Env

mutable struct Env
    dict
end

function (e::Env)(var)
    return var in keys(e.dict) ? e.dict[var] : [var]
end

function with_rule(e::Env, rule)
    e = Env(copy(e.dict))
    e.dict[first(rule)] = last(rule)
    return e
end

import Base.in
function in(item, env::Env)
    return item in keys(env.dict)
end

#--- Eval
verbose = false

function Eval!(tokens, env)
    # env is a closure with a dict
    verbose ? println("Tokens: ", join(tokens, " ")) : nothing
    ft = popfirst!(tokens)

    @match ft begin
        "eval" => begin
            verbose ? println("------ eval") : nothing
            Eval!(prepend!(tokens, Replace(Eval!(tokens,env),Eval!(tokens,env))), env)
        end
        "expr" => begin
            verbose ? println("------ expr") : nothing
            [[popfirst!(tokens)], Eval!(tokens, env)]
        end
        "let"  => begin
            verbose ? println("------ let") : nothing
            var = Eval!(tokens, env)
            val = Eval!(tokens, env)
            Eval!(tokens, with_rule(env, var[1] => val))
        end
        "("    => begin
            verbose ? println("------ (") : nothing
            Quote!(tokens, env)
        end
        token, if token in env end => begin
            verbose ? println("------ iftoken") : nothing
            Eval!(prepend!(tokens, env(token)), env)
        end
        token  => begin
            verbose ? println("------ token saute") : nothing
            [token]
        end
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
    Eval!(to_tokens(str), Env(Dict()))
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
