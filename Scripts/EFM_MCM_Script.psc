ScriptName EFM_MCM_Script extends SKI_ConfigBase

EFM_Events Property EventScript Auto

Int index_Interval
Int index_Enable
Int index_DynamicAttachment

Event OnPageReset(String page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	index_Enable = AddToggleOption("Enable", EventScript.IsEnabled)
	index_Interval = AddSliderOption("Interval", EventScript.Interval, "{1}s", BoolToEnabledFlag(EventScript.IsEnabled))
	index_DynamicAttachment = AddToggleOption("Dynamic Attachment", EventScript.IsDAEnabled)
EndEvent

Event OnOptionSelect(Int option)
	If (option == index_Enable)
		EventScript.IsEnabled = !EventScript.IsEnabled
		SetToggleOptionValue(option, EventScript.IsEnabled)
		SetOptionFlags(index_Interval, BoolToEnabledFlag(EventScript.IsEnabled))
		SetOptionFlags(index_DynamicAttachment, BoolToEnabledFlag(EventScript.IsDAEnabled))
	ElseIf (option == index_DynamicAttachment)
		EventScript.IsDAEnabled = !EventScript.IsDAEnabled
		SetToggleOptionValue(option, EventScript.IsDAEnabled)
	EndIf

	EventScript.Reset()
EndEvent

Event OnOptionSliderOpen(Int option)
	If (option == index_Interval)
		SetSliderDialogStartValue(EventScript.Interval)
		SetSliderDialogDefaultValue(EventScript.Interval)
		SetSliderDialogInterval(0.1)
		SetSliderDialogRange(0.1, 10.0)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
	If (option == index_Interval)
		SetSliderOptionValue(option, value, "{1}s")
		EventScript.Interval = value
	EndIf
EndEvent

Event OnOptionHighlight(Int option)
	If (option == index_Enable)
		SetInfoText("Disable it will not undo changes immediately, you'll have to restart the game.")
	ElseIf (option == index_Interval)
		SetInfoText("Set the timer interval.")
	ElseIf (option == index_DynamicAttachment)
		SetInfoText("It's Experimental!!! Dynamically attach a dummy EncounterZone to cells those dosn't have EncounterZone, this makes enemies chase you from exterior to interior. May cause performance issue and weird bugs.")
	EndIf
EndEvent

Event OnOptionDefault(Int option)
	If (option == index_Interval)
		SetSliderOptionValue(option, 1.0, "{1}s")
		EventScript.Interval = 1.0
	EndIf
EndEvent

Int Function BoolToEnabledFlag(Bool enabled)
	If (enabled)
		return OPTION_FLAG_NONE
	Else
		return OPTION_FLAG_DISABLED
	EndIf
EndFunction