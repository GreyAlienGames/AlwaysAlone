#GLFW_USE_MINGW=False

#GLFW_WINDOW_WIDTH=800
#GLFW_WINDOW_HEIGHT=600

'TODO:

'Title music end music?

'Fix wall sticking with player
'Different wall graphics on each level.
'Game obstacles
'Make sure created enemies don't start in colliding positions.
'Make them scared so their move counter min and max is reduce and scared wears off.
'Level complete floating text? "Leave me alone!" Maybe also starting floating text?
'Spin spiral effect (it's bugged and turned off now)
'Have more than one type of kid with slightly different behaviour.
'Waves?

'Load HUD? Set gameplay area in gameScreen and bounds check that + fix enemy randomisation.
'Show level name on HUD

'Framework:
'Move CommonClasses and Functions into a module, also autofit so that it can be accessed by them.
'Make collision work with hitbox.
'Use private and public on class fields and functions.
'Make rotation work properly.
'Store old rotation in sprite draw so it can be restored (perhaps just storing the Matrix is fine)
'Make sound loader that uses correct extension (test ogg for HTML5)
'Consider storing MouseX/Y and MouseHit in TGame at start of Update loop. Add a Flush Mouse command for MouseHit.


Strict

Import diddy
Import mojo
Import globals
Import commonFunctions
Import CommonClasses
Import gameclasses
Import screens
Import autofit

Function Main:Int()
	SCREEN_WIDTH = 800
	SCREEN_HEIGHT = 600

	New MyApp

	Return 1
End

Class MyApp Extends App
		
	Method OnCreate:Int()
		'Setup screen size
		DEVICE_WIDTH = DeviceWidth()
		DEVICE_HEIGHT = DeviceHeight()
'		Print DEVICE_WIDTH  
'		Print DEVICE_HEIGHT
		SCREENX_RATIO = DEVICE_WIDTH/SCREEN_WIDTH
		SCREENY_RATIO = DEVICE_HEIGHT/SCREEN_HEIGHT		
		
		InitGlobals()

		SetVirtualDisplay SCREEN_WIDTH,SCREEN_HEIGHT
		
		'Set frame rate
		SetUpdateRate 60
		Seed = RealMillisecs()
		
		SetFont(LoadImage("Font.png",12,12,96),32)
		
		titleScreen = New TTitleScreen
		myGame.ChangeScreen(titleScreen)
		
		Return 1
	End Method

	Method OnUpdate:Int()
		myGame.Update()
		
		Return 1
	End Method

	Method OnRender:Int()
		UpdateVirtualDisplay
		Cls

'		PushMatrix 
'		Scale SCREENX_RATIO, SCREENY_RATIO 'From Diddy.

		myGame.Draw()

'		PopMatrix
		
		Return 1
	End Method
	
End Class

