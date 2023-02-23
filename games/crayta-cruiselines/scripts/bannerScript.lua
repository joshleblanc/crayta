local BannerScript = {}

-- Script properties are defined here
BannerScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{ name = "imageLocator", type = "entity" }
}

--This function is called on the server when this entity is created
function BannerScript:Init()
end

function BannerScript:HandleCheckin(user)
	if IsServer() then
		user:SendToScripts("DoOnLocal", self:GetEntity(), "HandleCheckin", user)
		return
	end
	
	print("handling checkin")
	Leaderboards.GetNearbyValuesForGame(
		"1ff284cd-d4f7-4d63-a59d-63cb367b140b", 
		"1-wealth", 1, user, function(results)
			local me = results[1]
			print("Rank 1", #results, me and me.rank)
			if me.rank > 0 then
				self.properties.imageLocator.simpleImageWidget.js.data.imageURL = "https://live.content.crayta.com/ui_image/04e6a4c1-790e-4ab7-b86f-eb0e05475b9c_ui_image"
			end
		end)

	Leaderboards.GetNearbyValuesForGame(
		"1ff284cd-d4f7-4d63-a59d-63cb367b140b", 
		"2-wealth", 1, user, function(results)
			local me = results[1]
			print("Rank 2", #results, me and me.rank)
			if me and me.rank > 0 then
				self.properties.imageLocator.simpleImageWidget.js.data.imageURL = "https://live.content.crayta.com/ui_image/0181a783-fad8-445a-bc00-93c73b1abe24_ui_image"
			end
		end)
end

function BannerScript:HandleCheckout()
	if IsServer() then
		self:SendToAllClients("HandleCheckout")
		return
	end
	
	self.properties.imageLocator.simpleImageWidget.js.data.imageURL = ""
end

return BannerScript
