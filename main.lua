require("actor")
require("levelloader")
function love.load()
	love.window.setTitle("LoveAnoid")
	love.window.setMode(640,480)

	blip=love.audio.newSource("blip.wav","static")
	expdata=love.sound.newSoundData("exp.wav")
	


	paddle=newActor("paddle",270,400,100,20,true,255,0,0)

	paddle.update=function(self,dt)
		local a=0
		if love.keyboard.isDown("a") then
			a=1
		end
		local d=0
		if love.keyboard.isDown("d") then
			d=1
		end
		local multi=300
		local move=(d-a)*multi*dt
		self.rect.x=self.rect.x+move
		if self.rect.x<10 then
			self.rect.x=10
		elseif self.rect.x>530 then
			self.rect.x=530
		end

		self.rect:updateValues()
	end


	
	ball=newActor("ball",315,300,10,10,true,255,255,255)
	local vel={}
	vel.x=0
	vel.y=400
	ball.maxVel=400
	ball.vel=vel

	ball.update=function(self,dt)
		
		local x=self.rect.x+self.vel.x*dt
		local y=self.rect.y+self.vel.y*dt

		local coldata=collisionCheck(self,x,y)
		if coldata.actor~=nil then
			local horiz=coldata.horiz
			local nVel={}
			nVel.x=self.vel.x
			nVel.y=self.vel.y
			if horiz then
				nVel.y=nVel.y*-1
				
			else
				
				nVel.x=nVel.x*-1
			end
			self.vel=nVel
			
			
			x=self.rect.x+self.vel.x*dt
			y=self.rect.y+self.vel.y*dt

			self:collCallback(coldata.actor)
			coldata.actor:collCallback(self)
			
		end
		self.rect.x=x
		self.rect.y=y
		self.rect:updateValues()
		
	end

	ball.collCallback=function(self,other)
		love.audio.play(blip)
		if other.name=="wallbottom" then
			--self.vel.x=0
			--self.vel.y=0
			--self:destroy()
		end
		if other.name=="paddle" then
			local middle=other.rect.x+other.rect.width/2
			local selfx=self.rect.x+self.rect.width/2
			local diff=selfx-middle

			self.vel.x=self.vel.x+(diff*math.abs(diff))/4
			local newVel=normalizeVelocity(self.vel)
			--print(newVel.x)
			--print(newVel.y)
			newVel.x=newVel.x*self.maxVel
			newVel.y=newVel.y*self.maxVel
			self.vel=newVel

		end


	end

	walltop=newActor("walltop",0,-30,640,40,true,0,0,255)
	wallleft=newActor("wallleft",-30,0,40,480,true,0,0,255)
	wallbottom=newActor("wallbottom",0,470,640,40,true,0,0,255)
	wallright=newActor("wallright",630,0,40,480,true,0,0,255)

	--spawn blocks
	--[[for y=1,23 do
		for x=1,31 do
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
	]]
	loadLevel("level1.png")








end


function love.update(dt)

	updateActors(dt)


end


function love.draw()
	
	drawActors()

end