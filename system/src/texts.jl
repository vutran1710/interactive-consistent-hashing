const WELCOME = """
-------------------- INTERACTIVE-CONSISTENT-HASHING ----------------------
Made by VuTran
@github: vutran1710
@email: me@vutr.io
"""



const INSTRUCTION = """
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

/info
    # View Cache-cluster hash table in the Terminal
    'args: none
    'returns: nothing

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
    # if there is already a failing server, it will be turned on again
    'args: none
    'returns:
        # The updated cache cluster info
        - Array{Tuple{String, Float, ServerID, Boolean}}

/help
    # show this diaglog again
============================== !SHOWTIME! ================================
"""
