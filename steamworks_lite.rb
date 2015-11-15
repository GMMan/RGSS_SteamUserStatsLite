# cyanic's Quick and Easy Steamworks Achievements Integration for Ruby
# 11/15/15
#
# Drop steam_api.dll into the root of your project. Requires Steamworks SDK version >= 1.32.
#
# Examples:
#
# - Relaunch from Steam if Steamworks isn't available
# SteamworksLite.restart_app_if_necessary 480
#
# - Initialize Steamworks
# steam = SteamworksLite.new
#
# - However, for your convenience, an instance of SteamworksLite has already been created for you.
#   Access it like this.
# steam = SteamworksLite.instance
#
# - Check if Steamworks is initted
# is_initted = steam.initted?
#
# - Set achievement
# steam.set_achievement 'YOUR_ACH_ID_HERE'
#
# - Unset achievement
# steam.clear_achievement 'YOUR_ACH_ID_HERE'
#
# - Do this whereever it's convenient to update things
# steam.update
#
# - Shutdown Steamworks
# steam.shutdown
#

class SteamworksLite
  
  def initialize
    @initted = @@dll_SteamAPI_Init.call % 256 != 0
    @i_user_stats = @@dll_SteamUserStats.call if @initted
    @initted
  end
  
  def shutdown
    if @initted
      @i_user_stats = nil
      @@dll_SteamAPI_Shutdown.call
      @initted = false
    end    
  end
  
  def initted?
    @initted
  end
  
  def self.restart_app_if_necessary(app_id)
    @@dll_SteamAPI_RestartAppIfNecessary.call(app_id) % 256 != 0
  end
  
  def update
    @@dll_SteamAPI_RunCallbacks.call if initted?
  end
  
  def set_achievement(id)
    if initted?
      ok = @@dll_SteamAPI_ISteamUserStats_SetAchievement.call(@i_user_stats, id) % 256 != 0
      ok = @@dll_SteamAPI_ISteamUserStats_StoreStats.call(@i_user_stats) % 256 != 0 && ok
    else
      false
    end
  end
  
  def clear_achievement(id)
    if initted?
      ok = @@dll_SteamAPI_ISteamUserStats_ClearAchievement.call(@i_user_stats, id) % 256 != 0
      ok = @@dll_SteamAPI_ISteamUserStats_StoreStats.call(@i_user_stats) % 256 != 0 && ok
    else
      false
    end    
  end
  
  def self.instance
    @@instance
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
  @@dll_SteamAPI_Shutdown = Win32API.new(self.steam_dll_name, 'SteamAPI_Shutdown', '', 'V')
  @@dll_SteamAPI_RunCallbacks = Win32API.new(self.steam_dll_name, 'SteamAPI_RunCallbacks', '', 'V')
  @@dll_SteamUserStats = Win32API.new(self.steam_dll_name, 'SteamUserStats', '', 'P')
  @@dll_SteamAPI_ISteamUserStats_SetAchievement = Win32API.new(self.steam_dll_name, 'SteamAPI_ISteamUserStats_SetAchievement', 'PP', 'I')
  @@dll_SteamAPI_ISteamUserStats_ClearAchievement = Win32API.new(self.steam_dll_name, 'SteamAPI_ISteamUserStats_ClearAchievement', 'PP', 'I')
  @@dll_SteamAPI_ISteamUserStats_StoreStats = Win32API.new(self.steam_dll_name, 'SteamAPI_ISteamUserStats_StoreStats', 'P', 'I')
  
  @@instance = self.new

end
