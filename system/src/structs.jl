# Type Aliases ==========================================
Angle = Float64
ServerID = String
RecordID = Integer

# Constants & Enum ======================================
@enum Message SUCCESS=1 NOT_FOUND SYSTEM_ERROR


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
end

struct ResponseMessage
    data::Any
    message::Message
end

struct TheSystem
    api__get_record::Any
    api__add_records::Any
    inspect__cache_data::Any
    db::Database
    table::Table
end

struct Point
    x::Float64
    y::Float64
end
