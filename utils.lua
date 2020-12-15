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
local utils = {}

function utils.conditional(condition, on_true, on_false)
    -- A prettier way to write `if X then Y else Z end`
    -- The "ternary operator" (X and Y or Z) doesn't work if Y is false
    if condition then
        return on_true
    end
    return on_false
end

function utils.on_any_entity_created(fn, filters)
    -- Register a callback when an entity is created in any way. `fn` should take the LuaEntity object as a single argument.
    script.on_event(
        defines.events.on_built_entity,
        function(event) fn(event.created_entity) end,
        filters
    )
    script.on_event(
        defines.events.on_robot_built_entity,
        function(event) fn(event.created_entity) end,
        filters
    )

    script.on_event(
        defines.events.script_raised_built,
        function(event) fn(event.entity) end,
        filters
    )
    script.on_event(
        defines.events.script_raised_revive,
        function(event) fn(event.entity) end,
        filters
    )

    script.on_event(
        defines.events.on_entity_cloned,
        function(event) fn(event.destination) end,
        filters
    )
end

return utils
