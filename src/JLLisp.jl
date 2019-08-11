module JLLisp

abstract type T end
abstract type Atom <: T end
abstract type Number_ <: Atom end
abstract type List <: T end
struct Null <: List end

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
    struct Integer_
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
