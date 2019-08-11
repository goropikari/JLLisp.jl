module JLLisp

abstract type T end
abstract type Atom <: T end
abstract type Number_ <: Atom end
abstract type List <: T end
struct Null <: List end
const Nil = Null()
Base.string(x::Null) = "NIL"

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

    Base.string(x::Symbol_) = x.name
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
    lisptf(bool) = bool ? JLLisp.Symbols.symbolT : JLLisp.Null()
    add(a::Integer_, b::Integer_) = Integer_(+(a.value, b.value))
    sub(a::Integer_, b::Integer_) = Integer_(-(a.value, b.value))
    mul(a::Integer_, b::Integer_) = Integer_(*(a.value, b.value))
    Base.div(a::Integer_, b::Integer_) = Integer_(div(a.value, b.value))
    ge(a::Integer_, b::Integer_) = lisptf(>=(a.value, b.value))
    le(a::Integer_, b::Integer_) = lisptf(<=(a.value, b.value))
    gt(a::Integer_, b::Integer_) = lisptf(>(a.value, b.value))
    lt(a::Integer_, b::Integer_) = lisptf(<(a.value, b.value))
    numberequal(a::Integer_, b::Integer_) = lisptf(a.value == b.value)
    Base.string(x::Integer_) = string(x.value)
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
    struct Eq <: Func end
    struct Add <: Func end
    struct Sub <: Func end
    struct Mul <: Func end
    struct Div <: Func end
    struct Ge <: Func end
    struct Le <: Func end
    struct Gt <: Func end
    struct Lt <: Func end
    struct NumberEqual <: Func end
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

    function funcall(fn::Eq, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        if arg1 == arg2
            return JLLisp.Symbols.symbolT
        else
            return JLLisp.Cons_.Cons(arg1, arg2)
        end
    end

    function funcall(fn::Add, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.add(arg1, arg2)
    end

    function funcall(fn::Sub, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.sub(arg1, arg2)
    end

    function funcall(fn::Mul, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.mul(arg1, arg2)
    end

    function funcall(fn::Div, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.div(arg1, arg2)
    end

    function funcall(fn::Ge, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.ge(arg1, arg2)
    end

    function funcall(fn::Le, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.le(arg1, arg2)
    end

    function funcall(fn::Gt, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.gt(arg1, arg2)
    end

    function funcall(fn::Lt, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.lt(arg1, arg2)
    end

    function funcall(fn::NumberEqual, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval(arguments.car)
        arg2 = JLLisp.Eval.eval(arguments.cdr.car)
        return JLLisp.Integer__.numberequal(arg1, arg2)
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
        regist("EQ", Eq())
        regist("+", Add())
        regist("-", Sub())
        regist("*", Mul())
        regist("/", Div())
        regist(">=", Ge())
        regist("<=", Le())
        regist(">", Gt())
        regist("<", Lt())
        regist("=", NumberEqual())
        regist("DEFUN", Defun())
        regist("SYMBOL-FUNCTION", SymbolFunction())
    end
    registSystemFunctions()
end # Function_

module Reader
    using ..JLLisp
    const charbuffersize = 256
    charbuff = Vector{Char}()
    ch = ' '
    line = ""
    indexofline = 1
    linelength = 0

    function read(;ex = "")
        if isempty(ex)
            global line = readline()
        else # For test
            global line = ex
        end
        prepare()
        return getSexp()
    end

    function prepare()
        global indexofline = 1
        global linelength = length(line)
        global charbuff = Vector{Char}(line)
        push!(charbuff, '\0')
        getchar()
    end

    function getchar()
        global ch = charbuff[indexofline]
        global indexofline += 1
    end

    function skipspace()
        while isspace(ch)
            getchar()
        end
    end

    function getSexp()
        while true
            skipspace()
            ch == '('   &&  return makelist()
            ch == '\''  &&  return makequote()
            ch == '-'   &&  return makeminusnumber()
            isdigit(ch) &&  return makenumber()
            return makesymbol()
        end
    end

    function makelist()
        getchar()
        skipspace()
        if ch == ')'
            getchar()
            return JLLisp.Null()
        end
        top = JLLisp.Cons_.Cons()
        list = top
        while true
            list.car = getSexp()
            skipspace()
            indexofline > linelength && JLLisp.Null() # 不等号要注意
            ch == ')' && break
            if ch == '.'
                getchar()
                list.cdr = getSexp()
                skipspace()
                getchar()
                return top
            end
            list.cdr = JLLisp.Cons_.Cons()
            list = list.cdr
        end
        getchar()
        return top
    end

    function makequote()
        top = JLLisp.Cons_.Cons()
        list = top
        list.car = JLLisp.Symbols.symbol_("QUOTE")
        list.cdr = JLLisp.Cons_.Cons()
        list = list.cdr
        getchar()
        list.car = getSexp()
        return top
    end

    function makeminusnumber()
        nch = charbuff[indexofline]
        isdigit(nch) || return makesymbolinternal(Char[ch])
        return makenumber()
    end

    function makenumber()
        str = Vector{Char}()
        if ch == '-'
            push!(str, ch)
            getchar()
        end
        while indexofline <= linelength + 1
            ch == '(' || ch == ')' && break
            isspace(ch) && break
            if !isdigit(ch)
                global indexofline -= 1
                return makesymbolinternal(str)
            end
            push!(str, ch)
            getchar()
        end
        value = parse(Int, String(str))
        return JLLisp.Integer__.Integer_(value)
    end

    function makesymbol()
        global ch = uppercase(ch)
        str = Char[ch]
        return makesymbolinternal(str)
    end

    function makesymbolinternal(str::Vector{Char})
        while indexofline < linelength + 1
            getchar()
            ch in ('(', ')') && break
            isspace(ch) && break
            global ch = uppercase(ch)
            push!(str, ch)
        end
        symstr = String(str)

        symstr == "NIL" && return JLLisp.Null()
        return JLLisp.Symbols.symbol_(symstr)
    end
end # Reader

module TopLevel
    export repl
    using ..JLLisp
    function repl()
        println("Welcome to JLLisp! (2019-8-11)")
        println("> Copyright (C) goropikari 2019.")
        println("> Type quit and hit Enter for leaving JLLisp.")
        JLLisp.Function_.registSystemFunctions()
        while true
            try
                print("> ")
                sexp = JLLisp.Reader.read()
                sexp == JLLisp.Symbols.symbolQuit && break
                ret = JLLisp.Eval.eval_(sexp)
                println(string(ret))
            catch e
                println(typeof(e))
                break
            end
        end
        println("Bye!")
    end
end

using .TopLevel
export repl

end # JLLisp module
