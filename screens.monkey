Strict

Import diddy
Import mojo
Import globals
Import CommonFunctions
Import CommonClasses
Import gamefunctions

Class TTitleScreen Extends TScreen
	Field titleSound:Sound
	Field URLButton:TButton
	
	Method Draw:Void()
		Super.Draw()
		
		SetColor 240,240,0 
		DrawGameText("CLICK MOUSE TO START", SCREEN_WIDTH/2, INSTRUCTION_HEIGHT-50, 0.5)
		If URLButton.mouseOver Then
			SetColor 150,255,150 
		Else
			SetColor 50,240,50 
		Endif
		DrawGameText("www.GreyAlienGames.com", SCREEN_WIDTH/2, INSTRUCTION_HEIGHT, 0.5)
		SetColor 255,255,255
	End Method	

	Method Load:Void()
		name = "Title"
		background = LoadImage("Title.png")
		#If TARGET="html5" Or TARGET="glfw" Then
			titleSound = LoadSound("title.wav")
		#Else
			titleSound = LoadSound("title.mp3")
		#End
		PlaySound(titleSound,2)
		
		URLButton = New TButton
		Local URLWidth:Int = 22*12
		Local URLHeight:Int = 12
		Local buffer:Int = 4
		URLButton.MoveTo(SCREEN_WIDTH/2-URLWidth/2-buffer, INSTRUCTION_HEIGHT-buffer)		
		URLButton.SetHitBox(0,0,URLWidth+buffer*2, URLHeight+buffer*2)
	End Method
		
	Method Update:Void()
		URLButton.IsClicked()
		If URLButton.clicked Then
			LaunchBrowser("http://www.greyaliengames.com")
		Else	
			If MouseHit() Or ccKeyAccept() Then
				'Create Player now because it will persist through the levels.
				player = New TPlayer
			
				storyScreen = New TStoryScreen
				myGame.ChangeScreen(storyScreen)
			Endif
		Endif				
	End Method
End Class

Class TStoryScreen Extends TScreen
	Field picture:Image
	Field text1:String
	Field text2:String
	Field instructions:String
	Field titleSound:Sound
	
	Method Delete:Void()
		Super.Delete
		picture = Null
	End Method

	Method Draw:Void()
		Super.Draw()

		Local y:Int = 70
		DrawGameText(text1, SCREEN_WIDTH/2, y, 0.5)
		y+=18
		DrawGameText(text2, SCREEN_WIDTH/2, y, 0.5)
		y=400
		DrawGameText(instructions, SCREEN_WIDTH/2, y, 0.5)
		
		DrawImage picture,SCREEN_WIDTH/2,SCREEN_HEIGHT/2

		SetColor 80,80,80
		DrawGameText("<CLICK>", SCREEN_WIDTH/2+1, INSTRUCTION_HEIGHT+1, 0.5)
		SetColor 240,240,0 
		DrawGameText("<CLICK>", SCREEN_WIDTH/2, INSTRUCTION_HEIGHT, 0.5)
		SetColor 255,255,255
	End Method	
	
	Method Load:Void()
		name = "Story"

		Local story:Int = player.story
		
		picture = LoadImage("story"+story+".png",1,Image.MidHandle)
		
		Local storyText:String[]=["Jim was one of 9 children.",
			"As a child he preferred to be alone.",
			"At school Jim chased the children away",
			"with bodily functions.",
			"Jim became a computer programmer",
			"and appreciated silence.",
			"One day at the office, Jim lost it",
			"and chased his co-workers away.",
			"Jim hated shopping for clothes",
			"once every 5 years.",
			"One day at the mall, the muzak and lights",
			"had an adverse effect on Jim.",
			"Jim's flip out at the mall didn't go down well",
			"with the authorities.",
			"Jim finds himself in a bedlam",
			"and is greatly troubled.",
			"At last Jim gets his lifelong wish",
			"and is always alone..."] 
		text1 = storyText[(story-1)*2]
		text2 = storyText[(story-1)*2+1]

		Local instructionsText:String[]=["","Use <arrow keys> to move and <Z> to fart.",
			"","Use <Z> to swear.",
			"","Use <Z> to spin.",
			"","Use <Z> to go insane",
			""]
		instructions = instructionsText[story-1]					
		
		If story=3 Or story=5 Or story=7 Or story=9 Then
			#If TARGET="html5" Or TARGET="glfw" Then
				titleSound = LoadSound("title.wav")
			#Else
				titleSound = LoadSound("title.mp3")
			#End
		PlaySound(titleSound,2)		
		Endif

		If story=2 Or story=4 Or story=6 Or story=8 Then
			story-=1
		Endif
		background = LoadImage("story"+story+"bg.png")					
	End Method
	
	Method Update:Void()
		If MouseHit() Or ccKeyAccept() Then
			player.story+=1
			Local story:Int = player.story
			If story=3 Or story=5 Or story=7 Or story=9 Then
				StopChannel(2)		
				gameScreen = New TGameScreen
				myGame.ChangeScreen(gameScreen)	
			Elseif story=10 Then
				titleScreen = New TTitleScreen
				myGame.ChangeScreen(titleScreen)			
			Else
				storyScreen = New TStoryScreen
				myGame.ChangeScreen(storyScreen)
			Endif
		Endif

		If KeyHit(KEY_ESCAPE) Then
			titleScreen = New TTitleScreen
			myGame.ChangeScreen(titleScreen)
		Endif
	End Method	
