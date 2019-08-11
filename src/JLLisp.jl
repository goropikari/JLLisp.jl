module JLLisp

abstract type T end
abstract type Atom <: T end
abstract type Number_ <: Atom end
abstract type List <: T end
struct Null <: List end

module Eval
    import ..JLLisp
    const maxstacksize = 65536
    const stack = Vector{JLLisp.T}(undef, maxstacksize)
    stackP = 0

    function eval_(form::JLLisp.T)
        if isa(form, JLLisp.Symbols.Symbol_)
            try
                symbolvalue = form.value
            catch
                error("Unbound Variable Error: $(form)")
            end
            return symbolvalue
        end

        if isa(form, JLLisp.Null) return form end
        if isa(form, JLLisp.Atom) return form end
        # todo: cons
    end

end # Eval

module Symbols
    import ..JLLisp

    mutable struct Symbol_ <: JLLisp.Atom
        name::String
        value::JLLisp.T
        fn::JLLisp.T

        function Symbol_(name::String)
            x = new()
            x.name = name
            x
        end
    end

    const symboltable = Dict{String, Symbol_}()
    function symbol_(name::String)
        get!(symboltable, name, Symbol_(name))
    end

    const symbolT = symbol_("T")
    symbolT.value = symbolT
    const symbolQuit = symbol_("QUIT")

end # Symbols_

module Integer__
    import ..JLLisp
    struct Integer_ <: JLLisp.Number_
        value::Integer
    end

    # todo: other operations
    add(a::Integer_, b::Integer_) = Integer_(+(a.value, b.value))
end # Integer__

module Cons_
    import ..JLLisp
    mutable struct Cons <: JLLisp.List
        car::JLLisp.T
        cdr::JLLisp.T
    end

    function Cons()
        Cons(JLLisp.Null(), JLLisp.Null())
    end
end#module


end # JLLisp module
