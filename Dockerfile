FROM julia:1.1.1

COPY . /app

CMD ["julia", "--project=/app", "-e", "using JLLisp; repl()"]
