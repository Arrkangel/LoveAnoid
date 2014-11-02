require("actor")
require("levelloader")
function love.load()
	love.window.setTitle("LoveAnoid")
	love.window.setMode(640,480)

	blip=love.audio.newSource("blip.wav","static")
	expdata=love.sound.newSoundData("exp.wav")

	gamestate={}
	gamestate.begin=false
	gamestate.lives=5
	gamestate.curLevel=1
	gamestate.maxLevel=5
	gamestate.score=0

--main menu

	mainmenu={}
	mainmenu.selector=1
	mainmenu.curMenu=1
	mainmenu.maxSelect=2


	mainmenu.menus={}

	mainmenu.moveSelector=function(sel)
		print(sel)
		if sel>mainmenu.maxSelect then
			sel=1
		elseif sel<1 then
			sel=mainmenu.maxSelect
		end

		mainmenu.selector=sel

	end

--root menu

	local rootmenu={}
	rootmenu.updateSelector=function()
		mainmenu.maxSelect=2
		mainmenu.selector=1
	end
	rootmenu.runSelection=function()
		if mainmenu.selector==1 then
			gamestate.begin=true
		else
			mainmenu.curMenu=2
			mainmenu.menus[2].updateSelector()
		end


	end


	rootmenu.draw=function()
		love.graphics.print("Main Menu",200,200)
		local selchar={}
		selchar[1]=""
		selchar[2]=""
		selchar[mainmenu.selector]=">"
		love.graphics.print(selchar[1].."Start Game",200,220)
		love.graphics.print(selchar[2].."Change Level",200,240)
	end

	mainmenu.menus[1]=rootmenu

--level menu

	local levelmenu={}
	levelmenu.updateSelector=function()
		mainmenu.maxSelect=gamestate.maxLevel+1
		mainmenu.selector=1
	end
	levelmenu.runSelection=function()
		if mainmenu.selector==1 then
			mainmenu.curMenu=1
			mainmenu.menus[mainmenu.curMenu].updateSelector()
		else
			changeLevel(mainmenu.selector-1)
		end
	end
	levelmenu.draw=function()
		love.graphics.print("Level Selector",200,200)
		local retstr=""
		if mainmenu.selector==1 then
			retstr=retstr..">"
		end
		love.graphics.print(retstr.."Return to Main Menu",200,220)
		for i=1,gamestate.maxLevel do
			local str=""
			if i ==mainmenu.selector-1 then
				str=str..">"
			end
			if i==gamestate.curLevel then
				str=str.."|"
			end
			str=str.."Level "..i
			love.graphics.print(str,200,220+i*20)
		end
	end

	mainmenu.menus[2]=levelmenu



	



	paddle=newActor("paddle",270,400,100,20,true,255,0,0)

	paddle.update=function(self,dt)
		local a=0
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
			a=1
		end
		local d=0
		if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
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

	ball.reset=function(self)
		self.rect.x=resetPos.x
		self.rect.y=resetPos.y
		self.vel.x=resetVel.x
		self.vel.y=resetVel.y
		self.curDelay=0
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
			gamestate.lives=gamestate.lives-1
			ball:reset()
			
		end
		if other.name=="paddle" then
			if coldata.horiz then
				local middle=other.rect.x+other.rect.width/2
				local selfx=self.rect.x+self.rect.width/2
				local diff=selfx-middle

				self.vel.x=self.vel.x+(diff*math.abs(diff))/4
				if self.vel.x>=self.maxVel*0.9 then
					self.vel.x=self.maxVel*0.9
				end

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

	loadLevel("level"..gamestate.curLevel..".png")
end

function changeLevel(level)
	if level>gamestate.maxLevel then
		--put win stuff here
		return nil
	end
	ball:reset()
	actors={}
	actors[1]=paddle
	actors[2]=ball
	actors.curID=3
	walltop=newActor("walltop",0,-30,640,40,true,0,0,255)
	wallleft=newActor("wallleft",-30,0,40,480,true,0,0,255)
	wallbottom=newActor("wallbottom",0,470,640,40,true,0,0,255)
	wallright=newActor("wallright",630,0,40,480,true,0,0,255)

	
	loadLevel("level"..level..".png")
	gamestate.curLevel=level


end

function love.keypressed(key,isrepeat)
	if gamestate.begin then
		if key=="n" and not irepeat then
			ball:reset()
			gamestate.lives=gamestate.lives-1
		end
	else
		if key=="w" or key=="up" then
			mainmenu.moveSelector(mainmenu.selector-1)
		elseif key=="s" or key=="down" then
			mainmenu.moveSelector(mainmenu.selector+1)
		elseif key=="return" then
			mainmenu.menus[mainmenu.curMenu].runSelection()
		end
	end
	
end


function love.update(dt)
	if gamestate.begin and gamestate.lives>=0 and love.window.hasFocus() then
		updateActors(dt)
	end



end


function love.draw()
	if gamestate.begin and gamestate.lives>=0 then
		drawScore()
		drawActors()
	elseif gamestate.lives<0 then
		drawGameOver()

	else
		mainmenu.menus[mainmenu.curMenu].draw()
	end

end
function drawScore()
	love.graphics.setColor(255,255,255)
	love.graphics.print("Score: "..gamestate.score .. " Extra Lives: "..gamestate.lives..
	" Stuck ball workaround: Press N to reset ball (lose a life) ",20,450)
end
function drawGameOver()
	love.graphics.setColor(255,255,255)
	love.graphics.print("GAME OVER! Score: "..gamestate.score,300,300)

end


