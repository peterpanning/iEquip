ScriptName iEquip_NameFadeoutUpdateScript Extends Quest Hidden

Import UICallback

iEquip_WidgetCore Property WC Auto

int property targetName auto 							; 0 = Main name, 1 = Preselect name, 2 = Poison name
int property index auto 								; The index used to set the abIsXxxxNameShown bools to false on fadeout
int property clip auto 									; The index we're sending to flash for retrieving the correct name movieclip from the clip array

String WidgetRoot

Float fDelay
Float fDuration

bool bWaitingForNameFadeoutUpdate

function registerForNameFadeoutUpdate()
	WidgetRoot = WC.WidgetRoot
	
	if targetName == 0									; Targeting main name
		fDelay = WC.fMainNameFadeoutDelay
	elseIf targetName == 1								; Targeting preselect name
		fDelay = WC.fPreselectNameFadeoutDelay
	else 												; Targeting poison name
		fDelay = WC.fPoisonNameFadeoutDelay
	endIf
	
	fDuration = WC.fNameFadeoutDuration 				; The fadeout duration is a common value for all three names
	
	if WC.bNameFadeoutEnabled && fDelay > 0
		RegisterForSingleUpdate(fDelay)
		bWaitingForNameFadeoutUpdate = true
	endIf
endFunction

function unregisterForNameFadeoutUpdate()
	UnregisterForUpdate()
	bWaitingForNameFadeoutUpdate = false
endFunction

event OnUpdate()
	
	if bWaitingForNameFadeoutUpdate 					;Failsafe bool to block OnUpdate if triggered from another script on the quest
		bWaitingForNameFadeoutUpdate = false
		if targetName == 2
			WC.abIsPoisonNameShown[0] = false
		else
			WC.abIsNameShown[index] = false
		endIf
		Int iHandle = UICallback.Create("HUD Menu", WidgetRoot + ".tweenWidgetNameAlpha")
		If(iHandle)
			UICallback.PushInt(iHandle, clip) 			; The index of the name clip we're targeting
			UICallback.PushFloat(iHandle, 0) 			; Target alpha which for FadeOut is 0
			UICallback.PushFloat(iHandle, fDuration) 	; FadeOut duration
			UICallback.Send(iHandle)
		EndIf
	endIf
endEvent