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

local flib = require("__flib__.data-util")


-- Train spawner stop
local train_spawner_stop = flib.copy_prototype(data.raw["recipe"]["train-stop"], "train-spawner-stop")
train_spawner_stop.result = 'train-spawner-stop'
train_spawner_stop.ingredients = {}
train_spawner_stop.enabled = true


-- Train void stop
local train_void_stop = flib.copy_prototype(data.raw["recipe"]["train-stop"], "train-void-stop")
train_void_stop.result = 'train-void-stop'
train_void_stop.ingredients = {}
train_void_stop.enabled = true


-- Train meter stop
local train_meter_stop = flib.copy_prototype(data.raw["recipe"]["train-stop"], "train-meter-stop")
train_meter_stop.result = 'train-meter-stop'
train_meter_stop.ingredients = {}
train_meter_stop.enabled = true


data:extend{train_spawner_stop, train_void_stop, train_meter_stop}