FROM julia:latest
COPY . /app
WORKDIR /app
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate();Pkg.precompile();"
ENTRYPOINT julia --project=. src/consistent_hashing.jl
