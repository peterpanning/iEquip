
scriptName iEquip_PotionScript extends Quest

import _Q2C_Functions
import AhzMoreHudIE
import iEquip_StringExt
import iEquip_FormExt
import iEquip_ActorExt
import UI

iEquip_WidgetCore Property WC Auto
iEquip_PlayerEventHandler Property EH Auto

actor property PlayerRef auto

FormList Property iEquip_AllCurrentItemsFLST Auto
FormList Property iEquip_PotionItemsFLST Auto
Formlist Property iEquip_GeneralBlacklistFLST Auto ;To block individual potions and poisons previously manually removed through the queue menus from being auto-added again. Does not affect Potion Groups

String HUD_MENU = "HUD Menu"
String WidgetRoot

int[] aiPotionQ
int iConsumableQ
int iPoisonQ

MagicEffect[] aStrongestEffects
MagicEffect Property AlchRestoreHealth Auto ;0003eb15
MagicEffect Property AlchFortifyHealth Auto ;0003eaf3
MagicEffect Property AlchFortifyHealRate Auto ;0003eb06
MagicEffect Property AlchRestoreMagicka Auto ;0003eb17
MagicEffect Property AlchFortifyMagicka Auto ;0003eaf8
MagicEffect Property AlchFortifyMagickaRate Auto ;0003eb07
MagicEffect Property AlchRestoreStamina Auto ;0003eb16
MagicEffect Property AlchFortifyStamina Auto ;0003eaf9
MagicEffect Property AlchFortifyStaminaRate Auto ;0003eb08

MagicEffect[] aConsummateEffects
MagicEffect Property AlchRestoreHealthAll Auto ;000ffa03
MagicEffect Property AlchRestoreMagickaAll Auto ;000ffa04
MagicEffect Property AlchRestoreStaminaAll Auto ;000ffa05

MagicEffect[] aPoisonEffects
MagicEffect Property AlchDamageHealth Auto ;0003eb42
MagicEffect Property AlchDamageHealthDuration Auto ;0010aa4a
MagicEffect Property AlchDamageHealthRavage Auto ;00073f26
MagicEffect Property AlchDamageMagicka Auto ;0003a2b6
MagicEffect Property AlchDamageMagickaDuration Auto ;0010de5f
MagicEffect Property AlchDamageMagickaRate Auto ;00073f2B
MagicEffect Property AlchDamageMagickaRavage Auto ;00073f27
MagicEffect Property AlchDamageSpeed Auto ;00073f25
MagicEffect Property AlchDamageStamina Auto ;0003a2b6
MagicEffect Property AlchDamageStaminaDuration Auto ;0010de5f
MagicEffect Property AlchDamageStaminaRate Auto ;00073f2B
MagicEffect Property AlchDamageStaminaRavage Auto ;00073f27
MagicEffect Property AlchInfluenceAggUp Auto ;00073f29
MagicEffect Property AlchInfluenceAggUpCombo Auto ;000ff9f8
MagicEffect Property AlchInfluenceAggUpComboCOPY0000 Auto ;0010fdd4
MagicEffect Property AlchInfluenceConfDown Auto ;00073f20
MagicEffect Property AlchParalysis Auto ;00073f30
MagicEffect Property AlchWeaknessFire Auto ;00073f2D
MagicEffect Property AlchWeaknessFrost Auto ;00073f2E
MagicEffect Property AlchWeaknessMagic Auto ;00073f51
MagicEffect Property AlchWeaknessPoison Auto ;00090042
MagicEffect Property AlchWeaknessShock Auto ;00073f2F

int Property iPotionsFirstChoice = 0 Auto Hidden
int Property iPotionsSecondChoice = 1 Auto Hidden
int Property iPotionsThirdChoice = 2 Auto Hidden

string[] asPotionGroups
String[] asPoisonIconNames
string[] asActorValues
int[] aiActorValues

int property iPotionSelectChoice = 1 auto hidden ; 0 = Always use strongest, 1 = Smart Select, 2 = Always Use Weakest
float property fSmartConsumeThreshold = 0.4 auto hidden

bool bIsCACOLoaded = false
MagicEffect[] aCACO_RestoreEffects
bool bIsPAFLoaded
MagicEffect[] aPAF_RestoreEffects

bool bMoreHUDLoaded = false

bool bAddedToQueue = false
int iQueueToSort = -1 ;Only used if potion added by onPotionAdded

bool property bAutoAddPoisons = true auto hidden
bool property bAutoAddPotions = true auto hidden
bool property bAutoAddConsumables = true auto hidden
bool Property bQuickRestoreUseSecondChoice = true Auto Hidden
bool property bFlashPotionWarning = true auto hidden
int property iEmptyPotionQueueChoice = 0 auto hidden
bool property bEnableRestorePotionWarnings = true auto hidden
bool property bNotificationOnLowRestorePotions = true auto hidden

bool bInitialised = false

