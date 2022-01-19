ScriptName EFM_Events extends ReferenceAlias

Bool Property IsEnabled = true Auto
Float Property Interval = 1.0 Auto
Bool Property IsDAEnabled = false Auto
EncounterZone Property DummyEncounterZone Auto

Int prevCellID

Event OnInit()
	Reset()
EndEvent

Event OnPlayerLoadGame()
	Reset()
EndEvent

Event OnUpdate()
	Cell currentCell = self.GetReference().GetParentCell()
	If (prevCellID != currentCell.GetFormID())
		EFM_Plugin.SetEncounterZoneToNoBoundary(currentCell)
		prevCellID = currentCell.GetFormID()
	EndIf

	If (IsEnabled)
		RegisterForSingleUpdate(Interval)
	EndIf
EndEvent

Function Reset()
	If (IsEnabled)
		prevCellID = 0
		RegisterForSingleUpdate(Interval)
		If (IsDAEnabled)
			EFM_Plugin.SetDummyEncounterZone(DummyEncounterZone)
		Else
			EFM_Plugin.SetDummyEncounterZone(none)
		EndIf
	Else
		UnregisterForUpdate()
	EndIf
EndFunction