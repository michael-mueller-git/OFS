#include "OFS_WebsocketApiCommands.h"
#include <optional>
#include <iostream>

WsCommandBuffer::WsCommandBuffer() noexcept
{

}

inline static std::unique_ptr<WsCmd> CreateCommand(const std::string& name, const nlohmann::json& data) noexcept
{
    if(name == "change_time" &&  data.contains("time") && data["time"].is_number())
    {
        float time = data["time"].get<float>();
        return std::make_unique<WsTimeChangeCmd>(time);
    }
    else if(name == "change_play" && data.contains("playing") && data["playing"].is_boolean())
    {
        bool playing = data["playing"].get<bool>();
        return std::make_unique<WsPlayChangeCmd>(playing);
    }
    else if(name == "change_playbackspeed" && data.contains("speed") && data["speed"].is_number())
    {
        float speed = data["speed"].get<float>();
        return std::make_unique<WsPlaybackSpeedChangeCmd>(speed);
    }
    else if(name == "add_action" && data.contains("at") && data.contains("pos"))
    {
        auto at = data["at"].get<float>();
        auto pos = data["pos"].get<int32_t>();
        auto scriptIndex = data.contains("scriptIndex") ? data["scriptIndex"].get<int32_t>() : -1;
        return std::make_unique<WsAddActionCmd>(at, pos, scriptIndex);
    }
    else if(name == "user_data_01" && data.contains("message") && data.contains("source")) {
        auto source = data["source"].get<std::string>();
        auto message = data["message"].get<std::string>();
        return std::make_unique<WsUserData01Cmd>(source, message);
    }
    return {};
}

bool WsCommandBuffer::AddCmd(const nlohmann::json& jsonCmd) noexcept
{
    auto& type = jsonCmd["type"];
    if(!type.is_string() || type != "command") return false;

    auto& name = jsonCmd["name"];
    if(!name.is_string()) return false;

    auto& data = jsonCmd["data"];
    if(data.is_null()) return false;

    auto cmd = CreateCommand(name.get_ref<const std::string&>(), data);
    if(cmd)
    {
        SDL_AtomicLock(&commandLock);
        commands.emplace_back(std::move(cmd));
        SDL_AtomicUnlock(&commandLock);
        return true;
    }
    return false;
}

void WsCommandBuffer::ProcessCommands() noexcept
{
    if(commands.empty()) return;
    SDL_AtomicLock(&commandLock);
    for(auto& cmd : commands)
    {
        cmd->Run();
    }
    commands.clear();
    SDL_AtomicUnlock(&commandLock);
}


#include "OpenFunscripter.h"

void WsPlayChangeCmd::Run() noexcept
{
    auto app = OpenFunscripter::ptr;
    app->player->SetPaused(!playing);
}

void WsPlaybackSpeedChangeCmd::Run() noexcept
{
    auto app = OpenFunscripter::ptr;
    app->player->SetSpeed(speed);
}

void WsTimeChangeCmd::Run() noexcept
{
    auto app = OpenFunscripter::ptr;
    app->player->SetPositionExact(time);
}

void WsAddActionCmd::Run() noexcept
{
    auto app = OpenFunscripter::ptr;
    auto funscripts = app->LoadedFunscripts();
    auto activeFunscript = app->ActiveFunscript();
    if (scriptIndex < 0) {
        activeFunscript->AddEditAction({at, pos}, app->scripting->LogicalFrameTime());
    } else if (scriptIndex < funscripts.size()) {
        funscripts[scriptIndex]->AddEditAction({at, pos}, app->scripting->LogicalFrameTime());
    }
}

void WsUserData01Cmd::Run() noexcept
{
    auto app = OpenFunscripter::ptr;
    app->extensions->WsReceive(source, message);
}
