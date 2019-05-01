-- Client-exposed 'Echo' method invoking 'Print' method:
function MyService.Client:Echo(player, message)
	self.Server:Print(message) -- Note the reference to 'self.Server'
	return message
end

function MyService:Print(msg)
	return msg
end