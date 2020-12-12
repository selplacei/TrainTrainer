local function get_next_carriage_position(back_rail)
    -- TODO
end

local function clone_train(source_stop, destination_stop)
    -- Returns the LuaTrain instance if successful, nil otherwise
    local source_train = source_stop.get_stopped_train()
    if source_train == nil then
        return
    end
    local destination_rail = destination_stop.connected_rail
    if destination_rail == nil or destination_rail.trains_in_block > 0 then
        return
    end
    local destination_train = source_train.front_stock.clone{position=get_next_carriage_position(destination_rail)}.train
    for i, carriage in ipairs(source_train.carriages) do
        if i > 1 then
            carriage.clone{position=get_next_carriage_position(destination_train.back_rail)}
        end
    end
    return destination_train
end


script.on_event(
    defines.events.on_built_entity,
    function(event)
        local source_stop = event.created_entity.surface.get_train_stops{name="TT_SOURCE"}[1]
        if source_stop == nil then
            game.print("No source stop! It should be named 'TT_SOURCE'.")
        else
            clone_train(source_stop, event.created_entity)
        end
    end,
    {{filter="name", name="train-spawner-stop"}}
)
