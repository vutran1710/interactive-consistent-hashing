using TypedTables: Table

# Type Aliases ==========================================
Angle = Float64
ServerID = String
RecordID = Integer
Row = NamedTuple

# Constants & Enum ======================================
@enum Status SUCCESS=1 NOT_FOUND SYSTEM_ERROR USER_ERROR
@enum Sender SERVER=1 CLIENT


# Structs representing System parts  ====================
struct Record
    id::RecordID
    name::String
end

struct CacheServer
    id::ServerID
    bucket::Dict{RecordID, Record}
end

struct Database
    table::Table
    select_single::Function
    select_many::Function
    insert_records::Function
    count::Function
end

struct CacheCluster
    table::Table
    get::Function
end

struct App
    get_record::Function
    add_records::Function
    fail_server::Function
end
