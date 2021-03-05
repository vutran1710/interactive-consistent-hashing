# Type Aliases ==========================================
Angle = Float64
ServerID = String
RecordID = Integer

# Constants & Enum ======================================
@enum Message SUCCESS=1 NOT_FOUND SYSTEM_ERROR USER_ERROR
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
end

struct ResponseMessage
    data::Any
    message::Message
end

struct SocketMessage
    sender::Sender
    payload::Union{Dict, Array}
end

struct TheSystem
    api__get_record::Any
    api__add_records::Any
    inspect__cache_data::Any
    db::Database
    table::Table
end
