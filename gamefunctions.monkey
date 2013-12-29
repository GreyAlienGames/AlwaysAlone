Import diddy
Import mojo
Import globals
Import CommonFunctions
Import CommonClasses
Import gameclasses

Function DrawGameText:Void(text$, x:Float, y:Float, xalign:Float=0, yalign:Float=0)
	PushMatrix
	Local scaleFactor:Float = 1
'	Scale SCREENX_RATIO*scaleFactor, SCREENY_RATIO*scaleFactor
	Scale scaleFactor, scaleFactor
	DrawText(text, x/scaleFactor, y/scaleFactor, xalign, yalign)
	PopMatrix
End Function
