AddCSLuaFile()

player_manager.RegisterClass('player_shipdriver', {
  SetupDataTables = function(self)
    self.Player:NetworkVar('Entity', 0, 'Ship')
    self.Player:NetworkVar('Bool', 0, 'Thirdperson')
  end
}, 'player_default')
