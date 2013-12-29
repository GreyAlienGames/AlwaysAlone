Import diddy
Import mojo
Import CommonFunctions
Import autofit

Class TGame
	Field currentTScreen:TScreen

	Method ChangeScreen:Void(nextScreen:TScreen)
		If nextScreen=Null Then
			Error("TGame.ChangeScreen: nextScreen cannot be null")
		Else
			If currentTScreen <> Null Then
				If currentTScreen.deletable Then currentTScreen.Delete()
			Endif
			
			nextScreen.Load()
			currentTScreen = nextScreen
			FlushKeys()
		Endif		
	End Method
		
	Method Draw:Void()
		currentTScreen.Draw()
	End Method

	Method Update:Void()
		currentTScreen.Update()
	End Method	
End Class

Class TScreen
	Field background:Image
	Field deletable:Int = 1
	Field name:String

	Method Delete:Void()
		background = Null
	End Method
			
	Method Draw:Void()
		If background<>Null Then
			DrawImage background,0,0
		Endif		
	End Method

	Method Load:Void()
	End Method
	
	Method Update:Void()
	End Method
End Class

Class TSprite
	Field alpha:Float = 1
	Field alphaDeleteWhenDone:Int = 0 'if 1, the sprite will be marked for deletion after the alpha transition.
	Field alphaEnd:Float = 1 'alpha at end of alpha transition.
	Field alphaSpeed:Float = 0 'amount to progress per frame. Can be -ve.
	Field alphaTransition:Int = 0
	Field angle:Float
	Field clicked:Int
	Field dx:Float
	Field dy:Float
	Field deleteIfOffScreen:Int=1
	Field halfWidth:Int
	Field halfHeight:Int
	Field hitBoxX:Int
	Field hitBoxY:Int
	Field hitBoxX2:Int
	Field hitBoxY2:Int
	Field midHandled:Int
	Field mouseOver:Int = 0
	Field rotation:Float = 0
	Field rotationDeleteWhenDone:Int = 0 'if 1, the sprite will be marked for deletion after the rotation transition.
	Field rotationEnd:Float = 1 'rotation at end of rotation transition.
	Field rotationSpeed:Float = 0 'amount to progress per frame. Can be -ve.
	Field rotationTransition:Int = 0
	Field scaleX:Float = 1
	Field scaleY:Float = 1
	Field scaleXDeleteWhenDone:Int = 0 'if 1, the sprite will be marked for deletion after the scale transition.
	Field scaleYDeleteWhenDone:Int = 0 'if 1, the sprite will be marked for deletion after the scale transition.
	Field scaleXEnd:Float = 1 'scale at end of scale transition.
	Field scaleYEnd:Float = 1 'scale at end of scale transition.
	Field scaleXSpeed:Float = 0 'amount to progress per frame. Can be -ve.
	Field scaleYSpeed:Float = 0 'amount to progress per frame. Can be -ve.
	Field scaleXTransition:Int = 0
	Field scaleYTransition:Int = 0
	Field speed:Float = 0
	Field spriteImage:Image
	Field x:Float
	Field y:Float
	Field width:Int
	Field height:Int
	Field visible:Int = 1
	
	Method CalcSize:Void()
		If spriteImage Then
			width = spriteImage.Width() 
			height = spriteImage.Height()
			halfWidth = width/2 
			halfHeight = height/2 
			ResetHitBox()
		Endif
	End Method
	
	Method Collide:Int(target:TSprite)
		Local tx:Float = target.x
		Local ty:Float = target.y
		If target.midHandled Then
			tx-=target.halfWidth
			ty-=target.halfHeight
		Endif
		If midHandled Then
			Return ccRectsCollide(x-halfWidth,y-halfHeight,width,height,tx,ty,target.width,target.height)
		Else
			Return ccRectsCollide(x,y,width,height,tx,ty,target.width,target.height)
		Endif
	End Method
	
	Method Draw:Void()
		If visible Then
			Local oldAlpha = GetAlpha
			If alpha>1 Then
				SetAlpha 1
			Else
				SetAlpha alpha
			endif
			PushMatrix
			Rotate rotation
			DrawImage spriteImage,x,y,angle,scaleX,scaleY
			SetAlpha oldAlpha
			PopMatrix
		Endif
	End Method
		
	Method IsClicked:Int()
		If IsMouseOver() And MouseHit() Then
			clicked = 1
		Else
			clicked = 0
		Endif
	End Method

	Method IsMouseOver:Int()
		If VMouseX() >= x+hitBoxX And VMouseX() < x+hitBoxX2 And VMouseY() >= y+hitBoxY And VMouseY() < y+hitBoxY2 Then
			mouseOver = 1
			Return 1
		Endif

		mouseOver = 0		
		Return 0		
	End Method

	Method IsOffScreen:Int()
		If x<-halfWidth Then Return 1
		If x>=SCREEN_WIDTH+halfWidth Then Return 1
		If y<-halfHeight Then Return 1
		If y>SCREEN_HEIGHT+halfHeight Then Return 1
		Return 0
	End Method

	Method LoadImage:Void(path:String, frames:Int=1, flags:Int=Image.MidHandle)
		spriteImage = graphics.LoadImage(path, frames, flags)
		CalcSize()
		midHandled = (flags & Image.MidHandle)
	End Method
	
	Method Move:Int()
		'Returns -1 if it should be deleted.
		x+=dx
		y+=dy
		If deleteIfOffScreen Then
			If IsOffScreen() Then
				Return -1
			Endif
		Endif
		Return 1
	End Method

	Method MoveX:Int()
		'Returns -1 if it should be deleted.
		x+=dx
		If deleteIfOffScreen Then
			If IsOffScreen() Then
				Return -1
			Endif
		Endif
		Return 1
	End Method

	Method MoveY:Int()
		'Returns -1 if it should be deleted.
		y+=dy
		If deleteIfOffScreen Then
			If IsOffScreen() Then
				Return -1
			Endif
		Endif
		Return 1
	End Method

	Method MoveTo(newX:Float, newY:Float)	
		x = newX
		y = newY
	End Method
	
	Method ResetHitBox:Void()
		hitBoxX = 0
		hitBoxY = 0
		hitBoxX2 = width		
		hitBoxY2 = height
	End Method
	
	Method SetAlphaTransition:Void(startA:Float, endA:Float, speedA:Float, deleteWhenDone:Int=0)
		alpha = startA
		alphaEnd = endA
		alphaSpeed = speedA
		alphaDeleteWhenDone = deleteWhenDone
		alphaTransition = 1
	End Method
	
	Method SetCoords:Void(newx:Float,newy:Float)
		x = newx
		y = newy
	End Method
	
	Method SetHitBox:Void(bx:Int, by:Int, bw:Int, bh:Int)	
		'Uses x and y coords plus width and height to set x2 and y2.
		hitBoxX = bx
		hitBoxY = by
		hitBoxX2 = bx+bw
		hitBoxY2 = by+bh
	End Method
	
	Method SetRotationTransition:Void(startR:Float, endR:Float, speedR:Float, deleteWhenDone:Int=0)
		rotation = startR
		rotationEnd = endR
		rotationSpeed = speedR
		rotationDeleteWhenDone = deleteWhenDone
		rotationTransition = 1		
	End Method
	
	Method SetScaleXTransition:Void(startSc:Float, endSc:Float, speedSc:Float, deleteWhenDone:Int=0)
		scaleX = startSc
		scaleXEnd = endSc
		scaleXSpeed = speedSc
		scaleXDeleteWhenDone = deleteWhenDone
		scaleXTransition = 1
	End Method

	Method SetScaleYTransition:Void(startSc:Float, endSc:Float, speedSc:Float, deleteWhenDone:Int=0)
		scaleY = startSc
		scaleYEnd = endSc
		scaleYSpeed = speedSc
		scaleYDeleteWhenDone = deleteWhenDone
		scaleYTransition = 1
	End Method

	Method SetSpriteImage:Void(theImage:Image, isMidHandled:Int=1)
		spriteImage = theImage
		CalcSize()		
		midHandled = isMidHandled
		If midHandled Then
			spriteImage.SetHandle(width/2,height/2)
		Endif
	End Method
	
	Method Update:Int()
		'Returns -1 if it should be deleted
		If alphaTransition
			alpha+=alphaSpeed
			If alphaSpeed<0 And alpha<=alphaEnd Then
				alpha = alphaEnd
				alphaTransition = 0
				If alphaDeleteWhenDone Then Return -1
			Elseif alphaSpeed>0 And alpha>=alphaEnd Then
				alpha = alphaEnd
				alphaTransition = 0
				If alphaDeleteWhenDone Then Return -1
			Endif
		Endif
		
		If scaleXTransition
			scaleX+=scaleXSpeed
			If scaleXSpeed<0 And scaleX<=scaleXEnd Then
				scaleX = scaleXEnd
				scaleXTransition = 0
				If scaleXDeleteWhenDone Then Return -1
			Elseif scaleXSpeed>0 And scaleX>=scaleXEnd Then
				scaleX = scaleXEnd
				scaleXTransition = 0
				If scaleXDeleteWhenDone Then Return -1
			Endif
		Endif

		If scaleYTransition
			scaleY+=scaleYSpeed
			If scaleYSpeed<0 And scaleY<=scaleYEnd Then
				scaleY = scaleYEnd
				scaleYTransition = 0
				If scaleYDeleteWhenDone Then Return -1
			Elseif scaleYSpeed>0 And scaleY>=scaleYEnd Then
				scaleY = scaleYEnd
				scaleYTransition = 0
				If scaleYDeleteWhenDone Then Return -1
			Endif
		Endif

		If rotationTransition
			rotation+=rotationSpeed
			If rotationSpeed<0 And rotation<=rotationEnd Then
				rotation = rotationEnd
				rotationTransition = 0
				If rotationDeleteWhenDone Then Return -1
			Elseif rotationSpeed>0 And rotation>=rotationEnd Then
				rotation = rotationEnd
				rotationTransition = 0
				If rotationDeleteWhenDone Then Return -1
			Endif
		Endif
		
	End Method
		
End Class

Class TButton Extends TSprite
	
End Class