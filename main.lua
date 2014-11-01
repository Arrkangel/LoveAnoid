require("actor")
require("levelloader")
function love.load()
	love.window.setTitle("LoveAnoid")
	love.window.setMode(640,480)

	blip=love.audio.newSource("blip.wav","static")
	expdata=love.sound.newSoundData("exp.wav")

	gamestate={}
	gamestate.begin=true
	gamestate.lives=5
	gamestate.curLevel=1
	gamestate.maxlevel=3
	gamestate.score=0
	



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

		if checkOverlap(self.rect,ball.rect) then
			if ball.rect.x > self.rect.x then
				ball.rect.x=self.rect.x+self.rect.width
			else
				ball.rect.x=self.rect.x-ball.rect.width
			end
		end
		

	end


	
	ball=newActor("ball",315,300,10,10,true,255,255,255)
	resetPos={}
	resetPos.x=315
	resetPos.y=300
	local vel={}
	vel.x=0
	vel.y=300
	resetVel={}
	
	resetVel.x=0
	resetVel.y=300

	ball.maxVel=300
	ball.vel=vel

	ball.delay=2
	ball.curDelay=0

	local function ballPhys(self,dt)

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

			self:collCallback(coldata.actor,coldata)
			coldata.actor:collCallback(self,coldata)
			
		else
			self.rect.x=x
			self.rect.y=y
			self.rect:updateValues()
		end
	end

	ball.update=function(self,dt)
		if self.curDelay<self.delay then
			self.curDelay=self.curDelay+dt
		else
			ballPhys(self,dt)
		end
	end

	ball.collCallback=function(self,other,coldata)
		love.audio.play(blip)
		if other.name=="wallbottom" then
			--self.vel.x=0
			--self.vel.y=0
			--self:destroy()
			print(self.rect.x)
			print(resetPos.x)
			self.rect.x=resetPos.x
			self.rect.y=resetPos.y
			self.vel.x=resetVel.x
			self.vel.y=resetVel.y
			self.curDelay=0
			gamestate.lives=gamestate.lives-1
			
		end
		if other.name=="paddle" then
			if coldata.horiz then
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
			else
				
			end



		end


	end

	walltop=newActor("walltop",0,-30,640,40,true,0,0,255)
	wallleft=newActor("wallleft",-30,0,40,480,true,0,0,255)
	wallbottom=newActor("wallbottom",0,470,640,40,true,0,0,255)
	wallright=newActor("wallright",630,0,40,480,true,0,0,255)

	loadLevel("level4.png")








end


function love.update(dt)
	if gamestate.begin and gamestate.lives>=0 then
		updateActors(dt)
	end



end


function love.draw()
	if gamestate.begin and gamestate.lives>=0 then
		drawScore()
		drawActors()
	elseif gamestate.lives<0 then
		drawGameOver()
	end
	

	

end
function drawScore()
	love.graphics.setColor(255,255,255)
	love.graphics.print("Score: "..gamestate.score .. " Extra Lives: "..gamestate.lives,20,450)
end
function drawGameOver()
	love.graphics.setColor(255,255,255)
	love.graphics.print("GAME OVER",300,300)
end


