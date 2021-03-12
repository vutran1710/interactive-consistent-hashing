using Faker: first_name, last_name


row_to_record(r::Row) = Record(r.id, r.name)


create_records(;start::Integer=1, stop::Integer=1000)::Array{Record} = begin
    data = [(i, "$(first_name()) $(last_name())") for i=start:stop]
    (t -> Record(t...)).(data)
end


create_table(rc::Array{Record})::Table = begin
    ids = getproperty(:id).(rc)
    names = getproperty(:name).(rc)
    Table(id=ids, name=names)
end


insert_records(table::Table, number_of_records::Integer)::Integer = begin
    start = length(table) + 1
    stop = start + number_of_records - 1
    new_records = create_records(start=start, stop=stop)
    for r in new_records
        push!(table.id, r.id)
        push!(table.name, r.name)
    end
    length(table)
end


select_single(table::Table, id::RecordID)::Union{Record, Nothing} = begin
    find = row_to_record.(table[table.id .== id])
    !isempty(find) ? find[1] : nothing
end


select_many(table::Table, predicate)::Array{Record} = begin
    row_to_record.(filter(predicate, table))
end



"""
Initialize a database with given number of records
"""
db_init(record_number::Integer)::Database = begin
    tbl = create_records(start=1, stop=record_number) |> create_table

    __insert_records(count::Integer) = insert_records(tbl, count)
    __select_single(id::RecordID) = select_single(tbl, id)
    __select_many(predicate) = select_many(tbl, predicate)
    __count() = length(tbl)

    Database(tbl, __select_single, __select_many, __insert_records, __count)
end
