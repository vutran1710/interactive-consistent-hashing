FROM julia:latest
COPY . /app
WORKDIR /app
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate();Pkg.precompile();"
EXPOSE 8081
ENTRYPOINT julia --project=. src/consistent_hashing.jl
