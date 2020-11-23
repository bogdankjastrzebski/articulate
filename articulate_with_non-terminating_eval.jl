
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
            # token, if token in env end => begin
            #     prepend!(tokens, env(token))
            #     continue
            # end
        end
        if i == 0 break end
        push!(ret, ft)
    end
    return ret
end

# Env

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

# Eval
function Eval!(tokens, env)
    # env is a closure with a dict
    verbose ? println("Tokens: ", join(tokens, " ")) : nothing

    if length(tokens) == 0
        return []
    end
    
    @match popfirst!(tokens) begin
        "eval" => Eval!(prepend!(tokens, Replace(Eval!(tokens,env), Eval!(tokens,env))), env)
        "expr" => [popfirst!(tokens), Eval!(tokens, env)]
        "let"  => Eval!(tokens, with_rule(env, Eval!(tokens, env) => Eval!(tokens, env)))
        "("    => Quote!(tokens, env)
        token, if token in env end => Eval!(prepend!(tokens, env([token])), env)
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
    Eval!(to_tokens(str), Env(Dict()))
end
