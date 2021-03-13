FROM julia:latest
RUN apt update && apt install lighttpd -y
COPY lighttpd.conf /etc/lighttpd
COPY webapp/dist/ /var/www
COPY system/ /app
WORKDIR /app
RUN julia -e "using Pkg;Pkg.activate(\".\");Pkg.instantiate();"
EXPOSE 4444
EXPOSE 8081
ENTRYPOINT service lighttpd start && julia --project=. src/consistent_hashing.jl
