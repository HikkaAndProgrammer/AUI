local IParticleSystem = setmetatable({}, { __index = love.AUI.IUIObject })

function IParticleSystem:draw()
	love.graphics.draw(self.__ps_layer, self.x, self.y)
end

function IParticleSystem:update(dt)
	self.__ps_layer:update(dt)
end

function IParticleSystem:checkHover(_, _)
	return false
end

function IParticleSystem:recreate(parent)
	self.parent = parent or self.parent
	return love.AUI.ParticleSystem(self)
end

local function ParticleSystem(particlesystem)
	local ps_p = {}
	for k, v in pairs(particlesystem) do
		c = k:sub(1, 1)
		if c:upper() == c then
			ps_p[k] = v
		end
	end
	if getmetatable(particlesystem) == nil or getmetatable(particlesystem).__index ~= IParticleSystem then
		local ps = particlesystem
		particle_system = setmetatable({
			x = particlesystem.x, y = particlesystem.y,
			width = -1,
			height = -1,
			image = particlesystem.image,
			limit = particlesystem.limit,
			__image_layer = particlesystem.__image_layer or love.graphics.newImage(particlesystem.image),
			__ps_layer = particlesystem.__ps_layer
		}, { __index = IParticleSystem })
		for k, v in pairs(ps) do if not rawget(particlesystem, k) then particlesystem[k] = v end end
	end
	particle_system.__ps_layer = particle_system.__ps_layer or love.graphics.newParticleSystem(particle_system.__image_layer, particle_system.limit or 10)
	for k, v in pairs(ps_p) do
		if particle_system.__ps_layer["set" .. k] then
			particle_system.__ps_layer["set" .. k](particle_system.__ps_layer, unpack(v))
		end
	end
	return particle_system
end

return {IParticleSystem, ParticleSystem}