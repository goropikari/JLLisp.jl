using JLLisp
using Test

@testset "JLLisp.jl" begin
    # Write your own tests here.
    x = JLLisp.Integer__.Integer_(1)
    y = JLLisp.Integer__.Integer_(2)
    @test JLLisp.Integer__.add(x,y) == JLLisp.Integer__.Integer_(3)

    @test isa(x, JLLisp.Atom)
    @test x == JLLisp.Eval.eval_(x) # Atom
    @test isa(JLLisp.Null(), JLLisp.Null)
    @test JLLisp.Eval.eval_(JLLisp.Null()) == JLLisp.Null() # Null

    z = JLLisp.Cons_.Cons(x, JLLisp.Cons_.Cons(y, JLLisp.Null()))
    @test JLLisp.Integer__.Integer_(3) == JLLisp.Function_.funcall(JLLisp.Function_.Add(), z)

    form = JLLisp.Cons_.Cons()
    form.car = JLLisp.Symbols.symboltable["+"]
    form.cdr = JLLisp.Cons_.Cons(x, JLLisp.Cons_.Cons(y, JLLisp.Null()))
    @test JLLisp.Eval.eval_(form) == JLLisp.Integer__.Integer_(3)
end
