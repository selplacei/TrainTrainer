--[[
   Copyright 2020 Illia B. (selplacei)

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]

local flib_misc = require("__flib__.misc")
local utils = require("utils")

local spawn_on_ticks = nil

local function get_next_rail(rail, direction)
    for _, conn_direction in pairs{
        defines.rail_connection_direction.straight,
        defines.rail_connection_direction.left,
        defines.rail_connection_direction.right
    } do
        local next_rail = rail.get_connected_rail{rail_direction=direction, rail_connection_direction=conn_direction}
        if next_rail then
            return next_rail
        end
    end
end

local function get_next_carriage_position(train, direction)
    -- Returns a Position if the input is valid, nil otherwise
    -- Prints a message explaining why the input isn't valid if it is; this will be removed in the future.
    -- The Factorio API provides neither a way to create a carriage and automatically
    -- connect it to a train, nor a way to consistently traverse rails.
    -- This is the only other working mechanism that I could come up with.
    if train == nil or not train.valid then
        game.print("Train is invalid.")
        return
    end
    local last_carriage = utils.conditional(
        direction == defines.rail_direction.front,
        train.front_stock,
        train.back_stock
    )
    local next_rail = get_next_rail(
        utils.conditional(
            direction == defines.rail_direction.front,
            train.front_rail,
            train.back_rail
        ),
        utils.conditional(
            direction == defines.rail_direction.front,
            train.rail_direction_from_front_rail,
            utils.conditional(
                train.rail_direction_from_back_rail == defines.rail_direction.front,
                defines.rail_direction.back,
                defines.rail_direction.front
            )
        )
    )
    if next_rail == nil then
        game.print("Next rail is nil.")
        return
    end
    local theta = (1 - last_carriage.orientation + 0.25) * 2 * math.pi
    local offset_A = {x=math.cos(theta) * 6.5, y=math.sin(theta) * -6.5}
    local offset_B = {x=-offset_A.x, y=-offset_A.y}
    local position_A = {x=last_carriage.position.x + offset_A.x, y=last_carriage.position.y + offset_A.y}
    local position_B = {x=last_carriage.position.x + offset_B.x, y=last_carriage.position.y + offset_B.y}
    if flib_misc.get_distance(next_rail.position, position_A) < flib_misc.get_distance(next_rail.position, position_B) then
        return position_A
    end
    return position_B
end

local function get_first_carriage_position(stop)
    local direction_to_offset = {}
    direction_to_offset[defines.direction.north] = {-2, 3}
    direction_to_offset[defines.direction.south] = {2, -3}
    direction_to_offset[defines.direction.east] = {-3, -2}
    direction_to_offset[defines.direction.west] = {3, 2}
    local offset = direction_to_offset[stop.direction]
    return {x=stop.position.x + offset[1], y=stop.position.y + offset[2]}
end

local function orientation_to_cardinal_direction(orientation)
    local values = {
        [0]=defines.direction.north,
        defines.direction.east,
        defines.direction.south,
        defines.direction.west
    }
    return values[math.floor((orientation * 4) + 0.5)]
end

local function clone_train(source_stop, destination_stop)
    -- Returns the LuaTrain instance if successful, nil otherwise
    local source_first_carriage_position = get_first_carriage_position(source_stop)
    local source_carriages = source_stop.surface.find_entities_filtered{
        type={
            "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"
        },
        area={
            {x=source_first_carriage_position.x - 2, y=source_first_carriage_position.y - 2},
            {x=source_first_carriage_position.x + 2, y=source_first_carriage_position.y + 2}
        }
    }
    if source_carriages == nil or #source_carriages == 0 then
        return
    end
    local source_train = source_carriages[1].train
    local destination_rail = destination_stop.connected_rail
    if destination_rail == nil or destination_rail.trains_in_block > 0 then
        return
    end
    local source_train_is_reversed = (
        flib_misc.get_distance(source_stop.position, source_train.front_stock.position)
        > flib_misc.get_distance(source_stop.position, source_train.back_stock.position)
    )
    local growth_direction = utils.conditional(
        source_train_is_reversed,
        defines.rail_direction.front,
        defines.rail_direction.back
    )
    local first_carriage = utils.conditional(
        source_train_is_reversed,
        source_train.back_stock,
        source_train.front_stock
    ).clone{
        position=get_first_carriage_position(destination_stop)
    }
    if orientation_to_cardinal_direction(first_carriage.orientation) ~= destination_stop.direction then
        first_carriage.rotate()
    end
    local destination_train = first_carriage.train
    for i, carriage in ipairs(source_train.carriages) do
        if i > 1 then
            -- TODO: instead of taking an arbitrary direction in case of a split, perform a search on possible paths and pick one that's long enough
            local new_position = get_next_carriage_position(destination_train, growth_direction)
            if new_position == nil then
                return
            end
            local new_carriage = carriage.clone{position=new_position}
            -- TODO: test if locomotive direction is always preserved
            if new_carriage == nil then
                game.print({"", "Failed to spawn all carriages for train spawner stop ", destination_stop.backer_name})
                game.print({"", "Attempted to spawn at ", new_position})
                game.print({"", "Front rail: ", destination_train.front_rail.position, "; back rail: ", destination_train.back_rail.position})
                return
            end
            destination_train = new_carriage.train
        end
    end
    return destination_train
end

local register_spawn_tick

local function trigger_spawner(stop)
    if not stop or not stop.valid then return end
    local source_stop = stop.surface.get_train_stops{name="TT_SOURCE"}[1]
    if source_stop then
        local train = clone_train(source_stop, stop)
        if train then
            train.go_to_station(1)
        end
    end
    register_spawn_tick(game.tick + 200, stop)
end

register_spawn_tick = function(tick, stop)
    if spawn_on_ticks[tick] == nil then
        spawn_on_ticks[tick] = {function() trigger_spawner(stop) end}
    else
        table.insert(spawn_on_ticks[tick], function() trigger_spawner(stop) end)
    end
end

script.on_init(
    function()
        global.spawn_on_ticks = {}
    end
)

script.on_load(
    function()
        spawn_on_ticks = global.spawn_on_ticks
    end
)

script.on_event(
    defines.events.on_tick,
    function(event)
        local tick = event.tick
        if spawn_on_ticks[tick] ~= nil then
            for _, f in pairs(spawn_on_ticks[tick]) do
                f()
            end
            spawn_on_ticks[tick] = nil
        end
    end
)

utils.on_any_entity_created(
    trigger_spawner,
    {{filter="name", name="train-spawner-stop"}}
)
