local yoga = require "layout.yoga"

local dom = {}

local document = {}
local element = {}

local function initElement(obj)
	do local _ENV = obj
		_keys = {}
		_list = {}
	end
	return obj
end

function document:__gc()
	local root = self._yoga[self._document]
	self._yoga = nil
	yoga.node_free(root)
end

function dom.calc(doc)
	doc = doc._document
	local root = doc._yoga[doc]
	yoga.node_calc(root)
end

function dom.updateStyle(e, style)
	local doc = e._document
	local obj = doc._yoga[e]
	return yoga.node_set(obj, style)
end

function dom.position(e)
	local doc = e._document
	local obj = doc._yoga[e]
	return yoga.node_get(obj)
end

do
	local function parse_node(v)
		local attr = {}
		local content = {}
		local n = 1
		for i = 1, #v, 2 do
			local name = v[i]
			local value = v[i+1]
			if type(value) == "table" then
				content[n] = name
				content[n+1] = value
				n = n + 2
			else
				attr[name] = value
			end
		end
		if n == 1 then
			content = nil
		end
		return content, attr
	end

	local function add_list(element, list)
		for i = 1, #list, 2 do
			local name = list[i]
			local content, attr = parse_node(list[i+1])
			local e = dom.createElement(element, name, attr)
			if content then
				add_list(e, content)
			end
		end
	end

	function dom.load(list)
		local doc = dom.document()
		add_list(doc, list)
		return doc
	end
end

function dom.document(style)
	local _yoga = {}
	local doc = initElement {
		_id = {},
		_yoga = _yoga,
	}
	local root = yoga.node_new()
	if style then
		yoga.node_set(root, style)
	end
	_yoga[doc] = root
	doc._document = doc
	return setmetatable(doc, document)
end

function dom:createElement(tagname, attr)
	local _yoga = self._document._yoga
	local parent = _yoga[self]
	local yoga_obj = yoga.node_new(parent)
	if attr then
		yoga.node_set(yoga_obj, attr)
	end
	local obj = initElement {}
	_yoga[obj] = yoga_obj
	do local _ENV = obj
		_attr = attr or {}
		_type = tagname
		_document = self._document
		_attr.tagName = tagname
		if _attr.id then
			_document._id[_attr.id] = obj
		end
	end
	local n = #self._list + 1
	self._keys[obj] = n
	self._list[n] = obj
	return setmetatable(obj, element)
end

function dom:getElement(id)
	return self._id[id]
end

local function iterElement(self, prekey)
	local index = self._keys[prekey] or 0
	return self._list[index + 1]
end

function document:__pairs()
	return iterElement, self
end

function document:__tostring()
	return "[document]"
end

function element:__tostring()
	return "<" .. self._type .. ">"
end

function element:__index(key)
	return self._attr[key]
end

do local _ENV = document
	__index = dom.getElement
	__newindex = dom.createElement
end

do local _ENV = element
	__newindex = dom.createElement
	__pairs = document.__pairs
	__call = dom.updateStyle
end

return dom
