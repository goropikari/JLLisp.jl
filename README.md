# JLLisp

[![Build Status](https://travis-ci.org/goropikari/JLLisp.jl.svg?branch=master)](https://travis-ci.org/goropikari/JLLisp.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/goropikari/JLLisp.jl?svg=true)](https://ci.appveyor.com/project/goropikari/JLLisp-jl)
[![Codecov](https://codecov.io/gh/goropikari/JLLisp.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/goropikari/JLLisp.jl)

This is a Julia translation of [SDLisp](http://train.gomi.info/lisp/sdlisp.html) by Gomi-san.


- Julia 1.1.1

```julia
using Pkg
Pkg.pkg"add https://github.com/goropikari/JLLisp.jl"
using JLLisp
repl()
```

```lisp
Welcome to JLLisp! (2019-8-11)
> Copyright (C) goropikari 2019.
> Type quit and hit Enter for leaving JLLisp.
> (+ 1 2)
3
> (setq foo 10)
10
> (* foo 2)
20
> (defun f () 100)
F
> (f)
100
> (defun g (x y) (+ x y))
F
> (g 10 1)
11
> (defun fac (n) (if (< n 1) 1 (* n (fac (- n 1)))))
FAC
> (fac 5)
120
> (defun fib (n) (if (< n 2) 1 (+ (fib (- n 1)) (fib (- n 2)))))
FIB
> (fib 5)
8
```
