using JLLisp
using Test

@testset "JLLisp.jl" begin
    # Write your own tests here.
    x = JLLisp.Integer__.Integer_(1)
    y = JLLisp.Integer__.Integer_(2)
    @test JLLisp.Integer__.add(x,y) == JLLisp.Integer__.Integer_(3)
end
