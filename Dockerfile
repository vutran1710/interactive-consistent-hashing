FROM julia:latest
RUN apt update && apt install lighttpd -y
COPY lighttpd.conf /etc/lighttpd
COPY webapp/dist/ /var/www
COPY system/ /app
WORKDIR /app
RUN COMPILE=1 julia -e "using Pkg;Pkg.activate(\".\");Pkg.instantiate();Pkg.precompile();"
EXPOSE 4444
EXPOSE 8081
ENTRYPOINT service lighttpd start && julia --project=. src/consistent_hashing.jl
