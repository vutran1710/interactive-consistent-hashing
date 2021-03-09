cli_loop(instruction::String, handler::Function) = begin
    println(instruction)
    while true
        handler(readline())
    end
end

cli_handler(cmd_map::Dict{String, CLICommand})::Function = begin
    conversion(tuple) = begin
        type, val = tuple
        if type == String
            return val
        end
        if type == Integer
            return parse(Int64, val)
        end
    end

    __process_user_input(input::String) = begin
        input = string.(split(input))

        if length(input) < 2
            @warn "Not enough arguments"
            return nothing
        end

        cmd, args = input[begin], input[2:end]

        if !haskey(cmd_map, cmd)
            @warn "Invalid commands"
            return nothing
        end

        cmd = cmd_map[cmd]

        if length(args) < length(cmd.argument_types)
            @error "Argument lenght not mached"
            return nothing
        end

        try
            pairing = zip(cmd.argument_types, args)
            args = conversion.(pairing)
            return cmd.exec(args...)
        catch e
            println("Cannot process input")
            @error e
            return nothing
        end
    end

    __process_user_input
end