event OnInit()
    debug.trace("iEquip_PotionScript OnInit start")
    GotoState("")
    bInitialised = false
    WidgetRoot = WC.WidgetRoot
    aiPotionQ = new int[9]
    aStrongestEffects = new MagicEffect[9]
    aStrongestEffects[0] = AlchRestoreHealth
    aStrongestEffects[1] = AlchFortifyHealth
    aStrongestEffects[2] = AlchFortifyHealRate
    aStrongestEffects[3] = AlchRestoreMagicka
    aStrongestEffects[4] = AlchFortifyMagicka
    aStrongestEffects[5] = AlchFortifyMagickaRate
    aStrongestEffects[6] = AlchRestoreStamina
    aStrongestEffects[7] = AlchFortifyStamina
    aStrongestEffects[8] = AlchFortifyStaminaRate

    aConsummateEffects = new MagicEffect[3]
    aConsummateEffects[0] = AlchRestoreHealthAll
    aConsummateEffects[1] = AlchRestoreMagickaAll
    aConsummateEffects[2] = AlchRestoreStaminaAll

    aPoisonEffects = new MagicEffect[22]
    aPoisonEffects[0] = AlchDamageHealth
    aPoisonEffects[1] = AlchDamageHealthDuration
    aPoisonEffects[2] = AlchDamageHealthRavage
    aPoisonEffects[3] = AlchDamageMagicka
    aPoisonEffects[4] = AlchDamageMagickaDuration
    aPoisonEffects[5] = AlchDamageMagickaRate
    aPoisonEffects[6] = AlchDamageMagickaRavage
    aPoisonEffects[7] = AlchDamageSpeed
    aPoisonEffects[8] = AlchDamageStamina
    aPoisonEffects[9] = AlchDamageStaminaDuration
    aPoisonEffects[10] = AlchDamageStaminaRate
    aPoisonEffects[11] = AlchDamageStaminaRavage
    aPoisonEffects[12] = AlchInfluenceAggUp
    aPoisonEffects[13] = AlchInfluenceAggUpCombo
    aPoisonEffects[14] = AlchInfluenceAggUpComboCOPY0000
    aPoisonEffects[15] = AlchInfluenceConfDown
    aPoisonEffects[16] = AlchParalysis
    aPoisonEffects[17] = AlchWeaknessFire
    aPoisonEffects[18] = AlchWeaknessFrost
    aPoisonEffects[19] = AlchWeaknessMagic
    aPoisonEffects[20] = AlchWeaknessPoison
    aPoisonEffects[21] = AlchWeaknessShock

    asPoisonIconNames = new String[22]
    asPoisonIconNames[0] = "PoisonHealth"
    asPoisonIconNames[1] = "PoisonHealth"
    asPoisonIconNames[2] = "PoisonHealth"
    asPoisonIconNames[3] = "PoisonMagicka"
    asPoisonIconNames[4] = "PoisonMagicka"
    asPoisonIconNames[5] = "PoisonMagicka"
    asPoisonIconNames[6] = "PoisonMagicka"
    asPoisonIconNames[7] = "PoisonStamina"
    asPoisonIconNames[8] = "PoisonStamina"
    asPoisonIconNames[9] = "PoisonStamina"
    asPoisonIconNames[10] = "PoisonStamina"
    asPoisonIconNames[11] = "PoisonStamina"
    asPoisonIconNames[12] = "PoisonFrenzy"
    asPoisonIconNames[13] = "PoisonFrenzy"
    asPoisonIconNames[14] = "PoisonFrenzy"
    asPoisonIconNames[15] = "PoisonFear"
    asPoisonIconNames[16] = "PoisonParalysis"
    asPoisonIconNames[17] = "PoisonWeaknessFire"
    asPoisonIconNames[18] = "PoisonWeaknessFrost"
    asPoisonIconNames[19] = "PoisonWeaknessMagic"
    asPoisonIconNames[20] = "PoisonWeaknessPoison"
    asPoisonIconNames[21] = "PoisonWeaknessShock"

    asActorValues = new string[3]
    asActorValues[0] = "Health"
    asActorValues[1] = "Magicka"
    asActorValues[2] = "Stamina"

    aiActorValues = new int[3]
    aiActorValues[0] = 24 ;Health
    aiActorValues[1] = 25 ;Magicka
    aiActorValues[2] = 26 ;Stamina

    asPotionGroups = new string[3]
    asPotionGroups[0] = "$iEquip_common_HealthPotions"
    asPotionGroups[1] = "$iEquip_common_MagickaPotions"
    asPotionGroups[2] = "$iEquip_common_StaminaPotions"
    
    bInitialised = true
    debug.trace("iEquip_PotionScript OnInit end")
endEvent

;Called from OnPlayerLoadGame on the PlayerEventHandler script
function initialise()
    debug.trace("iEquip_PotionScript initialise start")
    while !bInitialised
        Utility.WaitMenuMode(0.01)
    endWhile
    WidgetRoot = WC.WidgetRoot
    bMoreHUDLoaded = WC.bMoreHUDLoaded
    WC.abPotionGroupEmpty[0] = true
    WC.abPotionGroupEmpty[1] = true
    WC.abPotionGroupEmpty[2] = true

    aCACO_RestoreEffects = new MagicEffect[9]
    if Game.GetModByName("Complete Alchemy & Cooking Overhaul.esp") != 255
        bIsCACOLoaded = true
        aCACO_RestoreEffects[0] = Game.GetFormFromFile(0x001AA0B6, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[1] = Game.GetFormFromFile(0x001AA0B7, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[2] = Game.GetFormFromFile(0x001AA0B8, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[3] = Game.GetFormFromFile(0x001B42BE, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[4] = Game.GetFormFromFile(0x001B42BF, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[5] = Game.GetFormFromFile(0x001B42C0, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[6] = Game.GetFormFromFile(0x001B42BB, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[7] = Game.GetFormFromFile(0x001B42BC, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
        aCACO_RestoreEffects[8] = Game.GetFormFromFile(0x001B42BD, "Complete Alchemy & Cooking Overhaul.esp") as MagicEffect
    else
        bIsCACOLoaded = false
    endIf
    aPAF_RestoreEffects = new MagicEffect[6]
    if Game.GetModByName("PotionAnimatedFix.esp") != 255
        bIsPAFLoaded = true
        aPAF_RestoreEffects[0] = Game.GetFormFromFile(0x006B2D4, "PotionAnimatedFix.esp") as MagicEffect
        aPAF_RestoreEffects[1] = Game.GetFormFromFile(0x00754DB, "PotionAnimatedFix.esp") as MagicEffect
        aPAF_RestoreEffects[2] = Game.GetFormFromFile(0x00754DC, "PotionAnimatedFix.esp") as MagicEffect
        aPAF_RestoreEffects[3] = Game.GetFormFromFile(0x00754DD, "PotionAnimatedFix.esp") as MagicEffect
        aPAF_RestoreEffects[4] = Game.GetFormFromFile(0x00754DE, "PotionAnimatedFix.esp") as MagicEffect
        aPAF_RestoreEffects[5] = Game.GetFormFromFile(0x00754DF, "PotionAnimatedFix.esp") as MagicEffect
    else
        bIsPAFLoaded = false
    endIf
    debug.trace("iEquip_PotionScript initialise - bIsCACOLoaded: " + bIsCACOLoaded + ", bIsPAFLoaded: " + bIsPAFLoaded)
    findAndSortPotions()
endFunction

function InitialisePotionQueueArrays(int consQ, int poisQ)
    debug.trace("iEquip_PotionScript InitialisePotionQueueArrays start")
    iConsumableQ = consQ
    iPoisonQ = poisQ
    if aiPotionQ[0] == 0
        aiPotionQ[0] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "healthRestoreQ", aiPotionQ[0])
    endIf
    if aiPotionQ[1] == 0
        aiPotionQ[1] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "healthFortifyQ", aiPotionQ[1])
    endIf
    if aiPotionQ[2] == 0
        aiPotionQ[2] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "healthRegenQ", aiPotionQ[2])
    endIf
    if aiPotionQ[3] == 0
        aiPotionQ[3] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "magickaRestoreQ", aiPotionQ[3])
    endIf
    if aiPotionQ[4] == 0
        aiPotionQ[4] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "magickaFortifyQ", aiPotionQ[4])
    endIf
    if aiPotionQ[5] == 0
        aiPotionQ[5] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "magickaRegenQ", aiPotionQ[5])
    endIf
    if aiPotionQ[6] == 0
        aiPotionQ[6] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "staminaRestoreQ", aiPotionQ[6])
    endIf
    if aiPotionQ[7] == 0
        aiPotionQ[7] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "staminaFortifyQ", aiPotionQ[7])
    endIf
    if aiPotionQ[8] == 0
        aiPotionQ[8] = JArray.object()
        JMap.setObj(WC.iEquipQHolderObj, "staminaRegenQ", aiPotionQ[8])
    endIf
    int i = 0
    while i < 9
        debug.trace("iEquip_PotionScript InitialisePotionQueueArrays - aiPotionQ["+i+"] contains " + aiPotionQ[i])
        i += 1
    endWhile
    debug.trace("iEquip_PotionScript InitialisePotionQueueArrays end")