End Class

Class TGameScreen Extends TScreen

	Field collide:Int
	Field successSound:Sound
	
	Field enemyList:List<TEnemy>
	Field wallList:List<TSprite>
	
	Global goalText:String[] = ["Children Left:","Co-workers Left:","Shoppers Left:","Psychotics Left:"]	
	
	Method CreateEnemies:Void()
		Local enemy1:Image = LoadImage("enemy"+player.level+".png")
		Local enemy2:Image = LoadImage("enemy"+player.level+"b.png")		
		Local enemy3:Image
		Local enemy4:Image
		Local enemy5:Image
		Local enemy6:Image

		'Load in more for level 3, the mall.
		If player.level = 3 Then
			enemy3 = LoadImage("enemy1.png")
			enemy4 = LoadImage("enemy1b.png")		
			enemy5 = LoadImage("enemy2.png")
			enemy6 = LoadImage("enemy2b.png")		
		Endif

		enemyList = New List<TEnemy>
		Local border:Int = 100
		For Local i:Int = 0 To 3+player.level*3
			Local img:Image = enemy1
			If player.level = 3 Then
				Local test:Int = Rnd(100)
				If test<16 Then
					img = enemy1
				Elseif test<32 Then
					img = enemy2
				Elseif test<48 Then
					img = enemy3
				Elseif test<64 Then
					img = enemy4
				Elseif test<80 Then
					img = enemy5
				Else
					img = enemy6
				Endif
			Else
				If Rnd(100)<50 Then
					img = enemy2
				Endif
			Endif
			Local e:TEnemy = New TEnemy(Rnd(border,SCREEN_WIDTH-border),Rnd(border,SCREEN_HEIGHT-border),player.level, img)
			enemyList.AddLast(e)
		Next
	End Method

	Method CreateWalls:Void()
		Local wallImage:Image = LoadImage("wall.png")
		wallList = New List<TSprite>
		
		Select player.level
			Case 1
				Local y:Int = 0
				While y<= SCREEN_HEIGHT
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = SCREEN_WIDTH-w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					y+=wallImage.Height()
				Wend

			Case 2
				Local y:Int = 0
				While y<= SCREEN_HEIGHT
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					w = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = SCREEN_WIDTH-w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					y+=wallImage.Height()
				Wend

			Case 3
				Local x:Int = 0
				Local gap:Int = 150
				While x<= SCREEN_WIDTH/2 - gap
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + w.halfWidth
					w.y = w.halfHeight
					wallList.AddLast(w)
					w = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + + w.halfWidth
					w.y = SCREEN_HEIGHT-w.halfHeight
					wallList.AddLast(w)
					x+=wallImage.Width()
				Wend
				x = SCREEN_WIDTH/2+gap
				While x<= SCREEN_WIDTH
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + w.halfWidth
					w.y = w.halfHeight
					wallList.AddLast(w)
					w = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + + w.halfWidth
					w.y = SCREEN_HEIGHT-w.halfHeight
					wallList.AddLast(w)
					x+=wallImage.Width()
				Wend
				Local y:Int = 0
				While y<= SCREEN_HEIGHT/2 - gap
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					w = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = SCREEN_WIDTH-w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					y+=wallImage.Height()
				Wend
				y = SCREEN_HEIGHT/2 + gap
				While y<= SCREEN_HEIGHT
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					w = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = SCREEN_WIDTH-w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					y+=wallImage.Height()
				Wend
			
			Case 4
				Local y:Int = 0
				While y<= SCREEN_HEIGHT
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					w = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = SCREEN_WIDTH-w.halfWidth
					w.y = y + w.halfHeight
					wallList.AddLast(w)
					y+=wallImage.Height()
				Wend
				Local x:Int = 0
				While x<= SCREEN_WIDTH
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + w.halfWidth
					w.y = w.halfHeight
					wallList.AddLast(w)
					x+=wallImage.Width()
				Wend
				Local gap:Int = 100
				x=0
				While x<= SCREEN_WIDTH/2 - gap
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + + w.halfWidth
					w.y = SCREEN_HEIGHT-w.halfHeight
					wallList.AddLast(w)
					x+=wallImage.Width()
				Wend
				x = SCREEN_WIDTH/2+gap
				While x<= SCREEN_WIDTH
					Local w:TSprite = New TSprite
					w.SetSpriteImage(wallImage)
					w.x = x + + w.halfWidth
					w.y = SCREEN_HEIGHT-w.halfHeight
					wallList.AddLast(w)
					x+=wallImage.Width()
				Wend
		End Select
	End Method
	
	Method CollideWithWalls:Int(testSprite:TSprite)
		For Local w:TSprite = Eachin wallList
			If w.Collide(testSprite) Then Return 1
		Next
		Return 0		
	End Method
	
	Method Draw:Void()
		Super.Draw()
		For Local w:TSprite = Eachin wallList
			w.Draw()
		Next	
		For Local e:TEnemy = Eachin enemyList
			e.Draw()
		Next	
		If collide Then DrawText("collide",100,0)
		player.Draw()
		
		SetColor 0,0,0
		SetAlpha 0.3
		DrawRect 0,0,SCREEN_WIDTH,31
		SetAlpha 1
		SetColor 50,50,50
		DrawText(goalText[player.level-1]+enemyList.Count(),10+1,10)
		DrawText(goalText[player.level-1]+enemyList.Count(),10-1,10)
		DrawText(goalText[player.level-1]+enemyList.Count(),10,10+1)
		DrawText(goalText[player.level-1]+enemyList.Count(),10,10-1)
		SetColor 240,240,240
		DrawText(goalText[player.level-1]+enemyList.Count(),10,10)
		SetColor 255,255,255
	End Method
	
	Method LevelComplete:Void()
		player.level+=1
		storyScreen = New TStoryScreen
		myGame.ChangeScreen(storyScreen)		
	End Method
	
	Method Load:Void()
		name = "Game Screen"
		
		#If TARGET="html5" Or TARGET="glfw" Then
			successSound = LoadSound("success.wav")
		#else
			successSound = LoadSound("success.mp3")
		#end
		
		background = LoadImage("level"+player.level+".png")				
		CreateEnemies()		
		CreateWalls()
		player.InitForLevel()		
	End Method

	Method PushEnemies:Void(x:Int, y:Int)
		Local levelFactor:Float = 1+player.level/2
		Local range:Float = 150
		For Local e:TEnemy = Eachin enemyList
			'Work out angle and distance from player x and y passed in.
			Local dx:Float = x-e.x
			Local dy:Float = y-e.y
			Local dist:Int = Sqrt(dx*dx+dy*dy)
			If dist<range Then
				If dist = 0 Then dist = 0.01 'avoid divide by zero error.
				Local power:Float = (range-dist)/range
				power*=5				
				e.dx = -(dx/dist)*power
				e.dy = -(dy/dist)*power
				e.waitCounter = 0
				e.moveCounter = Int(90/levelFactor)
			End
		Next
	End Method
	
	Method Update:Void()
		Super.Update()		
		collide = 0
		For Local e:TEnemy = Eachin enemyList
			If e.Update()=-1 Then
				enemyList.Remove(e)
				PlaySound(successSound,1)
			Endif
		Next
		
		'Is everyone gone?
		If enemyList.Count() = 0 Then
			LevelComplete()
		Endif
		
		player.Update()		

		If KeyHit(KEY_ESCAPE) Then
			titleScreen = New TTitleScreen
			myGame.ChangeScreen(titleScreen)
		Endif

		If KeyHit(KEY_J) Then
			LevelComplete()
		Endif

	End Method
End Class


