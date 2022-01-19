namespace
{
	void InitializeLog()
	{
#ifndef NDEBUG
		auto sink = std::make_shared<spdlog::sinks::msvc_sink_mt>();
#else
		auto path = logger::log_directory();
		if (!path) {
			util::report_and_fail("Failed to find standard logging directory"sv);
		}

		*path /= fmt::format("{}.log"sv, Plugin::NAME);
		auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true);
#endif

#ifndef NDEBUG
		const auto level = spdlog::level::trace;
#else
		const auto level = spdlog::level::info;
#endif

		auto log = std::make_shared<spdlog::logger>("global log"s, std::move(sink));
		log->set_level(level);
		log->flush_on(level);

		spdlog::set_default_logger(std::move(log));
		spdlog::set_pattern("%g(%#): [%^%l%$] %v"s);
	}
}

extern "C" DLLEXPORT constinit auto SKSEPlugin_Version = []() {
	SKSE::PluginVersionData v;

	v.PluginVersion(Plugin::VERSION);
	v.PluginName(Plugin::NAME);

	v.UsesAddressLibrary(true);
	v.CompatibleVersions({ SKSE::RUNTIME_LATEST });

	return v;
}();

static RE::BGSEncounterZone* dummyEncounterZonePtr = nullptr;

void SetDummyEncounterZone(RE::StaticFunctionTag*, RE::BGSEncounterZone* akEncounterZone)
{
	dummyEncounterZonePtr = akEncounterZone;
}

void SetEncounterZoneToNoBoundary(RE::StaticFunctionTag*, RE::TESObjectCELL* akCell)
{
	if (akCell == nullptr) {
		return;
	}

	auto &BGSEncounterZonePtr = akCell->loadedData->encounterZone;
	if (BGSEncounterZonePtr == nullptr) {
		if (dummyEncounterZonePtr == nullptr) {
			logger::info("No EncounterZone In Cell {:0>8X}", akCell->formID);
		} else {
			BGSEncounterZonePtr = dummyEncounterZonePtr;
			logger::info("Attached Dummy EncounterZone To Cell {:0>8X}", akCell->formID);
		}
	} else {
		if (BGSEncounterZonePtr->formType == RE::FormType::EncounterZone && BGSEncounterZonePtr != dummyEncounterZonePtr) {
			BGSEncounterZonePtr->data.flags |= RE::ENCOUNTER_ZONE_DATA::Flag::kDisableCombatBoundary;
			logger::info("Modified EncounterZone {:0>8X} In Cell {:0>8X}", BGSEncounterZonePtr->formID, akCell->formID);
		} else {
			logger::info("No EncounterZone In Cell {:0>8X}", akCell->formID);
		}
	}
}

bool RegisterFuncs(RE::BSScript::IVirtualMachine* a_vm)
{
	a_vm->RegisterFunction("SetDummyEncounterZone", "EFM_Plugin", SetDummyEncounterZone, true);
	a_vm->RegisterFunction("SetEncounterZoneToNoBoundary", "EFM_Plugin", SetEncounterZoneToNoBoundary, true);

	return true;
}

extern "C" DLLEXPORT bool SKSEAPI SKSEPlugin_Load(const SKSE::LoadInterface* a_skse)
{
	InitializeLog();
	logger::info("{} v{}"sv, Plugin::NAME, Plugin::VERSION.string());

	SKSE::Init(a_skse);
	auto papyrus = SKSE::GetPapyrusInterface();
	if (!papyrus->Register(RegisterFuncs)) {
		return false;
	}

	return true;
}
