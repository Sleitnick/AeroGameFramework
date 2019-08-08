function MyController:Start()
	local fade = self.Controllers.Fade
	fade:SetText("Fade Example")
	fade:Out()
	wait(1)
	fade:In()
end