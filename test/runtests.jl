using JLLisp
using Test
eval_(x) = JLLisp.Eval.eval_(x)
read_ = JLLisp.Reader.read
T = JLLisp.Symbols.symbolT
Nil = JLLisp.Nil

@testset "JLLisp.jl" begin
    # Write your own tests here.
    @test Nil == JLLisp.Null()
    @test string(T) == "T"
    @test string(Nil) == "NIL"
    x = JLLisp.Integer__.Integer_(1)
    y = JLLisp.Integer__.Integer_(2)
    @test JLLisp.Integer__.add(x,y) == JLLisp.Integer__.Integer_(3)

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
    @test eval_(read_(ex = "(<= 1 1)")) == T
    @test eval_(read_(ex = "(<= -3 2)")) == T
    @test eval_(read_(ex = "(>= 1 1)")) == T
    @test eval_(read_(ex = "(>= -3 2)")) == JLLisp.Nil
    @test eval_(read_(ex = "(< 1 1)")) == JLLisp.Nil
    @test eval_(read_(ex = "(< -3 2)")) == T
    @test eval_(read_(ex = "(= 1 1)")) == T
    @test eval_(read_(ex = "(= -3 2)")) == JLLisp.Nil
end
