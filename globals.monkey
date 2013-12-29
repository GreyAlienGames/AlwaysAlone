Import CommonClasses
Import screens

Global INSTRUCTION_HEIGHT:Int

Global myGame:TGame = New TGame
Global player:TPlayer
Global titleScreen:TTitleScreen
Global storyScreen:TStoryScreen
Global gameScreen:TGameScreen

Function InitGlobals:Void()
	INSTRUCTION_HEIGHT = SCREEN_HEIGHT-50
End Function
