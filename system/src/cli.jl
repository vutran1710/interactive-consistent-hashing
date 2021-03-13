cli_command(name::String, func::Function)::CLICommand = begin
    info = methods(func)
    params = info.ms[1].sig.parameters
    args = length(params) > 1 ? collect(params[2:end]) : []
    CLICommand(name, func, args)
end


cli_loop(instruction::String, handler::Function)::Nothing = begin
    println(instruction)
    while true
        prompt = "command /"
        print(prompt)
        handler(readline())
    end
end


cli_handler(cmds::Array{CLICommand})::Function = begin
    cmd_map = Dict((c.name => c) for c=cmds)

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

        if isempty(input)
            return nothing
        end

        cmd, args = input[begin], nothing

        if !haskey(cmd_map, cmd)
            @warn "Invalid commands"
            return nothing
        end

        cmd = cmd_map[cmd]

        if isempty(cmd.argument_types)
            return cmd.exec()
        end

        if length(input) < length(cmd.argument_types) + 1
            @error "Argument lenght not mached"
            return nothing
        end

        args = input[2:end]

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
