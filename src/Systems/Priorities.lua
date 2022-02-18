local General = require(script.Parent.Parent.Utilities.General)

return General.lockTable("Priorities", {
	RemoteBefore = 0;
	CoreBefore = 10;

	Tools = 20;
	Projectiles = 30;

	Presentation = 80;
	CoreAfter = 90;
	RemoteAfter = 100;
})