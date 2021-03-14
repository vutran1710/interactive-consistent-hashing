# Interactive Consistent Hashing
<p align="center">
  <img src="images/ich.jpeg" width="100%">
</p>

## Introduction
TBD

## Modelling Architecture
<p align="center" style="margin:20px auto;">
  <img src="images/architecture.jpeg" width="80%">
</p>


## Running
#### Option 1: the no-brainer way
Pull from docker hub and run it
```shell
$ docker run -ti -p 4444:4444 -p 8081:8081 vutrio/interactive_consistent_hashing
```
Wait until the pulling and initial setup finished, showing something like this...
```shell
[ ok ] Starting web server: lighttpd.
-------------------- INTERACTIVE-CONSISTENT-HASHING ----------------------
Made by VuTran
@github: vutran1710
@email: me@vutr.io

Initializing a sample app
- 300 records, 3 cache-servers & 3 virtual node each servers
Initializing WS server, binding 0.0.0.0:8081
...
command /
```
Open http://localhost:4444 to see shit!


#### Option 2: building the App manually with Docker
If you do not want to bother installing any crappy dependencies to your precious - pure - and clean system, you can build and run the app with Docker by following:

Clone the app
```shell
$ git clone https://github.com/vutran1710/interactive-consistent-hashing
$ cd <project-dir>
```

Build the App with docker, tag the image with some name, eg: `ich` (which stands for *Iteractive-Consistent-Hashing*)
```shell
$ docker build -t ich .
```

Run the App, exposing the websocket port and web-app server's port
```shell
$ docker run -ti -p 4444:4444 -p 8081:8081 ich:latest
```

A sample modelling app will be initialized with 300 records, 3 cache servers and 3 virtual nodes each servers. After initialization finished, open http://localhost:4444.


#### Option 3: running in development-mode with Julia & NodeJS
- Installing dependencies
```shell
$ julia --project=.
# in julia interactive env
pkg> dev --local
```

- Running the backend App
```shell
$ julia --project=. src/consistent_hashing.jl
```

- Go to `webapp` dir and do the routine work
```shell
# project dir
$ cd webapp/
$ npm install
$ npm start
```
- Go to http://localhost:4444

### Usage
The backend App provides a simple command-line-interface, and the client, when run with default config, will be available at http://localhost:4444

When the client webapp connects to the backend app over web-socket, every change to the system will be forwarded and drawn in the client.

```shell
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/new
	# create/recreate backend-app, with a database and a cache-cluster
	'args:
		- record_number::Integer
		- cache_number::Integer
		- virtual_node_for_each_cache_number::Integer
	'returns:
		# List of node-info, including node-label, angle,
		# server-id and online-status
		- Array{Tuple{String, Float, ServerID, Boolean}}

/get
	# get a single record by record-id
	'args:
		- record_id::Integer
	'returns:
		# Record data if found, and server-id of the cache
		# that is mapped to the hashed record_id
		- Tuple{Union{Record, Nothing}, ServerID}

/add
	# add more records
	'args:
		- record_number::Integer
	'returns:
		# New length of the updated table
		- Integer

/hash
	# find hashing and the mapped server to a given record-id
	'args:
		- id::Integer
	'returns:
		# Return a list of the given-input, the hashed value,
		# and the correspondent server-id
		- Array{id::Integer, hashed::Angle, nearest::Angle, ServerID}

/fail
	# failing a random cache-server from cluster
	'args: none
	'returns:
		# The updated cache cluster info
		- Array{Tuple{String, Float, ServerID, Boolean}}

/help
	# show this diaglog again
============================== !SHOWTIME! ================================
command /
```
