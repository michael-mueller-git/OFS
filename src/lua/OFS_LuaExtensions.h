#pragma once
#include <vector>
#include <string>

#include "OFS_Lua.h"
#include "OFS_LuaExtension.h"
#include "OFS_ImGui.h"

#include <unordered_map>
#include <string>

struct OFS_LuaBinding
{
	std::string GlobalName;
    std::string ExtensionId;
	std::string Name;
};

class OFS_LuaExtensions
{
    private:
        std::string LastConfigPath;
        void load(const std::string& path) noexcept;
        void save() noexcept;
        void removeNonExisting() noexcept;
        std::unordered_map<std::string, OFS_LuaBinding> Bindings;
    public:
        static constexpr const char* ExtensionDir = "extensions";
        static constexpr const char* DynamicBindingHandler = "OFS_LuaExtensions";
        static bool DevMode;
        static bool ShowLogs;
        static OFS::AppLog ExtensionLogBuffer;
        std::vector<OFS_LuaExtension> Extensions;

        // tables/fields
        static constexpr const char* GlobalExtensionPtr = "OFS_ExtensionPtr";
        static constexpr const char* GlobalActionMetaTable = "OFS_TmpActionMetaTable";
        static constexpr const char* ScriptIdxUserdata = "OFS_ScriptIdx";
        static constexpr const char* ScriptDataUserdata = "OFS_ScriptData";
        static constexpr const char* ScriptActionsField = "actions";

        // functions
        static constexpr const char* InitFunction = "init";
        static constexpr const char* UpdateFunction = "update";
        static constexpr const char* WsReceiveFunction = "ws_receive";
        static constexpr const char* RenderGui = "gui";

        OFS_LuaExtensions() noexcept;
        ~OFS_LuaExtensions() noexcept;

        void UpdateExtensionList() noexcept;

        bool Init() noexcept;
        void Update(float delta) noexcept;
        void ShowExtensions() noexcept;
        void ReloadEnabledExtensions() noexcept;
        void ScriptChanged(uint32_t scriptIdx) noexcept;
        void WsReceive(std::string& source, std::string& message) noexcept;

        void AddBinding(const std::string& extId, const std::string& uniqueId, const std::string& name) noexcept;
};

REFL_TYPE(OFS_LuaExtensions)
    REFL_FIELD(Extensions)
    REFL_FIELD(DevMode)
    REFL_FIELD(ShowLogs)
REFL_END
