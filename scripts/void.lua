script.on_event(
    defines.events.on_train_changed_state,
    function(event)
        local stop = event.train.station
        if stop and stop.name == "train-void-stop" then
            for _, carriage in pairs(event.train.carriages) do
                carriage.destroy()
            end
        end
    end
)