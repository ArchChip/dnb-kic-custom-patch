Scriptname SBBathAnimation extends activemagiceffect  
;===============  PROPERTIES  ==========================================;
Actor Property PlayerREF Auto
Idle property IdleWarmHandsCrouched auto
Idle property IdleWarmArms auto
Idle property IdleWipeBrow auto
Idle property IdleStop auto
Idle property IdleBracedPain auto
Idle property IdleStudy auto
Sound Property SBBATHPlayerWashingfxSM auto
Spell property SoapEffectSpell auto
Spell property SBBathSoapNoAnimationSpell auto
Keyword Property LocTypeShowerInInns Auto
GlobalVariable Property WaterRestriction Auto
GlobalVariable Property SBBATHAnimatedSoapShader Auto
Formlist Property SBBAthOutfitList Auto
Formlist Property SBBAthOutfitListBasket Auto
Formlist Property SBBAthLeftList Auto
Formlist Property SBBAthAmmoList Auto
GlobalVariable Property SBBAthDLC1Trigger Auto
GlobalVariable Property SBBAthDLC2Trigger Auto
Keyword Property VendorItemArrow Auto

;===============  Utilities   ==========================================;
Import Debug
Import Game
;===============    EVENTS    ==========================================;
Event OnEffectStart(Actor akTarget, Actor akCaster)
If (PlayerREF.GetSitState() == 0)
	If ((WaterRestriction.GetValue())as Int) != 1;check water restriction
		If PlayerREF.GetCurrentLocation().HasKeyword(LocTypeShowerInInns);check if the player is in bathroom
			If akTarget == PlayerRef
				WashAnimation()
			Endif
		Endif
	Else
		if akTarget == PlayerRef
			WashAnimation()
		endif
	EndIf
EndIf
EndEvent
;===============    Functions  ==========================================;
function WashAnimation()
	; get and remember equipped items
	;-------Ammo-DLC-Detection--------------------------------------
	If(SBBAthDLC1Trigger.GetValueInt() == 0)
		If(Game.GetModByName("Dawnguard.esm") != 255)
			AddDawnguardAmmo()
			SBBAthDLC1Trigger.SetValueInt(1)
			;Debug.Notification("Dawnguard Ammo found. Adding to Memory.")
		EndIf
	EndIf
	If(SBBAthDLC2Trigger.GetValueInt() == 0)
		If(Game.GetModByName("Dragonborn.esm") != 255)
			AddDragonbornAmmo()
			SBBAthDLC2Trigger.SetValueInt(1)
			;Debug.Notification("Dragonborn Ammo found. Adding to Memory.")
		EndIf
	EndIf
	;--------------------------------------------------------------
		
	Game.DisablePlayerControls(true, true, true, false, true, true, true)
	Game.ForceThirdPerson()
	If PlayerRef.IsWeaponDrawn()
		PlayerRef.SheatheWeapon()
		Utility.Wait(1.500000)
	Else
		Utility.Wait(0.200000)
	EndIf
	If SBBAthOutfitListBasket.GetSize() == 0
		PlayerREF.PlayIdle(IdleStop)
		Debug.SendAnimationEvent(PlayerRef, "IdleMQ203EsbernBookEnterInstant")
		;PlayerREF.PlayIdle(IdleMQ203EsbernBookEnterInstant)
		Utility.Wait(3)
		PlayerREF.PlayIdle(IdleStop)
	EndIf
	Int searched = UnequipGear(PlayerRef)
	If PlayerREF.GetCurrentLocation().HasKeyword(LocTypeShowerInInns)
		Utility.Wait(1)
		Int instanceID = SBBATHPlayerWashingfxSM.play(PlayerREf)
		PlayerREF.PlayIdle(IdleWarmHandsCrouched)
		if (SBBATHAnimatedSoapShader.GetValue() as Int) == 1
			PlayerREF.AddSpell(SoapEffectSpell, false)
		Else
			PlayerREF.AddSpell(SBBathSoapNoAnimationSpell, false)
		EndIf
		Utility.Wait(3)
		PlayerREF.PlayIdle(IdleStop)
		Utility.Wait(1)
		PlayerREF.PlayIdle(IdleWarmArms)
		Utility.Wait(2)
		PlayerREF.PlayIdle(IdleStop)
		Utility.Wait(1)
		PlayerREF.PlayIdle(IdleWipeBrow)
		Utility.Wait(1.5)
		PlayerREF.PlayIdle(IdleStop)
		Utility.Wait(1)
		PlayerREF.PlayIdle(IdleWarmHandsCrouched)
		Utility.Wait(3)
		PlayerREF.PlayIdle(IdleStop)
		Utility.Wait(1)
		if (SBBATHAnimatedSoapShader.GetValue() as Int) == 1
			PlayerREF.RemoveSpell(SoapEffectSpell)
		Else
			PlayerREF.RemoveSpell(SBBathSoapNoAnimationSpell)
		EndIf
		PlayerREF.RemoveSpell(SoapEffectSpell)
		PlayerREF.PlayIdle(IdleWipeBrow)
		Sound.StopInstance(instanceID)
		Utility.Wait(1.5)	
	Else
		Utility.Wait(1)	
		Int instanceID = SBBATHPlayerWashingfxSM.play(PlayerREF)
		PlayerREF.PlayIdle(IdleWarmHandsCrouched)
		if (SBBATHAnimatedSoapShader.GetValue() as Int) == 1
			PlayerREF.AddSpell(SoapEffectSpell, false)
		Else
			PlayerREF.AddSpell(SBBathSoapNoAnimationSpell, false)
		EndIf
		Utility.Wait(3)
		PlayerREF.PlayIdle(IdleStop)
		Utility.Wait(1)
		PlayerREF.PlayIdle(IdleWarmArms)
		Utility.Wait(2)
		PlayerREF.PlayIdle(IdleStop)
		Utility.Wait(1)
		if (SBBATHAnimatedSoapShader.GetValue() as Int) == 1
			PlayerREF.RemoveSpell(SoapEffectSpell)
		Else
			PlayerREF.RemoveSpell(SBBathSoapNoAnimationSpell)
		EndIf
		PlayerREF.PlayIdle(IdleWipeBrow)
		Sound.StopInstance(instanceID)	
		Utility.Wait(1.5)
	EndIf
	If SBBAthOutfitListBasket.GetSize() == 0
		PlayerREF.PlayIdle(IdleStop)
		Debug.SendAnimationEvent(PlayerRef, "IdleMQ203EsbernBookEnterInstant")
		Utility.Wait(3)
		PlayerREF.PlayIdle(IdleStop)
	EndIf
	EquipGear(PlayerRef)
		
	If(searched == 0)
		;Debug.SendAnimationEvent(PlayerRef, "IdleBracedPain")
		PlayerREF.PlayIdle(IdleBracedPain)
	EndIf
	;Debug.SendAnimationEvent(PlayerRef, "IdleStop")
	PlayerREF.PlayIdle(IdleStop)
	Utility.Wait(0.500000)
	Game.EnablePlayerControls()

