actors={}
actors.curID=1

function newRect(xPos,yPos,xSize,ySize)
	local rect={}
	rect.x=xPos
	rect.y=yPos
	rect.width=xSize
	rect.height=ySize
	rect.updateValues=function(self)
		rect.left=self.x
		rect.right=self.x+self.width
		rect.top=self.y
		rect.bottom=self.y+self.height
	end
	rect.updateValues()
	rect.copy=function(self)
		return newRect(self.x,self.y,self.width,self.height)
	end

end


function newActor(image,x,y,width,height,collides)
	local act={}
	act.image=image
	act.collides=collides
	act.rect=newRect(x,y,width,height)
	act.id=actors.curID
	actors[act.id]=act
	actors.curID=actors.curID+1
	return act


end
