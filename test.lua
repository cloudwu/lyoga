local layout = require "layout"
local _, datalist = pcall(require, "datalist")

local doc

if _ then
	print "Use Datalist"
	local src = [=[
node :
	width : 500
	height : 500
	direction : row
	justify : center
	alignItems : center
	margin : 25
	gap : 20
	node :
		id : 1
		width : 100
		height : 100
	node :
		id : 2
		width : 100
		height : 100
]=]
	doc = layout.load(datalist.parse_list(src))
else
	print "Use lua table"
	doc = layout.load {
	"node", {
		"width" , 500,
		"height" , 500,
		"direction" , "row",
		"justify" , "center",
		"alignItems" , "center",
		"margin" , "25 50 75",
		"gap" , 20,
		"node", {
			"id", 1,
			"width", 100,
			"height", 100,
		},
		"node", {
			"id", 2,
			"width", 100,
			"height", 100,
		},
	},
}
end

layout.calc(doc)

print(layout.position(doc[1]))
print(layout.position(doc[2]))
