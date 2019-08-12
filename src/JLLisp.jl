module JLLisp
export T, Atom, Number_, List, Null, Nil

abstract type T end
abstract type Atom <: T end
abstract type Number_ <: Atom end
abstract type List <: T end
struct Null <: List end
const Nil = Null()
Base.string(x::Null) = "NIL"

module Cons_
    import ..JLLisp
    mutable struct Cons <: JLLisp.List
        car::JLLisp.T
        cdr::JLLisp.T
    end

    function Cons()
        Cons(JLLisp.Null(), JLLisp.Null())
    end

    function Base.string(cons::Cons)
        str = ""
        list = cons
        str *= "("
        while true
            str *= string(list.car)
            if list.cdr == JLLisp.Nil
                str *= ")"
                break
            elseif isa(list.cdr, JLLisp.Atom)
                str *= " . " * string(list.cdr) * ")"
                break
            else
                str *= " "
                list = list.cdr
            end
        end
        return str
    end
end # Cons_

module Eval
    import ..JLLisp
    const maxstacksize = 65536
    const stack = Vector{JLLisp.T}(undef, maxstacksize)
    stackP = 1

    function eval_(form::JLLisp.T)
        if isa(form, JLLisp.Symbols.Symbol_)
            try
                global symbolvalue = form.value
            catch
                error("Unbound Variable Error: $(form)")
            end
            return symbolvalue
        end

        if isa(form, JLLisp.Null) return form end
        if isa(form, JLLisp.Atom) return form end
        car = form.car
        isa(car, JLLisp.Symbols.Symbol_) || error("Not a Symbol: $(car)")
        try
            global fun = car.fn
        catch
            error("Undefined Function Error: $(car)")
        end

        # system functions
        if isa(fun, JLLisp.Function_.Func)
            argumentlist = form.cdr
            return JLLisp.Function_.funcall(fun, argumentlist)
        end

        # evaluate S expression
        if isa(fun, JLLisp.Cons_.Cons)
            cdr = fun.cdr
            lambdalist = cdr.car
            body = cdr.cdr
            lambdalist == JLLisp.Null() && return evalbody(body)

            return bindevalbody(lambdalist, body, form.cdr)
        end
        error("Not a Function: $(fun)")
    end

    # bindevalbody を実装
    function bindevalbody(lambda::JLLisp.Cons_.Cons, body::JLLisp.Cons_.Cons, form::JLLisp.Cons_.Cons)
        oldstackP = stackP
        while true
            ret = eval_(form.car)
            global stack[stackP] = ret
            global stackP += 1
            form.cdr == JLLisp.Nil && break
            form = form.cdr
        end

        arglist = lambda
        sp = oldstackP
        while true
            sym = arglist.car
            sym.value, stack[sp] = stack[sp], sym.value
            sp += 1
            arglist.cdr == JLLisp.Nil && break
            arglist = arglist.cdr
        end

        ret = evalbody(body)

        arglist = lambda
        global stackP = oldstackP
        while true
            sym= arglist.car
            sym.value = stack[oldstackP]
            oldstackP += 1
            arglist.cdr == JLLisp.Nil && break
            arglist = arglist.cdr
        end

        return ret
    end

    # bindbody
    function evalbody(body::JLLisp.Cons_.Cons)
        while true
            body.cdr == JLLisp.Nil && return JLLisp.Eval.eval_(body.car)
            body = body.cdr
        end
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
            x.value = JLLisp.Nil
            x.fn = JLLisp.Nil
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
    struct Quote <: Func end
    struct Setq <: Func end
    struct Defun <: Func end
    struct If <: Func end
    struct TypeOf <: Func end
    struct SymbolFunction <: Func end

    function funcall(fn::Car, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        return arg1 == JLLisp.Null() ? JLLisp.Null() : arg1.car
    end

    function funcall(fn::Cdr, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        return arg1 == JLLisp.Null() ? JLLisp.Null() : arg1.cdr
    end

    function funcall(fn::FunCons, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Cons_.Cons(arg1, arg2)
    end

    function funcall(fn::Eq, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        if arg1 == arg2
            return JLLisp.Symbols.symbolT
        else
            return JLLisp.Nil
        end
    end

    function funcall(fn::Add, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.add(arg1, arg2)
    end

    function funcall(fn::Sub, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.sub(arg1, arg2)
    end

    function funcall(fn::Mul, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.mul(arg1, arg2)
    end

    function funcall(fn::Div, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.div(arg1, arg2)
    end

    function funcall(fn::Ge, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.ge(arg1, arg2)
    end

    function funcall(fn::Le, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.le(arg1, arg2)
    end

    function funcall(fn::Gt, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.gt(arg1, arg2)
    end

    function funcall(fn::Lt, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.lt(arg1, arg2)
    end

    function funcall(fn::NumberEqual, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        return JLLisp.Integer__.numberequal(arg1, arg2)
    end

    function funcall(fn::Quote, arguments::JLLisp.List)
        return arguments.car
    end

    function funcall(fn::Setq, arguments::JLLisp.List)
        arg1 = arguments.car
        arg2 = JLLisp.Eval.eval_(arguments.cdr.car)
        sym = arg1
        value = JLLisp.Eval.eval_(arg2)
        sym.value = value
        return value
    end

    function funcall(fn::Defun, arguments::JLLisp.List)
        arg1 = arguments.car
        args = arguments.cdr
        fun = arg1
        lambda = JLLisp.Cons_.Cons()
        lambda.car = JLLisp.Symbols.symbol_("LAMBDA")
        lambda.cdr = args
        fun.fn = lambda
        return fun
    end

    function funcall(fn::If, arguments::JLLisp.List)
        arg1 = arguments.car
        args = arguments.cdr
        arg2 = args.car
        arg3 = args.cdr == JLLisp.Nil ? JLLisp.Nil : args.cdr.car
        if JLLisp.Eval.eval_(arg1) != JLLisp.Nil
            return JLLisp.Eval.eval_(arg2)
        else
            return JLLisp.Eval.eval_(arg3)
        end
    end

    function funcall(fn::TypeOf, arguments::JLLisp.List)
        arg1 = JLLisp.Eval.eval_(arguments.car)
        type = typeof(arg1).name |> string |> uppercase
        return JLLisp.Symbols.symbol_(type)
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
        regist("QUOTE", Quote())
        regist("SETQ", Setq())
        regist("DEFUN", Defun())
        regist("IF", If())
        regist("TYPE-OF", TypeOf())
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
                @async if eof(stdin) # exit when Ctrl-d is typed
                    println("\nBye!")
                    exit(0)
                end
                ret = JLLisp.Eval.eval_(sexp)
                println(string(ret))
            catch e
                println(typeof(e))
            end
        end
        println("Bye!")
    end
end

using .TopLevel
export repl

end # JLLisp module
