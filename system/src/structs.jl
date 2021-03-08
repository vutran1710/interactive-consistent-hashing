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
    select_single::Any
    select_many::Any
    insert_records::Any
    count::Any
end

struct CacheTable
    tbl::Table
    get::Any
end

struct ResponseMessage
    data::Any
    action::String
    status::Status
end

struct TheSystem
    api__get_record::Any
    api__add_records::Any
    inspect__cache_data::Any
    db::Database
    table::Table
end
