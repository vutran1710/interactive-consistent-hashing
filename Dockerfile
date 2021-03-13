FROM julia:latest

RUN apt install lighttpd -y
COPY lighttpd.conf /etc/lighttpd
COPY dist/* /var/www/
RUN service lighttpd start

COPY system/ /app
WORKDIR /app
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate();Pkg.precompile();"


EXPOSE 8081
ENTRYPOINT julia --project=. src/consist
