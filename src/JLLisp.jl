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
        car = form.car
        isa(car, JLLisp.Symbols.Symbol_) || error("Not a Symbol: $(car)")
        try
            global fun = car.fn
        catch
            error("Undefined Function Error: $(car)")
        end

        # システム関数の評価
        if isa(fun, JLLisp.Function_.Func)
            argumentlist = form.cdr
            return JLLisp.Function_.funcall(fun, argumentlist)
        end

        # if isa(fun, JLLisp.Cons_.Cons)
        #     cdr = fun.cdr
        #     lambdalist = cdr.car
        #     body = cdr.cdr
        #     lambdalist == JLLisp.Null() && return evalbody(body)
        #
        #     return bindevalbody(lambdalist, body, form.cdr)
        # end
        error("Not a Function: $(fun)")
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


module Function_
    import ..JLLisp
    abstract type Func <: JLLisp.Atom end

    function funcall(fn::Func, arguments::JLLisp.List)
        return JLLisp.Null()
    end

    function regist(name::String, fn::Func)
        sym = JLLisp.Symbols.symbol_(name)
        sym.fn = fn
    end

    struct Car <: Func end
    struct Cdr <: Func end
    struct FunCons <: Func end
    struct Add <: Func end
    struct Defun <: Func end
    struct SymbolFunction <: Func end

    function funcall(fn::Car, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        return arg1 == JLLisp.Null() ? JLLisp.Null() : arg1.cdr
    end

    function funcall(fn::Cdr, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        return arg1 == JLLisp.Null() ? JLLisp.Null() : arg1.cdr
    end

    function funcall(fn::FunCons, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Cons_.Cons(arg1, arg2)
    end

    function funcall(fn::Add, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.add(arg1, arg2)
    end

    function funcall(fn::Defun, arguments::JLLisp.List)
        arg1 = arguments.car
        args = arguments.cdr
        fun = arg1
        lambda = JLLisp.Cons_.Cons()
        lambda.car = Symbol_.symbol_("LAMBDA")
        lambda.cdr = args
        fun.fn = lambda
        return fun
    end

    function funcall(fn::SymbolFunction, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        return arg1.fn
    end

    function registSystemFunctions()
        regist("CAR", Car())
        regist("CDR", Cdr())
        regist("CONS", FunCons())
        regist("ADD", Add())
        regist("Defun", Defun())
        regist("SYMBOL-FUNCTION", SymbolFunction())
    end
    registSystemFunctions()



end # Function_

end # JLLisp module
