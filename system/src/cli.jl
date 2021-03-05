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


function get_args_signatures(func)
    func_info = collect(methods(func))
    m = func_info[1]
    parameters = map(r -> r, m.sig.parameters)

    if length(parameters) > 1
        map(p -> p, parameters[2:end])
    else
        nothing
    end
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
      #showing this dialog

    /exit
      #no description needed
    ==============================================
    """
end


function arg_converter(type, arg)
    if type == nothing
        return nothing
    end

    if type == Integer
        return parse(Int64, arg)
    end

    if type == String
        return String(arg)
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
            func, type = handler
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
            return println("")
        end

        if cmd == "help"
            return println(welcome)
        end

        if cmd == "exit"
            return "EXIT"
        end

        if !haskey(cmd_dict, cmd)
            return println("Command does not exist")
        end

        println("~~~~~~~~~~~~~~~ BEGIN")
        handler = cmd_dict[cmd]
        func, type = handler["func"], handler["type"]

        if !(type isa Array)
            type = [type]
        end

        args = map(r -> arg_converter(r...), zip(type, args))
        result = func(args...)

        @info result
        println("~~~~~~~~~~~~~~~ END")
        return result
    end

    # insert_blank_lines = _ -> print("\n")
    # run_forever(handle; after_cb=insert_blank_lines)
    return handle
end
