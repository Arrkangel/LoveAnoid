require("actor")

function love.load()
	love.window.setTitle("LoveAnoid")
	love.window.setMode(640,480)

	paddle=newActor("paddle",300,400,100,20,true,255,0,0)

	paddle.update=function(self,dt)
		local a=0
		if love.keyboard.isDown("a") then
			a=1
		end
		local d=0
		if love.keyboard.isDown("d") then
			d=1
		end
		local multi=100
		local move=(d-a)*multi*dt
		self.rect.x=self.rect.x+move
		self.rect:updateValues()
	end


	
	ball=newActor("ball",50,300,10,10,true,255,255,255)
	local vel={}
	vel.x=0
	vel.y=300
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
		if other.name=="wallbottom" then
			--self.vel.x=0
			--self.vel.y=0
			--self:destroy()
		end
	end

	walltop=newActor("walltop",0,0,640,10,true,0,0,255)
	wallleft=newActor("wallleft",0,0,10,480,true,0,0,255)
	wallbottom=newActor("wallbottom",0,470,640,10,true,0,0,255)
	wallright=newActor("wallright",630,0,10,480,true,0,0,255)

	--spawn blocks
	for y=1,2 do
		for x=1,15 do
			local block=newActor("block",x*20-10,y*20-10,20,20,true,0,255,0)
			block.collCallback=function(self,other)
				if other.name=="ball" then
					self:destroy()
				end
			end
		end
	end






end


function love.update(dt)

	updateActors(dt)


end


function love.draw()
	
	drawActors()

end