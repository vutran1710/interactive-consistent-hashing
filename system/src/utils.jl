function run_forever(exec; before_cb=nothing, after_cb=nothing, delay::Int=0)
    while true
        if before_cb != nothing
            before_cb()
        end

        result = exec()

        if result == "EXIT"
            println("exiting...")
            sleep(0.5)
            break
        end

        if after_cb != nothing
            after_cb(result)
        end

        sleep(delay)
    end
end

function serialize(r::ResponseMessage)::String
    JSON.json(Dict(:sender => SERVER, :data => r.data, :type => r.action))
end
