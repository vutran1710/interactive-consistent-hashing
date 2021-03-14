FROM julia:latest

# Webapp
# - install nodejs, npm, lighttpd
RUN apt update
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt install lighttpd nodejs -y

# - copy lighttpd config to container
COPY lighttpd.conf /etc/lighttpd

# - bundling webapp
WORKDIR /webapp
COPY webapp/ .
RUN npm i
# NOTE: dont know why node-sass did not get installed after running `npm i`
RUN npm install --save-dev node-sass
RUN npm run build
RUN mv dist/* /var/www

# System
WORKDIR /ich
COPY system/ .
# NOTE: precompile the project
# there will be weird error happened with Faker during precompiling, ignore it!
RUN COMPILE=1 julia -e "using Pkg;Pkg.activate(\".\");Pkg.instantiate();Pkg.precompile();"

# Expose both webserver & websocket server
EXPOSE 4444
EXPOSE 8081

# running the CLI: start webserver then run the cli app
ENTRYPOINT service lighttpd start && julia --project=. src/consistent_hashing.jl
