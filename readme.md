# Interactive Consistent Hashing
banner placed

## Project Status
**UNDER ACTIVE DEVELOPMENT**

## Prelude
- How/Why/When/What?

## Introdution
- design goal
- overall design
- technical breakdown

## Running
### System/Backend
Written in **Julia**

#### Option 1: using Docker
If you do not wish to install/use **julia**, you can run the app within Docker by following:

1. Dockerizing the App, tag the image with some name, eg: `ich` (which stands for *Iteractive-Consistent-Hashing*)
```shell
$ docker build -t ich .
```

2. Run the bastard! Don't forget to expose websocket port, if you want to enjoy the app visually
```shell
$ docker run -ti -p 4444:4444 -p 8081:8081 ich:latest
```


#### Option 2: running locally using Julia
- Installing dependencies
```shell
$ julia --project=.
# in julia interactive env
pkg> dev --local
```


- Running
```shell
$ julia --project=. src/consistent_hashing.jl
```


### Usage
System App provides a simple command-line-interface

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
