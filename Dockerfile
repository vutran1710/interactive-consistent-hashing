FROM julia:latest

# Webapp
RUN apt update && apt install lighttpd -y
COPY lighttpd.conf /etc/lighttpd
COPY webapp/dist/ /var/www

# System
COPY system/ /app
WORKDIR /app
RUN COMPILE=1 julia -e "using Pkg;Pkg.activate(\".\");Pkg.instantiate();Pkg.precompile();"

# Expose both webserver & websocket server
EXPOSE 4444
EXPOSE 8081

# running the CLI: start webserver then run the cli app
ENTRYPOINT service lighttpd start && julia --project=. src/consistent_hashing.jl
