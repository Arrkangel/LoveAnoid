actors={}
actors.curID=1

function newRect(xPos,yPos,xSize,ySize)
	local rect={}
	rect.x=xPos
	rect.y=yPos
	rect.width=xSize
	rect.height=ySize
	rect.updateValues=function(self) --call after moving the rect to put the colision helper values in the right spot
		rect.left=self.x
		rect.right=self.x+self.width
		rect.top=self.y
		rect.bottom=self.y+self.height
	end
	rect:updateValues()
	rect.copy=function(self)
		return newRect(self.x,self.y,self.width,self.height)
	end
	return rect

end


function newActor(name,x,y,width,height,collides,r,g,b)
	local act={}
	act.name=name

	act.collides=collides
	act.rect=newRect(x,y,width,height)

	local color={}
	color.r=r
	color.g=g
	color.b=b
	act.color=color

	act.update=function(self,dt) end --blank function, to be replaced for any objects that need actual logic


	act.id=actors.curID
	actors[act.id]=act
	actors.curID=actors.curID+1
	return act
end

function drawActors()
	for i,v in ipairs(actors) do
		local color=v.color
		local rect=v.rect
		love.graphics.setColor(color.r,color.g,color.b)
		love.graphics.rectangle("fill",rect.x,rect.y,rect.width,rect.height)
	end
end

function updateActors(dt)
	for i,v in ipairs(actors) do
		v:update(dt)
	end
end

function checkOverlap(a,b)
	local r=a.left<=b.right and b.left<=a.right and a.top<=b.bottom and b.top<=a.bottom
	return r
end




function collisionCheck(actor,x,y)
	local coldata={} --table for storing colision data
	coldata.actor=nil--actor collided with (nil for nothing)
	coldata.norm=nil --normal vector the actor collided with (for ball physics)
	coldata.horiz=true

	local r1=actor.rect:copy() --copy actor rect and move to new position
	r1.x=x
	r1.y=y
	r1:updateValues()

	coldata.rect=r1 --rect created by copy, to optimize slightly

	for i,v in ipairs(actors) do
		if actor.id~=v.id and v.collides then
			local norm={}
			norm.x=0
			norm.y=0
			local r2=v.rect
			
			if checkOverlap(r1,r2) then
				
				if r2.right<actor.rect.left or r2.left> actor.rect.right then
					coldata.horiz=false
				end


				coldata.actor=v
				coldata.norm=norm
				return coldata

			end
		end
	end
	return coldata
end



