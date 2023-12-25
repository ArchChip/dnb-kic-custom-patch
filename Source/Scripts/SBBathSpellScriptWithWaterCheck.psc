Scriptname SBBathSpellScriptWithWaterCheck extends activemagiceffect  
;===============  PROPERTIES  ==========================================;
Actor Property PlayerREF Auto
Message Property CleanMessage Auto
Message Property CleanRelaxMessage Auto
Message Property NoInnMessage Auto
Message Property NoWaterMessage Auto
Potion Property Soap Auto
Spell Property CleanSpell Auto 
Spell Property CleanRelaxSpell Auto 
Spell Property BathSpell Auto
FormList Property SBBathEffectFLST auto
Formlist Property SBBATHAliasesFLST Auto
Formlist Property SBBATHSoapItemList Auto
Formlist Property SBBATHLockedAliasesFLST Auto
Keyword Property LocTypeShowerInInns Auto
GlobalVariable Property WaterRestriction Auto
GlobalVariable Property Lastwashingtime Auto
GlobalVariable Property SBBATHFollowerSupport Auto; Follower Support
GlobalVariable Property SBBATHFollowerState Auto; Follower Support
GlobalVariable Property SBBATHLocationDirtyTimeVariation Auto
Quest Property SBBATHAliases Auto
;===============  Utilities   ==========================================;
Import Utility
Import Math
Import SBBathWaterCheck
;===============  VARIABLES   ==========================================;
Spell SpellForm
Actor TeammateActor
Actor LockedActor
Int TeammateFormListSize ;
int LockedTeammateFormListSize
int LockedTeammate
Bool IsSitting = false
;===============    EVENTS    ==========================================;
; Remove all Simple bathing Ex effect
Event OnInit()
If (PlayerREF.GetSitState() == 0)
	If ((WaterRestriction.GetValue())as Int) != 1 && SBBATHSoapItemList.HasForm(Soap);check water restriction
		If PlayerREF.GetCurrentLocation().HasKeyword(LocTypeShowerInInns);check if the player is in bathroom
			ClearEffect()
			ListTeammate()
		Else
			NoInnMessage.Show()
		EndIf
	Else
		ClearEffect()
		ListTeammate()
 	Endif
Else
	debug.notification("I cannot do that when I'm sitting.")
	IsSitting = True
EndIf
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
If IsInWater(akTarget)
	If !IsSitting
		If ((WaterRestriction.GetValue())as Int) != 1 && SBBATHSoapItemList.HasForm(Soap)
			If PlayerREF.GetCurrentLocation().HasKeyword(LocTypeShowerInInns);
				if akTarget == PlayerRef ;instead of Game.GetPlayer

				; Take a snapshot of the time when soap effect is applied
				Lastwashingtime.SetValue(GetCurrentGameTime())
				SBBATHLocationDirtyTimeVariation.SetValue(0)
				; add clean and soap effect

				PlayerREF.AddSpell(CleanRelaxSpell, false)
				CleanRelaxMessage.Show()
				PlayerREF.AddSpell(BathSpell, false)

				endif
			Else
			akCaster.AddItem(Soap As Potion, 1, abSilent = True)
			EndIf
		Else
			if akTarget == PlayerRef ;instead of Game.GetPlayer
		
				; Take a snapshot of the time when soap effect is applied
				Lastwashingtime.SetValue(GetCurrentGameTime())
				SBBATHLocationDirtyTimeVariation.SetValue(0)
			
				; add clean and soap effect

				If PlayerREF.GetCurrentLocation().HasKeyword(LocTypeShowerInInns) && SBBATHSoapItemList.HasForm(Soap)
					PlayerREF.AddSpell(CleanRelaxSpell, false)
					CleanRelaxMessage.Show()
				Else
					PlayerREF.AddSpell(CleanSpell, false)
					CleanMessage.Show()
				EndIf
				PlayerREF.AddSpell(BathSpell, false)
			
			endif
		EndIf
	Else
		akCaster.AddItem(Soap As Potion, 1, abSilent = True)	
	EndIf
Else
	akCaster.AddItem(Soap As Potion, 1, abSilent = True)

	if akTarget == PlayerRef
		NoWaterMessage.Show()
	endif
EndIf
EndEvent
;===============    Functions  ==========================================;
; Remove Magic effect from actor
Function ClearEffect()
	int CurrentSpell = 0
	int FormListSize = SBBathEffectFLST.GetSize()
	
	SBBATHFollowerState.setvalue(0)
	TeammateFormListSize = SBBATHAliasesFLST.GetSize()

	while ( CurrentSpell < FormListSize )
		SpellForm = SBBathEffectFLST.GetAt( CurrentSpell ) As Spell
		PlayerREF.RemoveSpell(SpellForm)
		;debug.notification("removing player debuff")
		If ((SBBATHFollowerSupport.getvalue()) as Int) == 1
		;debug.notification("test for follower")
			int CurrentAffectedTeammate = 0
			while ( CurrentAffectedTeammate < TeammateFormListSize )
				TeammateActor = SBBATHAliasesFLST.GetAt( CurrentAffectedTeammate ) As Actor
				;Debug.notification("Current loop " + (TeammateActor.getLeveledActorbase().getName() as String))
				TeammateActor.RemoveSpell(SpellForm)
				CurrentAffectedTeammate += 1
			endWhile
		EndIf
		CurrentSpell += 1
	endWhile
Endfunction

; Reinitialize teammate list
Function ListTeammate()
	; Reinitialize teammate list
	SBBATHAliases.Stop()
	int i = 0
    while !SBBATHAliases.IsStopped() && i < 50
       	Utility.Wait(0.1)
    	i += 1
    endWhile
	SBBATHAliasesFLST.Revert()
    SBBATHAliases.Start()

	; Add Locked teammate to the teammate formlist
	LockedTeammateFormListSize = SBBATHLockedAliasesFLST.GetSize()
	LockedTeammate = 0
	while ( LockedTeammate < LockedTeammateFormListSize )
		LockedActor = SBBATHLockedAliasesFLST.Getat(LockedTeammate) As Actor
		SBBATHAliasesFLST.AddForm(LockedActor)
		LockedTeammate += 1
	endWhile
Endfunction