endfunction

function initialisemoreHUDArray()
    debug.trace("iEquip_PotionScript initialisemoreHUDArray start")
    int jItemIDs = jArray.object()
    int jIconNames = jArray.object()
    int Q = 0
    
    while Q < 9
        int queueLength = JArray.count(aiPotionQ[Q])
        int i = 0
        debug.trace("iEquip_PotionScript initialisemoreHUDArray - Q" + Q + " contains " + queueLength + " potions")
        
        while i < queueLength
            form itemForm = jMap.getForm(jArray.getObj(aiPotionQ[Q], i), "iEquipForm")
            if !itemForm
                jArray.eraseIndex(aiPotionQ[Q], i)
                queueLength -= 1
            endIf
            int itemID = jMap.getInt(jArray.getObj(aiPotionQ[Q], i), "iEquipItemID")
            debug.trace("iEquip_PotionScript initialisemoreHUDArray Q: " + Q + ", i: " + i + ", itemID: " + itemID + ", " + jMap.getStr(jArray.getObj(aiPotionQ[Q], i), "iEquipName"))
            if itemID == 0
                itemID = WC.createItemID(itemForm.GetName(), itemForm.GetFormID())
                jMap.setInt(jArray.getObj(aiPotionQ[Q], i), "iEquipItemID", itemID)
            endIf
            if itemID != 0
                jArray.addInt(jItemIDs, jMap.getInt(jArray.getObj(aiPotionQ[Q], i), "iEquipItemID"))
                jArray.addStr(jIconNames, "iEquipQ.png")
            endIf
            i += 1
        endWhile

        Q += 1
    endWhile
    debug.trace("iEquip_PotionScript initialisemoreHUDArray - jItemIds contains " + jArray.count(jItemIDs) + " entries")
    debug.trace("iEquip_PotionScript initialisemoreHUDArray - jIconNames contains " + jArray.count(jIconNames) + " entries")
    if jArray.count(jItemIDs) > 0
        int[] itemIDs = utility.CreateIntArray(jArray.count(jItemIDs))
        string[] iconNames = utility.CreateStringArray(jArray.count(jIconNames))
        jArray.writeToIntegerPArray(jItemIDs, itemIDs)
        jArray.writeToStringPArray(jIconNames, iconNames)
        debug.trace("iEquip_PotionScript initialisemoreHUDArray - itemIDs contains " + itemIDs.Length + " entries with " + itemIDs[0] + " in index 0")
        debug.trace("iEquip_PotionScript initialisemoreHUDArray - iconNames contains " + iconNames.Length + " entries with " + iconNames[0] + " in index 0")
        AhzMoreHudIE.AddIconItems(itemIDs, iconNames)
    endIf
    debug.trace("iEquip_PotionScript initialisemoreHUDArray end")
endFunction

