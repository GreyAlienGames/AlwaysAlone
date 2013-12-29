Import diddy
Import mojo

Function ccKeyAccept:Int()
	Return KeyHit(KEY_SPACE) Or KeyHit(KEY_ENTER)
End Function

Function ccRectsCollide:Int(x1%, y1%, w1%, h1%, x2%, y2%, w2%, h2%)
	If x1 >= (x2 + w2) Or (x1 + w1) <= x2 Or y1 >= (y2 + h2) Or (y1 + h1) <= y2 Then
		Return 0
	Else
		Return 1	
	Endif
End Function

