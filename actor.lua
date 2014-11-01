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
	act.collCallback=function(self,other) end --blank collision callback


	act.id=actors.curID
	actors[act.id]=act
	actors.curID=actors.curID+1

	act.destroy=function(self)
		local desidx=0
		local found=false
		for i,v in ipairs(actors) do
			if v==self and not found then
				desidx=i
				found=true
			elseif found then
				v.id=v.id-1
			end
		end
		table.remove(actors,desidx)
		actors.curID=table.getn(actors)+1

	end

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

	local collisions={}

	local coldata={} --table for storing colision data
	coldata.actor=nil--actor collided with (nil for nothing)
	coldata.norm=nil --normal vector the actor collided with (for ball physics)
	coldata.horiz=true --collision against horizontal or vertical surface?

	local r1=actor.rect:copy() --copy actor rect and move to new position
	r1.x=x
	r1.y=y
	r1:updateValues()

	coldata.rect=r1 --rect created by copy, to optimize slightly

	for i,v in ipairs(actors) do
		if actor.id~=v.id and v.collides then
			local pcd={} --Possible Collision Data
			pcd.horiz=true
			local norm={}
			norm.x=0
			norm.y=0
			local r2=v.rect
			
			if checkOverlap(r1,r2) then
				
				if r2.right<actor.rect.left or r2.left> actor.rect.right then
					pcd.horiz=false
				end
				pcd.actor=v
				pcd.norm=norm
				table.insert(collisions,pcd)


			end
		end
	end
	local dist=1000000
	local curdata=nil
	for i,cd in ipairs(collisions) do
		local ndist=distanceBetween(actor,cd.actor)
		
		if ndist<dist then
			dist=ndist
			coldata=cd
		end
	end


	return coldata
end

function distanceBetween(a1,a2)
	local x1=a1.rect.x
	local x2=a2.rect.x
	local y1=a1.rect.y
	local y2=a2.rect.y

	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function normalizeVelocity(vel)
	local x=vel.x
	local y=vel.y
	
	local a=math.sqrt(x^2+y^2)
	x=x/a
	y=y/a
	local normV={}
	normV.x=x
	normV.y=y
	return normV
end