function findAndSortPotions()
    debug.trace("iEquip_PotionScript findAndSortPotions start")
    ;Count the number of potion items currently in the players inventory
    int numFound = GetNumItemsOfType(PlayerRef, 46)
    ;If any potions found
    if numFound > 0
        int i = 0
        int count
        int iIndex
        int[] openingQSizes = new int[10]
        while i < 9
            iIndex = 0
            count = jArray.count(aiPotionQ[i])
            ;Check and remove any potions which are no longer in the players inventory (fallback as there shouldn't be any!)
            while iIndex < count
                if PlayerRef.GetItemCount(jMap.getForm(jArray.getObj(aiPotionQ[i], iIndex), "iEquipForm")) < 1
                    iEquip_PotionItemsFLST.RemoveAddedForm(jMap.getForm(jArray.getObj(aiPotionQ[i], iIndex), "iEquipForm"))
                    EH.updateEventFilter(iEquip_PotionItemsFLST)
                    removePotionFromQueue(i, iIndex)
                endIf
                iIndex += 1
            endWhile
            ;Store the opening potion queue lengths for comparison later
            openingQSizes[i] = jArray.count(aiPotionQ[i])
            i += 1
        endWhile
        openingQSizes[9] = jArray.count(iPoisonQ)
        i = 0
        potion foundPotion
        ;Add each potion to the relevant queue
        while i < numFound
            foundPotion = GetNthFormOfType(PlayerRef, 46, i) as potion
            checkAndAddToPotionQueue(foundPotion)
            i += 1
        endWhile
        ;Now check if anything has been added to each potion queue and resort each if required
        i = 0
        while i < 9
            debug.trace("iEquip_PotionScript findAndSortPotions - aiPotionQ: " + i + ", openingQSizes: " + openingQSizes[i] + ", new count: " + jArray.count(aiPotionQ[i]))
            if jArray.count(aiPotionQ[i]) > openingQSizes[i]
                sortPotionQueue(i)
            endIf
            i += 1
        endWhile
        if jArray.count(iPoisonQ) > openingQSizes[9]
            sortPoisonQueue()
        endIf 
        ;Finally get the group counts and update the potionGroupEmpty bool array
        i = 0
        while i < 3
            numFound = getPotionGroupCount(i)
            if numFound > 0
                WC.abPotionGroupEmpty[i] = false
                debug.trace("iEquip_PotionScript findAndSortPotions - potionGroup: " + i + ", numFound: " + numFound + ", potionGroupEmpty[" + i + "]: " + WC.abPotionGroupEmpty[i])
            endIf
            i += 1
        endWhile
    else
        debug.trace("iEquip_PotionScript findAndSortPotions - No health, stamina or magicka potions found in players inventory")
    endIf
    debug.trace("iEquip_PotionScript findAndSortPotions end")
endFunction

function onPotionAdded(form newPotion)
    debug.trace("iEquip_PotionScript onPotionAdded start")
    debug.trace("iEquip_PotionScript onPotionAdded - newPotion: " + newPotion.GetName())
    checkAndAddToPotionQueue(newPotion as potion)
    if bAddedToQueue && iQueueToSort != -1
        if iQueueToSort == iPoisonQ
            sortPoisonQueue()
        elseIf iQueueToSort != iConsumableQ
            sortPotionQueue(iQueueToSort)
        endIf
    endIf
    debug.trace("iEquip_PotionScript onPotionAdded end")
endFunction

function onPotionRemoved(form removedPotion)
    debug.trace("iEquip_PotionScript onPotionRemoved start")
    GotoState("PROCESSING")
    debug.trace("iEquip_PotionScript onPotionRemoved - removedPotion: " + removedPotion.GetName())
    potion thePotion = removedPotion as potion
    int foundPotion
    int itemCount = PlayerRef.GetItemCount(removedPotion)
    if thePotion.isPoison()
        debug.trace("iEquip_PotionScript onPotionRemoved - removedPotion is a poison")
        if itemCount < 1
            foundPotion = findInQueue(iPoisonQ, removedPotion)
            if foundPotion != -1
                WC.removeItemFromQueue(4, foundPotion, false, false, true, false)
            endIf
        elseIf WC.asCurrentlyEquipped[4] == removedPotion.GetName()
            WC.setSlotCount(4, itemCount)
        endIf
    else
    	;Check and remove from the main consumable queue first
    	if itemCount < 1
            foundPotion = findInQueue(iConsumableQ, removedPotion)
            if foundPotion != -1
                WC.removeItemFromQueue(3, foundPotion, false, false, true, false)
            endIf
        elseIf WC.asCurrentlyEquipped[3] == removedPotion.GetName()
            WC.setSlotCount(3, itemCount)
        endIf
    	;Then check and remove from the potion groups
    	if !thePotion.IsFood()
	        int Q = getPotionQueue(thePotion)
	        if Q >= 0
	            int group
	            string potionGroup
	            if Q < 3
	                group = 0
	                potionGroup = "$iEquip_common_HealthPotions"
	            elseIf Q < 6
	                group = 1
	                potionGroup = "$iEquip_common_MagickaPotions"
	            else
	                group = 2
	                potionGroup = "$iEquip_common_StaminaPotions"
	            endIf
	            if WC.asCurrentlyEquipped[3] == potionGroup
	                WC.setSlotCount(3, getPotionGroupCount(group))
	            endIf
	        endIf
	        if itemCount < 1
	            iEquip_PotionItemsFLST.RemoveAddedForm(removedPotion)
	            EH.updateEventFilter(iEquip_PotionItemsFLST)
	            foundPotion = findInQueue(aiPotionQ[Q], removedPotion)
	            if foundPotion != -1
	                removePotionFromQueue(Q, foundPotion)
	            endIf
	        endIf
	    endIf
    endIf
    GotoState("")
    debug.trace("iEquip_PotionScript onPotionRemoved end")
endFunction

function removePotionFromQueue(int Q, int targetPotion)
    debug.trace("iEquip_PotionScript removePotionFromQueue start")
    debug.trace("iEquip_PotionScript removePotionFromQueue - Q: " + Q + ", targetPotion: " + targetPotion)
    if bMoreHUDLoaded
        AhzMoreHudIE.RemoveIconItem(jMap.getInt(jArray.getObj(aiPotionQ[Q], targetPotion), "iEquipItemID"))
    endIf
    ;First we need to remove the potion from the relevant queue
    jArray.eraseIndex(aiPotionQ[Q], targetPotion)
    ;Now we need to check to see if any potions remain in the three potion queues within the potion group we've just removed from
    string potionGroup
    if Q < 3
        Q = 0
        potionGroup = "$iEquip_common_HealthPotions"
    elseIf Q < 6
        Q = 1
        potionGroup = "$iEquip_common_MagickaPotions"
    else
        Q = 2
        potionGroup = "$iEquip_common_StaminaPotions"
    endIf
    ;If all three arrays in the group are empty then we need to update the widget accordingly
    if getPotionGroupCount(Q) < 1
        ;Flag the group as empty in WidgetCore for cycling
        WC.abPotionGroupEmpty[Q] = true
        ;Check if it's the currently shown item in the consumable slot
        if WC.asCurrentlyEquipped[3] == potionGroup
            debug.trace("iEquip_PotionScript removePotionFromQueue - potion group is currently shown")
            ;Check and flash empty warning if enabled
            if bFlashPotionWarning
                debug.trace("iEquip_PotionScript removePotionFromQueue - should be flashing empty warning now - Q: " + Q)
                UI.InvokeInt(HUD_MENU, WidgetRoot + ".runPotionFlashAnimation", Q)
                Utility.WaitMenuMode(1.4)
            endIf
            ;Finally check if we're fading icon or cycling to next slot
            if iEmptyPotionQueueChoice == 0 ;Fade icon
                debug.trace("iEquip_PotionScript removePotionFromQueue - should be fading now")
                WC.checkAndFadeConsumableIcon(true)
            else
                debug.trace("iEquip_PotionScript removePotionFromQueue - should be cycling forward now")
                WC.cycleSlot(3)
            endIf
        endIf
    endIf
    debug.trace("iEquip_PotionScript removePotionFromQueue end")
endFunction

function removeGroupedPotionsFromConsumableQueue(int potionGroup)
    debug.trace("iEquip_PotionScript removeGroupedPotionsFromConsumableQueue start")
    int Q = potionGroup * 3
    int maxQ = Q + 3
    int i
    int queueLength
    int targetArray
    while Q < maxQ
        targetArray = aiPotionQ[Q]
        queueLength = jArray.count(targetArray)
        while i < queueLength
            if findInQueue(iConsumableQ, jMap.getForm(jArray.getObj(targetArray, i), "iEquipForm")) != -1
                jArray.eraseIndex(iConsumableQ, i)
            endIf
            i += 1
        endWhile
        i = 0
        Q += 1
    endWhile
    debug.trace("iEquip_PotionScript removeGroupedPotionsFromConsumableQueue end")
endFunction

function addIndividualPotionsToQueue(int potionGroup)
    debug.trace("iEquip_PotionScript addIndividualPotionsToQueue start")
    int Q = potionGroup * 3
    int maxQ = Q + 3
    int i
    int queueLength
    int targetArray
    while Q < maxQ
        targetArray = aiPotionQ[Q]
        queueLength = jArray.count(targetArray)
        while i < queueLength
            if findInQueue(iConsumableQ, jMap.getForm(jArray.getObj(targetArray, i), "iEquipForm")) == -1
                jMap.setStr(jArray.getObj(targetArray, i), "iEquipIcon", getPotionIcon(jMap.getForm(jArray.getObj(targetArray, i), "iEquipForm") as potion))
                jArray.addObj(iConsumableQ, jArray.getObj(targetArray, i))
            endIf
            i += 1
        endWhile
        i = 0
        Q += 1
    endWhile
    debug.trace("iEquip_PotionScript addIndividualPotionsToQueue end")
endFunction

int function getPotionGroupCount(int potionGroup)
    debug.trace("iEquip_PotionScript getPotionGroupCount start")
    debug.trace("iEquip_PotionScript getPotionGroupCount - potionGroup: " + potionGroup)
    int count
    int Q = potionGroup * 3
    int maxQ = Q + 3
    int i = 0
    int queueLength
    int targetArray
    int currentCount
    while Q < maxQ
        targetArray = aiPotionQ[Q]
        queueLength = jArray.count(targetArray)
        debug.trace("iEquip_PotionScript getPotionGroupCount - currently checking Q: " + Q + ", queueLength: " + queueLength)
        while i < queueLength
            currentCount = count
            count += PlayerRef.GetItemCount(jMap.getForm(jArray.getObj(targetArray, i), "iEquipForm"))
            debug.trace("iEquip_PotionScript getPotionGroupCount - " + (count - currentCount) + " potions found in index " + i + " in potion queue " + Q)
            i += 1
        endWhile
        i = 0
        Q += 1
    endWhile
    debug.trace("iEquip_PotionScript getPotionGroupCount returning count: " + count)
    debug.trace("iEquip_PotionScript getPotionGroupCount end")
    return count
endFunction

int function getRestoreCount(int potionGroup)
    debug.trace("iEquip_PotionScript getRestoreCount start")
    debug.trace("iEquip_PotionScript getRestoreCount - potionGroup: " + potionGroup)
    int count
    int targetArray = aiPotionQ[potionGroup * 3]
    int queueLength = jArray.count(targetArray)
    int i
    while i < queueLength
        count += PlayerRef.GetItemCount(jMap.getForm(jArray.getObj(targetArray, i), "iEquipForm"))
        i += 1
    endWhile
    debug.trace("iEquip_PotionScript getRestoreCount returning count: " + count)
    debug.trace("iEquip_PotionScript getRestoreCount end")
    return count
endFunction

int function getPotionQueue(potion potionToCheck)
    debug.trace("iEquip_PotionScript getPotionQueue start")
    int index = potionToCheck.GetCostliestEffectIndex()
    magicEffect strongestEffect = potionToCheck.GetNthEffectMagicEffect(index)
    debug.trace("iEquip_PotionScript getPotionQueue - " + potionToCheck.GetName() + " CostliestEffectIndex: " + index + ", strongest magic effect: " + strongestEffect as string)
    ;Decide which potion queue it should be added to
    int Q = aStrongestEffects.find(strongestEffect) ;Returns -1 if not found
    ;If it's not a regular effect check for a consummate effect
    if Q < 0
        Q = aConsummateEffects.find(strongestEffect) ;Puts ultimate/consummate potions into the Restore queues (0,3,6)
        if Q != -1
            Q = Q * 3
        endIf
    endIf
    ;If we've not found a vanilla effect check if CACO is loaded and if so check for a CACO restore effect
    if Q < 0 && bIsCACOLoaded
        Q = aCACO_RestoreEffects.find(strongestEffect) ;Returns -1 if not found
        debug.trace("iEquip_PotionScript getPotionQueue - checking for a CACO restore effect, Q = " + Q)
        if Q != -1
            if Q < 3 ;AlchRestoreHealth_1sec, AlchRestoreHealth_5sec, AlchRestoreHealth_10sec
                Q = 0 ;Health Restore
            elseIf Q < 6 ;AlchRestoreMagicka_1sec, AlchRestoreMagicka_5sec, AlchRestoreMagicka_10sec
                Q = 3 ;Magicka Restore
            elseIf Q < 9 ;AlchRestoreStamina_1sec, AlchRestoreStamina_5sec, AlchRestoreStamina_10sec
                Q = 6 ;Stamina Restore
            endIf
        endIf
        debug.trace("iEquip_PotionScript getPotionQueue - CACO restore effect, final Q value = " + Q)
    endIf
    ;Finally check if PotionAnimatedFix is loaded and check for one of its DUPLICATE restore effects
    if Q < 0 && bIsPAFLoaded
        Q = aPAF_RestoreEffects.find(strongestEffect)
        debug.trace("iEquip_PotionScript getPotionQueue - checking for a PAF restore effect, Q = " + Q)
        if Q != -1
            if Q < 2 ;AlchRestoreHealthDUPLICATE001 or AlchRestoreHealthAllDUPLICATE001
                Q = 0 ;Health Restore
            elseIf Q < 4 ;AlchRestoreMagickaDUPLICATE001 or AlchRestoreMagickaAllDUPLICATE001
                Q = 3 ;Magicka Restore
            else ;AlchRestoreStaminaDUPLICATE001 or AlchRestoreStaminaAllDUPLICATE001
                Q = 6 ;Stamina Restore
            endIf
        endIf
        debug.trace("iEquip_PotionScript getPotionQueue - PAF restore effect, final Q value = " + Q)
    endIf
    ;If it's not a health, magicka or stamina potion then there's nothing to do here
    if Q < 0
        debug.trace("iEquip_PotionScript getPotionQueue -" + potionToCheck.GetName() + " does not appear to be a health, stamina or magicka potion")
    endIf
    debug.trace("iEquip_PotionScript getPotionQueue - returning: Q = " + Q)
    debug.trace("iEquip_PotionScript getPotionQueue end")
    return Q
endFunction

function checkAndAddToPotionQueue(potion foundPotion)
    debug.trace("iEquip_PotionScript checkAndAddToPotionQueue start")
    ;Check if the nth potion is a poison or a food and switch functions if required
    bAddedToQueue = false
    if foundPotion.isPoison() && bAutoAddPoisons && !iEquip_GeneralBlacklistFLST.HasForm(foundPotion as form)
        checkAndAddToPoisonQueue(foundPotion)

    elseIf foundPotion.isFood() && bAutoAddConsumables && !iEquip_GeneralBlacklistFLST.HasForm(foundPotion as form)
        checkAndAddToConsumableQueue(foundPotion)

    else
        debug.trace("iEquip_PotionScript checkAndAddToPotionQueue - foundPotion: " + foundPotion.GetName())
        int Q = getPotionQueue(foundPotion)
        int group
        string potionGroup
        if Q < 3
            group = 0
            potionGroup = "$iEquip_common_HealthPotions"
        elseIf Q < 6
            group = 1
            potionGroup = "$iEquip_common_MagickaPotions"
        else
            group = 2
            potionGroup = "$iEquip_common_StaminaPotions"
        endIf
        ;Check it isn't already in the chosen queue and add it if not. This needs to be done regardless of whether potion groups are enabled or not, so they remain populated in case the user later wishes to enable them
        form potionForm = foundPotion as form            
        if Q > -1 && findInQueue(aiPotionQ[Q], potionForm) == -1
            string potionName = foundPotion.GetName()
            int itemID = WC.createItemID(potionName, potionForm.GetFormID())
            int potionObj = jMap.object()
            jMap.setForm(potionObj, "iEquipForm", potionForm)
            jMap.setStr(potionObj, "iEquipName", potionName)
            jMap.setStr(potionObj, "iEquipIcon", getPotionIcon(foundPotion))
            jMap.setFlt(potionObj, "iEquipStrength", foundPotion.GetNthEffectMagnitude(foundPotion.GetCostliestEffectIndex()))
            jMap.setInt(potionObj, "iEquipItemID", itemID)
            jArray.addObj(aiPotionQ[Q], potionObj)
            iEquip_PotionItemsFLST.AddForm(potionForm)
        	EH.updateEventFilter(iEquip_PotionItemsFLST)
            if bMoreHUDLoaded
                AhzMoreHudIE.AddIconItem(itemID, "iEquipQ.png")
            endIf
            debug.trace("iEquip_PotionScript checkAndAddToPotionQueue -" + potionName + " added to the " + aStrongestEffects[Q].GetName() + " queue")
            bAddedToQueue = true
            iQueueToSort = Q
            WC.abPotionGroupEmpty[group] = false
        endIf
        ;If it isn't a grouped potion, or if potion grouping is disabled then if bAutoAddPotions is enabled add it directly to the consumable queue
        if bAutoAddPotions && (Q == -1 || !WC.bPotionGrouping || !WC.abPotionGroupEnabled[group]) && !iEquip_GeneralBlacklistFLST.HasForm(foundPotion as form)
	        checkAndAddToConsumableQueue(foundPotion, true)
        elseIf WC.asCurrentlyEquipped[3] == potionGroup
            WC.setSlotCount(3, getPotionGroupCount(group))
            if WC.bConsumableIconFaded
                WC.checkAndFadeConsumableIcon(false)
            endIf
        endIf

    endIf
    debug.trace("iEquip_PotionScript checkAndAddToPotionQueue end")
endFunction

function checkAndAddToPoisonQueue(potion foundPoison)
    debug.trace("iEquip_PotionScript checkAndAddToPoisonQueue start")
    string poisonName = foundPoison.GetName()
    debug.trace("iEquip_PotionScript checkAndAddToPoisonQueue - foundPoison: " + poisonName)
    form poisonForm = foundPoison as form
    if findInQueue(iPoisonQ, poisonForm) != -1
        debug.trace("iEquip_PotionScript checkAndAddToPoisonQueue -" + poisonName + " is already in the poison queue")
        if WC.asCurrentlyEquipped[4] == poisonName
            WC.setSlotCount(4, PlayerRef.GetItemCount(poisonForm))
        endIf
    elseIf !(jArray.count(iPoisonQ) == WC.iMaxQueueLength && WC.bHardLimitQueueSize)
        int poisonFormID = poisonForm.GetFormID()
        int itemID = WC.createItemID(poisonName, poisonFormID)
        int poisonObj = jMap.object()
        jMap.setForm(poisonObj, "iEquipForm", poisonForm)
        jMap.setInt(poisonObj, "iEquipFormID", poisonFormID)
        jMap.setInt(poisonObj, "iEquipItemID", itemID)
        jMap.setStr(poisonObj, "iEquipName", poisonName)
        jMap.setStr(poisonObj, "iEquipIcon", getPoisonIcon(foundPoison))
        jArray.addObj(iPoisonQ, poisonObj)
        iEquip_AllCurrentItemsFLST.AddForm(poisonForm)
        EH.updateEventFilter(iEquip_AllCurrentItemsFLST)
        if bMoreHUDLoaded
            AhzMoreHudIE.AddIconItem(itemID, "iEquipQ.png")
        endIf
        ;If the poison queue was previously empty update the widget to show what we've just added
        if jArray.count(iPoisonQ) == 1
            WC.aiCurrentQueuePosition[4] = 0
            WC.asCurrentlyEquipped[4] = poisonName
            if WC.bPoisonIconFaded
                WC.checkAndFadePoisonIcon(false)
                Utility.WaitMenuMode(0.3)
            endIf
            WC.updateWidget(4, 0, false, true)
            WC.setSlotCount(4, PlayerRef.GetItemCount(poisonForm))
        endIf
        debug.trace("iEquip_PotionScript checkAndAddToPoisonQueue - Form: " + poisonForm + ", " + poisonName + " added to the poison queue")
        bAddedToQueue = true
        iQueueToSort = iPoisonQ
    endIf
    debug.trace("iEquip_PotionScript checkAndAddToPoisonQueue end")
endFunction

function checkAndAddToConsumableQueue(potion foundConsumable, bool isPotion = false)
    debug.trace("iEquip_PotionScript checkAndAddToConsumableQueue start")
    string consumableName = foundConsumable.GetName()
    debug.trace("iEquip_PotionScript checkAndAddToConsumableQueue - foundConsumable: " + consumableName)
    form consumableForm = foundConsumable as form
    if findInQueue(iConsumableQ, consumableForm) != -1
        debug.trace("iEquip_PotionScript checkAndAddToConsumableQueue -" + consumableName + " is already in the consumable queue")
        if WC.asCurrentlyEquipped[3] == consumableName
            WC.setSlotCount(3, PlayerRef.GetItemCount(consumableForm))
        endIf
    elseIf !(jArray.count(iConsumableQ) == WC.iMaxQueueLength && WC.bHardLimitQueueSize)
        int consumableFormID = consumableForm.GetFormID()
        int itemID = WC.createItemID(consumableName, consumableFormID)
        int consumableObj = jMap.object()
        jMap.setForm(consumableObj, "iEquipForm", consumableForm)
        jMap.setInt(consumableObj, "iEquipFormID", consumableFormID)
        jMap.setInt(consumableObj, "iEquipItemID", itemID)
        jMap.setStr(consumableObj, "iEquipName", consumableName)
        if isPotion
        	jMap.setStr(consumableObj, "iEquipIcon", getPotionIcon(foundConsumable))
        else
        	jMap.setStr(consumableObj, "iEquipIcon", getConsumableIcon(foundConsumable))
        endIf
        jArray.addObj(iConsumableQ, consumableObj)
        iEquip_AllCurrentItemsFLST.AddForm(consumableForm)
        EH.updateEventFilter(iEquip_AllCurrentItemsFLST)
        if bMoreHUDLoaded
            AhzMoreHudIE.AddIconItem(itemID, "iEquipQ.png")
        endIf
        int count = jArray.count(iConsumableQ)
        int enabledPotionGroups
        int groupHasPotions
        if WC.bPotionGrouping
            int i = 0
            while i < 3
                if WC.abPotionGroupEnabled[i]
                    enabledPotionGroups += 1
                    if !WC.abPotionGroupEmpty[i]
                        groupHasPotions += 1
                    endIf
                endIf
                i += 1
            endWhile
        endIf    
        if count == 1 || ((count - enabledPotionGroups == 1) && groupHasPotions == 0)
            WC.aiCurrentQueuePosition[3] = count - 1
            WC.asCurrentlyEquipped[3] = consumableName
            if WC.bConsumableIconFaded
                WC.checkAndFadeConsumableIcon(false)
                Utility.WaitMenuMode(0.3)
            endIf
            WC.updateWidget(3, count - 1, false, true)
            WC.setSlotCount(3, PlayerRef.GetItemCount(consumableForm))
        endIf
        debug.trace("iEquip_PotionScript checkAndAddToConsumableQueue - Form: " + consumableForm + ", " + consumableName + " added to the consumable queue")
    endIf
    debug.trace("iEquip_PotionScript checkAndAddToConsumableQueue end")
endFunction

int function findInQueue(int Q, form formToFind)
    debug.trace("iEquip_PotionScript findInQueue start")
    debug.trace("iEquip_PotionScript findInQueue - Q: " + Q + ", formToFind: " + formToFind)
    int i = 0
    int foundAt = -1
    while i < jArray.count(Q) && foundAt == -1
        if formToFind == jMap.getForm(jArray.getObj(Q, i), "iEquipForm")
            foundAt = i            
        endIf
        i += 1
    endwhile
    debug.trace("iEquip_PotionScript findInQueue - returning " + foundAt)
    debug.trace("iEquip_PotionScript findInQueue end")
    return foundAt
endFunction

string function getPoisonIcon(potion foundPoison)
    debug.trace("iEquip_PotionScript getPoisonIcon start")
    string IconName
    if iEquip_FormExt.isWax(foundPoison as form)
        IconName = "PoisonWax"
    elseIf iEquip_FormExt.isOil(foundPoison as form)
        IconName = "PoisonOil"
    else
        MagicEffect strongestEffect = foundPoison.GetNthEffectMagicEffect(foundPoison.GetCostliestEffectIndex())
        int i = aPoisonEffects.Find(strongestEffect)
        if i == -1
            IconName = "Poison"
        else
            IconName = asPoisonIconNames[i]
        endIf
    endIf
    debug.trace("iEquip_PotionScript getPoisonIcon returning IconName as " + IconName)
    debug.trace("iEquip_PotionScript getPoisonIcon end")
    return IconName
endFunction

string function getConsumableIcon(potion foundConsumable)
    debug.trace("iEquip_PotionScript getConsumableIcon start")
    string IconName
    if foundConsumable.GetUseSound() == Game.GetForm(0x0010E2EA) ;NPCHumanEatSoup
        IconName = "Soup"
    elseif foundConsumable.GetUseSound() == Game.GetForm(0x000B6435) ;ITMPotionUse
        IconName = "Drink"
    else
        IconName = "Food"
    endIf
    debug.trace("iEquip_PotionScript getConsumableIcon end")
    return IconName
endFunction

string function getPotionIcon(potion foundPotion)
	debug.trace("iEquip_PotionScript getPotionIcon start")
	string IconName
	string pStr = foundPotion.GetNthEffectMagicEffect(foundPotion.GetCostliestEffectIndex()).GetName()
    if(pStr == "Health" || pStr == "Restore Health" || pStr == "Health Restoration" || pStr == "Regenerate Health" || pStr == "Health Regeneration" || pStr == "Fortify Health" || pStr == "Health Fortification")
        IconName = "HealthPotion"
    elseif(pStr == "Magicka " || pStr == "Restore Magicka" || pStr == "Magicka Restoration" || pStr == "Regenerate Magicka" || pStr == "Magicka Regeneration" || pStr == "Fortify Magicka" || pStr == "Magicka Fortification")
        IconName = "MagickaPotion" 
    elseif(pStr == "Stamina " || pStr == "Restore Stamina" || pStr == "Stamina Restoration" || pStr == "Regenerate Stamina" || pStr == "Stamina Regeneration" || pStr == "Fortify Stamina" || pStr == "Stamina Fortification")
        IconName = "StaminaPotion" 
    elseif(pStr == "Resist Fire")
        IconName = "FireResistPotion" 
    elseif(pStr == "Resist Shock")
        IconName = "ShockResistPotion" 
    elseif(pStr == "Resist Frost")
        IconName = "FrostResistPotion"
    else
    	IconName = "Potion"
    endIf
	debug.trace("iEquip_PotionScript getPotionIcon end")
	return IconName
endFunction

function sortPotionQueue(int Q)
    debug.trace("iEquip_PotionScript sortPotionQueue start")
    debug.trace("iEquip_PotionScript sortPotionQueue - Q: " + Q)
    ;This should sort strongest to weakest by the float value held in the Strength key on each object in the array
    int targetArray = aiPotionQ[Q]
    jArray.unique(targetArray)
    int n = jArray.count(targetArray)
    int i
    string theKey = "iEquipStrength"
    While (n > 1)
        i = 1
        n -= 1
        While (i <= n)
            Int j = i 
            int k = (j - 1) / 2
            While (jMap.getFlt(jArray.getObj(targetArray, j), theKey) < jMap.getFlt(jArray.getObj(targetArray, k), theKey))
                jArray.swapItems(targetArray, j, k)
                j = k
                k = (j - 1) / 2
            EndWhile
            i += 1
        EndWhile
        jArray.swapItems(targetArray, 0, n)
    EndWhile
    i = 0
    n = jArray.count(targetArray)
    while i < n
        debug.trace("iEquip_PotionScript - sortPotionQueue, sorted " + aStrongestEffects[Q].GetName() + " array - i: " + i + ", " + jMap.getForm(jArray.getObj(targetArray, i), "iEquipForm").GetName() + ", Strength: " + jMap.getFlt(jArray.getObj(targetArray, i), "iEquipStrength"))
        i += 1
    endWhile
    iQueueToSort = -1 ;Reset
    debug.trace("iEquip_PotionScript sortPotionQueue end")
EndFunction

function sortPoisonQueue()
    debug.trace("iEquip_PotionScript sortPoisonQueue start")
    form currentlyShownPoison = jMap.getForm(jArray.getObj(iPoisonQ, WC.aiCurrentQueuePosition[4]), "iEquipForm")
    int queueLength = jArray.count(iPoisonQ)
    int tempPoisonQ = jArray.objectWithSize(queueLength)
    int i
    
    while i < queueLength
        jArray.setStr(tempPoisonQ, i, jMap.getStr(jArray.getObj(iPoisonQ, i), "iEquipName"))
        i += 1
    endWhile
    
    jArray.sort(tempPoisonQ)
    i = 0
    int iIndex
    while i < queueLength
        string poisonName = jArray.getStr(tempPoisonQ, i)
        iIndex = 0
        
        while poisonName != jMap.getStr(jArray.getObj(iPoisonQ, iIndex), "iEquipName")
            iIndex += 1
        endWhile
        jArray.swapItems(iPoisonQ, i, iIndex)

        i += 1
    endWhile
    
    ;/i = 0
    while i < queueLength
        debug.trace("iEquip_PotionScript sortPoisonQueue - poison queue sorted, poison in index " + i + ": " + jMap.getStr(jArray.getObj(iPoisonQ, i), "iEquipName"))
        i += 1
    endWhile/;
    
    iIndex = findInQueue(iPoisonQ, currentlyShownPoison)
    if WC.aiCurrentQueuePosition[4] == -1 || !currentlyShownPoison || iIndex == -1
        iIndex = 0
    endIf
    
    WC.setCurrentQueuePosition(4, iIndex)
    debug.trace("iEquip_PotionScript sortPoisonQueue end")
endFunction

function selectAndConsumePotion(int potionGroup)
    debug.trace("iEquip_PotionScript selectAndConsumePotion start")
    debug.trace("iEquip_PotionScript selectAndConsumePotion - potionGroup: " + potionGroup)
    if 0 <= potionGroup && potionGroup <= 2
        int iTargetAV = aiActorValues[potionGroup]
        string sTargetAV = asActorValues[potionGroup]
        float currAVDamage = iEquip_ActorExt.GetAVDamage(PlayerRef, iTargetAV)
        debug.trace("iEquip_PotionScript selectAndConsumePotion - potionGroup received: " + potionGroup + ", targetAV: " + sTargetAV)
        int Q = (potionGroup * 3) + iPotionsFirstChoice

        if currAVDamage == 0 && (Q == 0 || Q == 3 || Q == 6) ;If we're targeting a restore potion but the AV is already full look for a fortify potion instead
            Q += 1
        endIf
        
        if jArray.count(aiPotionQ[Q]) < 1
            Q = (potionGroup * 3) + iPotionsSecondChoice
            if jArray.count(aiPotionQ[Q]) < 1
                Q = (potionGroup * 3) + iPotionsThirdChoice
                if jArray.count(aiPotionQ[Q]) < 1
                    Q = -1
                endIf
            endIf
        endIf
        
        if Q != -1
            debug.trace("iEquip_PotionScript selectAndConsumePotion - potionQ selected: " + Q + ", iPotionSelectChoice: " + iPotionSelectChoice + ", in combat: " + PlayerRef.IsInCombat())
            int targetPotion ; Default value is 0 which is the array index for the strongest potion of the type requested
            bool isRestore = (Q == 0 || Q == 3 || Q == 6)
            ; If MCM setting is Use Weakest First, or MCM setting is Smart Select then check for weapons not drawn and current stat value as percent of current max including buffs against threshold set, then set the target to the last potion in the queue
            if iPotionSelectChoice == 2 || (iPotionSelectChoice == 1 && !(PlayerRef.IsInCombat() || (PlayerRef.GetActorValue(sTargetAV) / (PlayerRef.GetActorValue(sTargetAV) + iEquip_ActorExt.GetAVDamage(PlayerRef, iTargetAV))) <= fSmartConsumeThreshold))    
                targetPotion = jArray.count(aiPotionQ[Q]) - 1
            elseIf isRestore ;Restore queues only - select strongest potion needed to fill current damage
                targetPotion = smartSelectRestorePotion(Q, currAVDamage)
            endIf
            form potionToConsume = jMap.getForm(jArray.getObj(aiPotionQ[Q], targetPotion), "iEquipForm")
            if potionToConsume
                debug.trace("iEquip_PotionScript selectAndConsumePotion - selected potion in index " + targetPotion + " is " + potionToConsume + ", " + potionToConsume.GetName())
                ; Consume the potion
                PlayerRef.EquipItemEx(potionToConsume)
                debug.notification(potionToConsume.GetName() + " " + iEquip_StringExt.LocalizeString("$iEquip_PO_PotionConsumed"))
                if isRestore
                	int restoreCount = getRestoreCount(potionGroup)
                	if restoreCount < 6
                		warnOnLowRestorePotionCount(restoreCount, potionGroup)
                	endIf
                endIf
            endIf
        elseIf currAVDamage == 0
            debug.notification(iEquip_StringExt.LocalizeString("$iEquip_PO_not_AVFull{"+sTargetAV+"}"))
        else
            debug.notification(iEquip_StringExt.LocalizeString("$iEquip_PO_not_noneLeft{"+sTargetAV+"}"))
        endIf
    endIf
    debug.trace("iEquip_PotionScript selectAndConsumePotion end")
endFunction

int function smartSelectRestorePotion(int Q, float currAVDamage)
    int targetPotion
    debug.trace("iEquip_PotionScript smartSelectRestorePotion - looking for the strongest restore potion in Q " + Q + ", current stat damage is " + currAVDamage)
    if jMap.getFlt(jArray.getObj(aiPotionQ[Q], 0), "iEquipStrength") > currAVDamage ;If the strongest potion in the queue has a greater strength than required to fully restore the target AV then check through the array until we find the best fit 
        int i = 1
        int queueLength = jArray.Count(aiPotionQ[Q])
        while i < queueLength
            if jMap.getFlt(jArray.getObj(aiPotionQ[Q], i), "iEquipStrength") < currAVDamage
                targetPotion = i - 1
                i = queueLength
            else
                i += 1
            endIf
        endWhile
    endIf
    debug.trace("iEquip_PotionScript smartSelectRestorePotion - selected potion in index " + targetPotion + " is a " + jMap.getStr(jArray.getObj(aiPotionQ[Q], targetPotion), "iEquipName") + " with a strength of " + jMap.getFlt(jArray.getObj(aiPotionQ[Q], targetPotion), "iEquipStrength"))
    return targetPotion
endFunction

bool function quickRestoreFindAndConsumePotion(int potionGroup, bool quickBuffRequested = false)
    debug.trace("iEquip_PotionScript quickHealFindAndConsumePotion start")
    ;Check we've actually still got entries in the first and second choice health potion queues
    int Q = potionGroup*3
    int count = jArray.count(aiPotionQ[Q])
    bool found
    if quickBuffRequested
        Q = Q + iPotionsSecondChoice
        count = jArray.count(aiPotionQ[Q])
    endIf
    if count > 0
        found = true
        int targetPotion
        if !quickBuffRequested && count > 1 ;If we're selecting from a restore queue then Smart Select only the strongest potion required to fully restore the stat, not necessarily the strongest overall
            targetPotion = smartSelectRestorePotion(Q, iEquip_ActorExt.GetAVDamage(PlayerRef, aiActorValues[Q/3]))
        endIf
        form potionToConsume = jMap.getForm(jArray.getObj(aiPotionQ[Q], targetPotion), "iEquipForm")
        PlayerRef.EquipItemEx(potionToConsume)
        debug.notification(potionToConsume.GetName() + " " + iEquip_StringExt.LocalizeString("$iEquip_PO_PotionConsumed"))
        if !quickBuffRequested
        	int restoreCount = getRestoreCount(potionGroup)
        	if restoreCount < 6
        		warnOnLowRestorePotionCount(restoreCount, potionGroup)
        	endIf
        endIf
    endIf
    debug.trace("iEquip_PotionScript quickHealFindAndConsumePotion end")
    return found
endFunction

function warnOnLowRestorePotionCount(int restoreCount, int potionGroup)
    debug.trace("iEquip_PotionScript warnOnLowRestorePotionCount start")
    if bEnableRestorePotionWarnings
	    string sPotionGroup = asPotionGroups[potionGroup]
	    ;If we've just dropped into one of the early warning thresholds and the consumable widget is currently displaying the Potion Group for the restore potion we've just consumed check and flash
	    if (restoreCount == 5 || restoreCount == 2) && bFlashPotionWarning && WC.asCurrentlyEquipped[3] == sPotionGroup
	        UI.InvokeInt(HUD_MENU, WidgetRoot + ".runPotionFlashAnimation", potionGroup)
	    endIf
	    ;Display the early warning notification
	    if bNotificationOnLowRestorePotions
	        string sWarning
	        if restoreCount == 0 && getPotionGroupCount(potionGroup) > 0 ;No need for a notification if the entire potion group is empty as this will be handled elsewhere
	            sWarning = iEquip_StringExt.LocalizeString("$iEquip_PO_not_allOutOfRestorePotions{" + sPotionGroup + "}")
	        elseIf restoreCount == 2
	            sWarning = iEquip_StringExt.LocalizeString("$iEquip_PO_not_nearlyOutOfRestorePotions{" + sPotionGroup + "}")
	        elseIf restoreCount == 5
	            sWarning = iEquip_StringExt.LocalizeString("$iEquip_PO_not_notManyRestorePotionsLeft{" + sPotionGroup + "}")
	        endIf
	        debug.notification(sWarning)
	    endIf
	endIf
    ;NB - the count colour will already have been set through WC.setSlotCount()
    debug.trace("iEquip_PotionScript warnOnLowRestorePotionCount end")
endFunction

state PROCESSING
    function onPotionRemoved(form removedPotion)
        ;Blocking in case of OnItemRemoved firing twice
    endFunction
endState