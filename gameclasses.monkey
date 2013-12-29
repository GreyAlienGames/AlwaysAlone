Import diddy
Import mojo
Import globals
Import CommonFunctions
Import CommonClasses

Class TPlayer Extends TSprite
	Field attackImage:TSprite
	Field fireCounter:Int
	Field fireLength:Float = 30 'keep as Float for math later on.
	Field fireSound:Sound
	Field level:Int = 1
	Field story:Int = 1
		
	Method BoundsCheck:Void()
		If x<0+halfWidth Then x=halfWidth 
		If x>SCREEN_WIDTH-halfWidth Then x=SCREEN_WIDTH-halfWidth
		If y<0+halfHeight Then y=halfHeight 
		If y>SCREEN_HEIGHT-halfHeight Then y=SCREEN_HEIGHT-halfHeight
	End Method

	Method InitForLevel()
		If level = 1 Then
			LoadImage("jim_child.png")
		Else
			LoadImage("jim_adult.png")
		Endif			
		SetHitBox(0,halfHeight,width,height)
		x=SCREEN_WIDTH/2
		y=SCREEN_HEIGHT/2
		speed = 3.5+level/2
		LoadAttackImage()
		#If TARGET="html5" Or TARGET="glfw" Then
			fireSound = LoadSound("level"+level+".wav")		
		#Else
			fireSound = LoadSound("level"+level+".mp3")		
		#End
	End Method
	
	Method CheckKeys:Void()
		Local oldx:Float = x
		Local oldy:Float = y
		If KeyDown(KEY_LEFT) Or KeyDown(KEY_A)
			x-=speed
		End If
		If KeyDown(KEY_RIGHT) Or KeyDown(KEY_D)
			x+=speed
		End If
		If KeyDown(KEY_UP) Or KeyDown(KEY_W)
			y-=speed
		End If
		If KeyDown(KEY_DOWN) Or KeyDown(KEY_S)
			y+=speed
		End If
		
		If gameScreen.CollideWithWalls(Self) Then
			x=oldx
			y=oldy
		Endif
		
		If (KeyDown(KEY_Z) Or KeyDown(KEY_SPACE) Or MouseHit()) And fireCounter=0
			fireCounter=fireLength
			attackImage.visible = 1
			attackImage.SetCoords(x,y)
			attackImage.SetAlphaTransition(1.5,0,-1/fireLength)
			attackImage.SetScaleXTransition(0.25,1,1/fireLength/2)
			attackImage.SetScaleYTransition(0.25,1,1/fireLength/2)
			If level = 3 Then
'				attackImage.SetRotationTransition(0, 720, 720/fireLength) 
			Endif				
			gameScreen.PushEnemies(x,y)
			PlaySound(fireSound,0)
		Endif
	End Method	

	Method Draw:Void()
		Super.Draw()		
		attackImage.Draw()
	End Method
	
	Method LoadAttackImage:Void()
		attackImage = New TSprite
		attackImage.LoadImage("attack"+level+".png")
		attackImage.visible = 0
	End Method
	
	Method Update:Int()
		CheckKeys()
		BoundsCheck()
		If fireCounter>0
			fireCounter-=1
			If fireCounter=0
				attackImage.visible=0
			Endif
		Endif
		attackImage.Update()
	End Method
	
End Class

Class TEnemy Extends TSprite
	Field moveCounter:Int
	Field waitCounter:Int
	Field level:Int
	
	Method New(startx:Int, starty:Int, level:Int, theImage:Image)
		Self.x = startx
		Self.y = starty
		Self.level = level
		Self.speed = 0.5+level*0.5
		Self.SetSpriteImage(theImage)
	End Method

	Method Update:Int()
		'Returns -1 if it should be destroyed.
		If waitCounter>0 Then
			waitCounter-=1
		Else		
			If moveCounter = 0 Then
				Local levelFactor:Float = 1+level/2
				If Rnd(100)<50 Then
					waitCounter = Int(Rnd(30,60)/levelFactor)
					dx = 0
					dy = 0
				Else
					moveCounter = Int(Rnd(20,60)/levelFactor)
					dx = Rnd(0,speed*2)-speed	
					dy = Rnd(0,speed*2)-speed
				Endif
			Else
				moveCounter-=1
			Endif
		Endif
		
		Local oldx:Float = x
		Local oldy:Float = y
		Local result:Int = MoveX()
		If result=-1 Then Return -1
		If gameScreen.CollideWithWalls(Self) Then
			x = oldx
		Endif
		result = MoveY()
		If result=-1 Then Return -1
		If gameScreen.CollideWithWalls(Self) Then
			y = oldy
		Endif
		Return 1
	End Method
		
End Class
