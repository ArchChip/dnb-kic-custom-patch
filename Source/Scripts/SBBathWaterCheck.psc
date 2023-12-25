Scriptname SBBathWaterCheck

Import PO3_SKSEFunctions
    
; Check if actor is in water using PO3 function
Bool Function IsInWater(Actor akTarget) Global
	If akTarget.IsSwimming()
		Return True
	Else
		Return PO3_SKSEFunctions.IsActorInWater(akTarget)
	EndIf
EndFunction