endFunction

Int Function UnequipGear(Actor target)
	Formlist List
	Formlist ListL

	List = SBBAthOutfitList
	ListL = SBBAthLeftList
	
	;-------Armor--------------------------------------------------
	Int slotsChecked
	;	slotsChecked += 0x00100000
	;	slotsChecked += 0x00200000 
    slotsChecked += 0x80000000											;ignore reserved slots
    Int thisSlot = 0x01
    While(thisSlot < 0x80000000)
        If(Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot) 		;only check slots we haven't found anything equipped on already
            Armor thisArmor = target.GetWornForm(thisSlot) as Armor
            If(thisArmor)
				List.AddForm(thisArmor)
				target.UnequipItem(thisArmor, false, true)
                slotsChecked += thisArmor.GetSlotMask() 				;add all slots this item covers to our slotsChecked variable
            Else														;no armor was found on this slot
                slotsChecked += thisSlot
            EndIf
        EndIf
        thisSlot *= 2													;double the number to move on to the next slot
    EndWhile
	;--------------------------------------------------------------
	
	
	;-------Ammo---------------------------------------------------
	Int searched = 0
	If(target.IsEquipped(SBBAthAmmoList as Form))
		Int n = SBBAthAmmoList.GetSize()
		While(n > 0)
			n -= 1
			If(target.IsEquipped(SBBAthAmmoList.GetAt(n)))
				List.AddForm(SBBAthAmmoList.GetAt(n))
				target.UnequipItem(SBBAthAmmoList.GetAt(n), false, true)
				n = 0
				;Debug.Notification("Ammo found on List")
			EndIf
		EndWhile
		searched = 0
	Else
		Int k = 0
		While(k < 8)
			Form Arrows = Game.GetHotkeyBoundObject(k)
			If(Arrows.GetType() == 42)
				If(SBBAthAmmoList.Find(Arrows) == -1)
					SBBAthAmmoList.AddForm(Arrows)
					;Debug.Notification("New Ammo found in Hotkeys. Adding to Memory.")
				EndIf
				If(target.IsEquipped(Arrows))
					List.AddForm(Arrows)
					target.UnequipItem(Arrows, false, true)
				EndIf
			EndIf
			k += 1
		EndWhile
		
		If(target.WornHasKeyword(VendorItemArrow))
			PlayerREF.PlayIdle(IdleBracedPain)
			PlayerREF.PlayIdle(IdleStop)
			PlayerREF.PlayIdle(IdleStudy)
			;Debug.SendAnimationEvent(target, "IdleBracedPain")
			;Debug.SendAnimationEvent(target, "IdleStop")
			;Debug.SendAnimationEvent(target, "IdleStudy")
			;Debug.Notification("New Ammo detected. Searching inventory. Please Wait.")
			k = target.GetNumItems()
			While k > 0
				k -= 1
				Form Arrows = target.GetNthForm(k)
				If(Arrows.GetType() == 42)
					If(SBBAthAmmoList.Find(Arrows) == -1)
						SBBAthAmmoList.AddForm(Arrows)
						;Debug.Notification("New Ammo found in Inventory. Adding to Memory.")
					EndIf
					If(target.IsEquipped(Arrows))
						List.AddForm(Arrows)
						target.UnequipItem(Arrows, false, true)
					EndIf
				EndIf
			EndWhile
			;Debug.Notification("Search complete.")
			searched = 1
		Else
			searched = 0
		EndIf
	EndIf
	;--------------------------------------------------------------
	
	;-------Right Hand Weapons-------------------------------------
	Form RightWeapon = target.GetEquippedObject(1)
	If(RightWeapon as Weapon)
		List.AddForm(RightWeapon)
		target.UnequipItem(RightWeapon, false, true)
		;Debug.Notification("Primary Right Weapon saved")
	EndIf
	RightWeapon = target.GetEquippedObject(1)
	If(RightWeapon && !(RightWeapon as Spell))
		List.AddForm(RightWeapon)
		target.UnequipItem(RightWeapon, false, true)
		;Debug.Notification("Secondary Right Weapon/Item saved")
	EndIf
	;--------------------------------------------------------------
	
	;-------Left Hand Weapon/Shield--------------------------------
	Form LeftWeapon = target.GetEquippedObject(0)
	If(LeftWeapon && !(LeftWeapon as Spell))
		ListL.AddForm(LeftWeapon)
		target.UnequipItem(LeftWeapon, false, true)
		;Debug.Notification("Left Weapon/Shield/Item saved")
	EndIf
	;--------------------------------------------------------------
	
	Return searched
