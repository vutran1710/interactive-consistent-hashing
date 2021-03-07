# Interactive Consistent Hashing
banner placed

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
# docker build -t ich .
```

2. Run the bastard! Don't forget to expose websocket port, if you want to enjoy the app visually
```shell
$ docker run -ti -p 8081:8081 ich
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
`src/consistent_hashing.jl` provide a simple command-line-interface

```shell
================ ClientCLI ===================
----------------------------------------------
/new
  #doc Re-construct a new System
  #args DataType[Integer, Integer, Integer]

/add
  #doc Add a number of records to Store
  #args Integer

/get
  #doc Get a single record by its ID
  #args Integer

/help
  #showing this dialog

/exit
  #no description needed
==============================================
# waiting for user to type in command and arguments
command /

```
