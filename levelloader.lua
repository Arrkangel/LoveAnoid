require("actor")
function colorToString(r,g,b)
	local rs=""
	local gs=""
	local bs=""
	if r<100 then
		if r<10 then
			rs="00"..r
		else
			rs="0"..r
		end
	else
		rs=r
	end
	if g<100 then
		if g<10 then
			gs="00"..g
		else
			gs="0"..g
		end
	else
		gs=g
	end
	if b<100 then
		if b<10 then
			bs="00"..b
		else
			bs="0"..b
		end
	else
		bs=b
	end
	return rs..gs..bs
end

function loadLevel(path)
	local dat=love.image.newImageData(path)
	local width,height=dat:getDimensions()
	print(width .. height)
	if width~=31 or height~= 23 then
		print("hi")
		return nil
	end
	for x=0,30 do
		for y=0, 22 do
			local r,g,b,a=dat:getPixel(x,y)
			if r==255 and g==0 and b==0 then
				local block=newActor("block",x*20-10,y*20-10,20,20,true,math.random(255),math.random(255),math.random(0))
				block.collCallback=function(self,other)
					if other.name=="ball" then
						local exp=love.audio.newSource(expdata,"static")
						love.audio.play(exp)
						self:destroy()
					end
				end
			end
		end
	end
end

