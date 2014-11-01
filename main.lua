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


	
	ball=newActor("ball",320,300,10,10,true,255,255,255)
	local vel={}
	vel.x=100
	vel.y=100
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
				print("Hi")
				nVel.x=nVel.x*-1
			end
			self.vel=nVel
			print(nVel.x ..",".. nVel.y)
			x=self.rect.x+self.vel.x*dt
			y=self.rect.y+self.vel.y*dt
			self.rect.x=x
			self.rect.y=y
			self.rect:updateValues()

		else
			self.rect.x=x
			self.rect.y=y
			self.rect:updateValues()
		end
	end

	walltop=newActor("walltop",0,0,640,10,true,0,0,255)
	wallleft=newActor("wallleft",0,0,10,480,true,0,0,255)
	wallbottom=newActor("wallbottom",0,470,640,10,true,0,0,255)
	wallright=newActor("wallright",630,0,10,480,true,0,0,255)





end


function love.update(dt)

	updateActors(dt)


end


function love.draw()
	
	drawActors()

end