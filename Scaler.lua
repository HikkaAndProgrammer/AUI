local Scaler = {}

function Scaler:increase(d)
	d = d or 1
	local v = self.value + self.step * d
	if v > self.maxv then
		v = self.maxv
	end
	self.value = v
	return self
end

function Scaler:decrease(d)
	self.value = self.value - self.step * d
	if self.value < self.minv then
		self.value = self.minv
	end
	return self
end

function Scaler:getValue()
	return self.transform(self.value)
end

function Scaler:reachedMaxValue()
	return self.value == self.maxv
end

function Scaler:reachedMinValue()
	return self.value == self.minv
end

return function (minv, maxv, step, transform)
	assert((maxv > minv) and (step > 0))
	return setmetatable({
		value = minv,
		minv = minv,
		maxv = maxv,
		step = step,
		transform = transform or function(x) return x end
	}, { __index = Scaler })
end