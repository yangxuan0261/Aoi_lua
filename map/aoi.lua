local quadtree = require "quadtree"
local dump = require "print_r"

local aoi = {}

local object = {}
local qtree
local radius

function aoi.init (bbox, r)
    print (string.format ("--- aoi, init, left:%d, bottom:%d, right:%d, top:%d, radius:%d", bbox.left, bbox.bottom, bbox.right, bbox.top, r))

	qtree = quadtree.new (bbox.left, bbox.bottom, bbox.right, bbox.top, nil)
    qtree:genChildren()
	radius = r

    -- dump(qtree, "root")
end

function aoi.insert (id, pos)
	if object[id] then return end

	local tree = qtree:insert (id, pos.x, pos.y)
	if not tree then return end

	local result = {}
	qtree:query (id, pos.x - radius, pos.y - radius, pos.x + radius, pos.y + radius, result)

	local list = {}
	for i = 1, #result do
		local cid = result[i]
		local c = object[cid]
		if c then
			list[cid] = cid
			c.list[id] = id
		end
	end

	object[id] = { id = id, pos = pos, qtree = tree, list = list }

	return true, list
end

function aoi.remove (id)
	local c = object[id]
	if not c then return end

	if c.qtree then
		c.qtree:remove (id)
	else
		qtree:remove (id)
	end

	for _, v in pairs (c.list) do
		local t = object[v]
		if t then
			t.list[id] = nil
		end
	end
	object[id] = nil

	return true, c.list
end

function aoi.update (id, pos)
	local c = object[id]
    -- dump(object)

    print (string.format("agent:%s, x:%d, y:%d, z:%d", id, pos.x, pos.y, pos.z))
	if not c then
        print ("--- not c, id:%d", id)
        return
    end

	if c.qtree then
		c.qtree:remove (id)
	else
		qtree:remove (id)
	end

	local olist = c.list -- 旧列表

	local tree = qtree:insert (id, pos.x, pos.y)
	if not tree then
         print ("--- not tree, id:%d", id)
        return
    end

	c.pos = pos

	local result = {} -- 当前为查询到范围内的对象
	qtree:query (id, pos.x - radius, pos.y - radius, pos.x + radius, pos.y + radius, result)

	local nlist = {} -- 新列表
    for k, v in pairs (result) do
		nlist[v] = v
	end

	local ulist = {} -- 更新列表 = 新旧列表的交集
	for k, v in pairs (nlist) do
		local k = olist[v]
		if k then
			ulist[v] = v
			olist[v] = nil -- 新旧列表删除该元素
            nlist[k] = nil
		end
	end

	c.list = {} -- 新列表
	for _, v in pairs (nlist) do
		c.list[v] = v
	end
	for _, v in pairs (ulist) do
		c.list[v] = v
	end

	return true, nlist, ulist, olist
end

return aoi
