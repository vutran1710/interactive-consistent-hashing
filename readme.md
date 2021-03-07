# Interactive Consistent Hashing
banner placed

## Prelude
- How/Why/When/What?

## Introdution
- design goal
- overall design
- technical breakdown

## Running
### Setup
#### System/Backend
Written in **Julia**

##### Running inside Docker
If you do not wish to install/use **julia**, you can run the app within Docker doing the following steps:
1. Dockerizing the App
- Tag the image with some name, eg: `ich` (which stands for *Iteractive-Consistent-Hashing*)
```shell
# docker build -t ich .
```

- Run the bastard! Don't forget to expose websocket port, if you want to enjoy the app visually
```shell
$ docker run -ti -p 8081:8081 ich
```


##### Running locally using Julia
- Installing dependencies
```shell
$ julia --project=.
# in julia interactive env
pkg> dev --local
```


- Testing
```shell
$ julia --project=. test/runtests.jl
```


- Usage
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
