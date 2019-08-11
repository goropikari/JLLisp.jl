module JLLisp

abstract type T end
abstract type Atom <: T end

module Symbols
    import ..JLLisp

    struct Symbol_
        name::JLLisp.T
        value::JLLisp.T
        fn::JLLisp.T

        function Symbol_(name::String)
            x = new()
            x.name = name
            x
        end
    end

    function symbol_(name::String)
        get!(symboltable, name, Symbol_(name))
    end

    symboltable = Dict{String, Symbol_}()
    symbolT = symbol_("T")
    symbolT.value = symbolT
    symbolQuit = symbol_("QUIT")

end # Symbols_



end # JLLisp module
