local makeEnum = require(script.Parent.Parent.Utilities.General).makeEnum

return makeEnum("NetMode", {
	"Server";
	"NetworkOwnership";
	"Extrapolation";
	"None";
})