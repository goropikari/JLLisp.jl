using JLLisp
using Test
eval_(x) = JLLisp.Eval.eval_(x)
read_ = JLLisp.Reader.read
symT = JLLisp.Symbols.symbolT
Nil = JLLisp.Nil

@testset "JLLisp.jl" begin
    @test Atom <: T
    @test Number_ <: Atom
    @test List <: T
    @test Null <: List
    @test Nil == Null()
    @test string(T) == "T"
    @test string(Nil) == "NIL"
    x = JLLisp.Integer__.Integer_(1)
    y = JLLisp.Integer__.Integer_(2)
    @test JLLisp.Integer__.add(x,y) == JLLisp.Integer__.Integer_(3)
    @test string(x) == "1"

    @test isa(x, JLLisp.Atom)
    @test x == JLLisp.Eval.eval_(x) # Atom
    @test isa(Nil, JLLisp.Null)
    @test JLLisp.Eval.eval_(Nil) == Nil # Null

    z = JLLisp.Cons_.Cons(x, JLLisp.Cons_.Cons(y, Nil))
    @test JLLisp.Integer__.Integer_(3) == JLLisp.Function_.funcall(JLLisp.Function_.Add(), z)

    form = JLLisp.Cons_.Cons()
    form.car = JLLisp.Symbols.symboltable["+"]
    form.cdr = JLLisp.Cons_.Cons(x, JLLisp.Cons_.Cons(y, Nil))
    @test eval_(form) == JLLisp.Integer__.Integer_(3)
    @test eval_(read_(ex = "(+ 1 2)")) == JLLisp.Integer__.Integer_(3)
    @test eval_(read_(ex = "(+ -1 2)")) == JLLisp.Integer__.Integer_(1)
    @test eval_(read_(ex = "(- 1 2)")) == JLLisp.Integer__.Integer_(-1)
    @test eval_(read_(ex = "(- 1 -2)")) == JLLisp.Integer__.Integer_(3)
    @test eval_(read_(ex = "(* 2 3)")) == JLLisp.Integer__.Integer_(6)
    @test eval_(read_(ex = "(* 2 -3)")) == JLLisp.Integer__.Integer_(-6)
    @test eval_(read_(ex = "(/ 1 2)")) == JLLisp.Integer__.Integer_(0)
    @test eval_(read_(ex = "(/ 3 2)")) == JLLisp.Integer__.Integer_(1)
    @test eval_(read_(ex = "(/ -3 2)")) == JLLisp.Integer__.Integer_(-1)
    @test eval_(read_(ex = "(+ (+ 1 2) (+ 3 4))")) == JLLisp.Integer__.Integer_(10)
    @test eval_(read_(ex = "(- (+ -1 2) (- 1 2))")) == JLLisp.Integer__.Integer_(2)
    @test eval_(read_(ex = "(* (+ 1 2) (- 2 4))")) == JLLisp.Integer__.Integer_(-6)
    @test eval_(read_(ex = "(/ (+ 100 -2) (- 4 2))")) == JLLisp.Integer__.Integer_(49)
    @test eval_(read_(ex = "(<= 1 1)")) == symT
    @test eval_(read_(ex = "(<= -3 2)")) == symT
    @test eval_(read_(ex = "(>= 1 1)")) == symT
    @test eval_(read_(ex = "(>= -3 2)")) == JLLisp.Nil
    @test eval_(read_(ex = "(< 1 1)")) == JLLisp.Nil
    @test eval_(read_(ex = "(< -3 2)")) == symT
    @test eval_(read_(ex = "(> 1 1)")) == JLLisp.Nil
    @test eval_(read_(ex = "(> 2 -3)")) == symT
    @test eval_(read_(ex = "(= 1 1)")) == symT
    @test eval_(read_(ex = "(= -3 2)")) == JLLisp.Nil
    @test eval_(read_(ex="(setq hoge 10)")) == JLLisp.Integer__.Integer_(10)
    @test eval_(read_(ex="hoge")) == JLLisp.Integer__.Integer_(10)
    @test eval_(read_(ex="(if (< 10 20) 100 200)")) == JLLisp.Integer__.Integer_(100)
    @test eval_(read_(ex="(if (> 10 20) 100 200)")) == JLLisp.Integer__.Integer_(200)
    @test eval_(read_(ex="(type-of 1)")) == JLLisp.Symbols.symbol_("JLLISP.INTEGER__.INTEGER_")
    eval_(read_(ex = "(defun f () (+ 10 20))"))
    @test eval_(read_(ex = "(f)")) == JLLisp.Integer__.Integer_(30)

    eval_(read_(ex = "(defun g (x) (+ 10 x))"))
    @test eval_(read_(ex = "(g 100)")) == JLLisp.Integer__.Integer_(110)

    eval_(read_(ex = "(defun fac (n) (if (< n 1) 1 (* n (fac (- n 1)))))"))
    @test eval_(read_(ex = "(fac 5)")) == JLLisp.Integer__.Integer_(120)
end
