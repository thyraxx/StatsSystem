namespace StatsSystem
{

	PlayerRecord@ m_record;
	Stats@ stats = Stats();

	class Stats
	{
		int currentLevel = 0;
		int pointsOnLevelUp = 5;

		int points_health = 0;
		int points_mana = 0;
		int points_health_regen = 0;
		int points_mana_regen = 0;
		int points_armor = 0;
		int points_resistance = 0;

		// TODO: implement these
		//int points_attack_speed = 0;
		//int points_cast_cooldown = 0;

		Stats() {};

	}


	[Hook]
	void GameModeConstructor(Campaign@ campaign)
	{
		AddFunction("add_stats_hp", { cvar_type::String }, AddPointsToHealthStats, cvar_flags::Cheat);
		//AddFunction("add_stats_hp_regen", { cvar_type::Int }, AddPointsToHealthStats);
		//AddFunction("add_stats_mana", { cvar_type::Int }, AddPointsToHealthStats);
		//AddFunction("add_stats_mana_regen", { cvar_type::Int }, AddPointsToHealthStats);
		//AddFunction("add_stats_armor", { cvar_type::Int }, AddPointsToHealthStats);
		//AddFunction("add_stats_resistance", { cvar_type::Int }, AddPointsToHealthStats);
		
	}

	[Hook]
	void GameModeInitializePlayer(Campaign@ campaign, PlayerRecord@ record)
	{
	}

	[Hook]
	void GameModeSpawnPlayer(Campaign@ campaign, PlayerRecord@ record)
	{

		stats.currentLevel = record.EffectiveLevel();

		// Level up values, set this to 0 because we want to give
		// the player stat points instead of static level up stats
		m_record.classStats.level_health = 0;
		m_record.classStats.level_health_regen = 0;
		m_record.classStats.level_mana = 0;
		m_record.classStats.level_mana_regen = 0;
		m_record.classStats.level_armor = 0;
		m_record.classStats.level_resistance = 0;
	}


	[Hook]
	void PlayerRecordLoad(PlayerRecord@ record, SValue@ sval)
	{
		@m_record = record;

		stats.points_health = GetParamInt(UnitPtr(), sval, "points_health", false);
		stats.points_mana = GetParamInt(UnitPtr(), sval, "points_mana", false);
		stats.points_health_regen = GetParamInt(UnitPtr(), sval, "points_health_regen", false);
		stats.points_mana_regen = GetParamInt(UnitPtr(), sval, "points_mana_regen", false);
		stats.points_armor = GetParamInt(UnitPtr(), sval, "points_armor", false);
		stats.points_resistance = GetParamInt(UnitPtr(), sval, "points_resistance", false);
		GetParamInt(UnitPtr(), sval, "points_unused", false);

		RefreshPlayerStats();

		print("PlayerLevel: " + (record.EffectiveLevel()) );
	}

	void RefreshPlayerStats()
	{
		record.classStats.base_health = stats.points_health * 1
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		// The real proper way of saving is not this, Miss gave an example you can find on the HoH Discord
		// which is much better/properly: https://discord.com/channels/391637540303667200/440922045547544586/563474129848762383
		
		// Save user spended and still spendable points
		builder.PushDictionary("stats");
			builder.PushInteger("points_health", record.classStats.base_health);
			builder.PushInteger("points_mana", record.classStats.base_mana);
			builder.PushInteger("points_health_regen",  record.classStats.base_health_regen);
			builder.PushInteger("points_mana_regen", record.classStats.base_mana_regen);
			builder.PushInteger("points_armor", record.classStats.base_armor);
			builder.PushInteger("points_resistance", record.classStats.base_resistance);

			//TODO: fix and implement
			//record.userdata.set("points_attack_speed", stats.points_attack_speed);
			//record.userdata.set("points_cast_cooldown", stats.points_cast_cooldown);
			builder.PushInteger("points_unused", GetAmountUnSpentPoints());
		builder.PopDictionary();

		
	}


	int GetAmountUnSpentPoints()
	{
		int spendedPoints = 0;

		for(uint i = 0; i < m_record.userdata.getKeys().length(); i++)
			spendedPoints += int(m_record.userdata[ m_record.userdata.getKeys()[i] ]);

		return stats.pointsOnLevelUp * m_record.EffectiveLevel() - spendedPoints;;
	}

	bool LeftOverPoints()
	{
		return (GetAmountUnSpentPoints() > 0);
	}

	void AddPointToStat(string statName)
	{
		for(uint i = 0; i < m_record.userdata.getKeys().length(); i++)
			print(m_record.userdata.getKeys()[i]);

		if(m_record.userdata.getKeys().find(statName) < 0)
		{
			print("This stat name doesn't exist!");
			return;
		}

		int plusOne = int(m_record.userdata[statName]) + 1;
		m_record.userdata.set(statName, plusOne);
		print( int(m_record.userdata[statName]) );

		m_record.classStats.base_health += 1;
	}

	// Test Function
	void AddPointsToHealthStats(cvar_t@ arg0)
	{
		print("Adding a point to health");
		//m_record.classStats.base_health += arg0.GetInt();
		AddPointToStat(arg0.GetString());


	}
}