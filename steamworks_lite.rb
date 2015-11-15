require 'Win32API'

class SteamworksLite
  
  def initialize
    @initted = @@dll_SteamAPI_Init.call % 256 != 0
	@i_user_stats = @@dll_SteamUserStats.call if @initted
	@initted
  end
  
  def shutdown
    @i_user_stats = nil if @initted
	@initted = false
  end
  
  def initted?
    @initted
  end
  
  def restart_app_if_necessary(app_id)
    @@dll_SteamAPI_RestartAppIfNecessary.call(app_id) % 256 != 0
  end
  
  def update
    @@dll_SteamAPI_RunCallbacks.call if initted?
  end
  
  def set_achievement(id)
    if initted?
      ok = @@dll_SteamAPI_ISteamUserStats_SetAchievement.call(@i_user_stats, id) % 256 != 0
	  ok = @@dll_SteamAPI_SteamAPI_ISteamUserStats_StoreStats.call(@i_user_stats) % 256 != 0 && ok
	else
	  false
	end
  end
  
  def clear_achievement(id)
    if initted?
      ok = @@dll_SteamAPI_ISteamUserStats_ClearAchievement.call(@i_user_stats, id) % 256 != 0
	  ok = @@dll_SteamAPI_SteamAPI_ISteamUserStats_StoreStats.call(@i_user_stats) % 256 != 0 && ok
	else
	  false
	end	
  end
  
  private
  def self.is_64bit?
    # Probably very bad detection of whether current runtime is 64-bit
	(/x64/ =~ RUBY_PLATFORM) != nil
  end
  
  def self.steam_dll_name
    @@dll_name ||= self.is_64bit? ? 'steam_api64' : 'steam_api'
  end
  
  # Function imports
  @@dll_SteamAPI_RestartAppIfNecessary = Win32API.new(self.steam_dll_name, 'SteamAPI_RestartAppIfNecessary', 'I', 'I')
  @@dll_SteamAPI_Init = Win32API.new(self.steam_dll_name, 'SteamAPI_Init', '', 'I')
  @@dll_SteamAPI_RunCallbacks = Win32API.new(self.steam_dll_name, 'SteamAPI_RunCallbacks', '', 'V')
  @@dll_SteamUserStats = Win32API.new(self.steam_dll_name, 'SteamUserStats', '', 'P')
  @@dll_SteamAPI_ISteamUserStats_SetAchievement = Win32API.new(self.steam_dll_name, 'SteamAPI_ISteamUserStats_SetAchievement', 'LS', 'I')
  @@dll_SteamAPI_ISteamUserStats_ClearAchievement = Win32API.new(self.steam_dll_name, 'SteamAPI_ISteamUserStats_ClearAchievement', 'LS', 'I')
  @@dll_SteamAPI_SteamAPI_ISteamUserStats_StoreStats = Win32API.new(self.steam_dll_name, 'SteamAPI_ISteamUserStats_StoreStats', 'L', 'I')

end
