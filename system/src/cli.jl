function parse_command(user_input)
    splitted = split(user_input, " ")
    len = length(splitted)

    if len == 0
        return nothing, nothing
    end

    if len == 1
        return splitted[1], nothing
    end

    return splitted[1], splitted[2:end]
end


function cli_render_introduction(cmd_maps)
    combine(r, element) = begin
        cmd, pair = element
        func, doc, type = pair["func"], pair["doc"], pair["type"]

        if type == nothing
            type = "None"
        end

        cmd_line = "/$(cmd) \n"
        doc_line = "  #doc $(doc)\n"
        arg_line = "  #args $(type)\n\n"
        result = r * cmd_line * doc_line * arg_line
        result
    end

    """
    ================ ClientCLI ===================
    ----------------------------------------------
    $(reduce(combine, cmd_maps, init=""))/help
      #showing this dialog again

    /exit
      #no description needed
    ==============================================
    """
end


function arg_converter(type, arg)
    if type == Integer
        return parse(Int64, arg)
    end

    if type == String
        return arg
    end
end


function make_command_dict(args...)
    cmd_dict = Dict()
    docs = []
    for item in args
        if item isa String
            push!(docs, item)
        else
            cmd, handler = item
            func, type = handler[begin], handler[2:end]
            controller = Dict("func" => func, "type" => type, "doc" => popfirst!(docs))
            push!(cmd_dict, cmd => controller)
        end
    end
    cmd_dict
end


function ClientCLI(args...)
    cmd_dict = make_command_dict(args...)
    welcome = cli_render_introduction(cmd_dict)
    println(welcome)

    handle() = begin
        print("command /")
        cmd, args = parse_command(readline())

        if cmd == nothing
            println("")
            return nothing
        end

        if cmd == "help"
            println(welcome)
            return nothing
        end

        if cmd == "exit"
            return "EXIT"
        end

        if !haskey(cmd_dict, cmd)
            println("Unrecognized command")
            return nothing
        end

        println("~~~~~~~~~~~~~~~ BEGIN")
        handler = cmd_dict[cmd]
        func, type, args = handler["func"], handler["type"], nothing

        try
            args = map(r -> arg_converter(r...), zip(type, args))
        catch
            @error "Invalid command arguments"
            return ResponseMessage(nothing, USER_ERROR)
        end

        result = func(args...)
        @info result
        println("~~~~~~~~~~~~~~~ END")
        return result
    end

    return handle
end
