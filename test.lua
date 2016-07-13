package.path = package.path .. ";./map/?.lua"

counter = 0
local dump = require("print_r")
local aoi = require "aoi"
function test16( ... )
    local bbox = {
        left = 0,
        bottom = 0,
        right = 960,
        top = 640,
    }
    local radius = 100
    aoi.init (bbox, radius)
    print("--- total num:", counter)

    local actor1 = {
        id = 1,
        pos = { x = 500, y = 500, z = 0},
    }
    local actor2 = {
        id = 2,
        pos = { x = 450, y = 450, z = 0},
    }
    local actor3 = {
        id = 3,
        pos = { x = 390, y = 390, z = 0},
    }
    local ok, list = aoi.insert(actor1.id, actor1.pos)
    -- if ok thenTabNum
    --     dump(list)
    -- end

    local ok2, list2 = aoi.insert(actor2.id, actor2.pos)
    -- if ok2 then
    --     dump(list2)
    -- end

    local ok3, list3 = aoi.insert(actor3.id, actor3.pos)

    -- local ok4, list4 = aoi.remove(actor2.id)
    -- if ok4 then
    --     dump(list4, "remove")
    -- end

    actor1.pos.x = 300
    actor1.pos.y = 300
    local ok5, add, update, remove = aoi.update (actor1.id, actor1.pos)
    if ok5 then
        dump(add, "add")
        dump(update, "update")
        dump(remove, "remove")
    end
end

test16()
