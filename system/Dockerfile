FROM julia:latest
COPY . /app
WORKDIR /app
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate();"
ENTRYPOINT julia --project=. src/main.jl