EndFunction


Function EquipGear(Actor target)
	Formlist List
	Formlist ListL

	List = SBBAthOutfitList
	ListL = SBBAthLeftList
	
	;-------Left Hand Weapon/Shield--------------------------------
	Form LeftItem = ListL.GetAt(0)
	If(LeftItem && target.GetItemCount(LeftItem) >= 1)
		target.EquipItemEx(LeftItem, 2, false, false)
	EndIf
	ListL.Revert()
	;--------------------------------------------------------------
	
	;-------Rest---------------------------------------------------
	Int i = List.GetSize()
	While(i >= 0)
		Form ListItem = List.GetAt(i)
		If(ListItem && target.GetItemCount(ListItem) >= 1)
			target.EquipItem(ListItem, false, true)
		EndIf
		i -= 1
	EndWhile
	List.Revert()
	;--------------------------------------------------------------
EndFunction

	
Function AddDawnguardAmmo()
	SBBAthAmmoList.AddForm(game.GetFormFromFile(2995, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(61856, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(61883, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(61884, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(95988, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(53401, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(61873, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(61879, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(61881, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(39072, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(39073, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(108888, "Dawnguard.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(65283, "Dawnguard.esm"))
	
	SBBAthDLC1Trigger.SetValue(1)
EndFunction


Function AddDragonbornAmmo()
	SBBAthAmmoList.AddForm(game.GetFormFromFile(96032, "Dragonborn.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(156217, "Dragonborn.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(156219, "Dragonborn.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(110287, "Dragonborn.esm"))
	SBBAthAmmoList.AddForm(game.GetFormFromFile(211361, "Dragonborn.esm"))
	
	SBBAthDLC2Trigger.SetValue(1)
EndFunction