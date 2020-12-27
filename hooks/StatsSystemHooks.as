namespace StatsSystemNS
{
	PlayerRecord@ m_record;
	StatsPoints@ stats = StatsPoints();
	SValue@ sval;
	StatsSystem@ g_interface;

	class StatsPoints
	{
		int currentLevel = 0;
		int pointsOnLevelUp = 5;

		dictionary statsDict = { 
			{"points_health", 0},
			{"points_mana", 0},
			{"points_health_regen", 0},
			{"points_mana_regen", 0},
			{"points_armor", 0},
			{"points_resistance", 0},
			{"points_unused", 5}
		};

		// TODO: implement these
		//int points_attack_speed = 0;
		//int points_cast_cooldown = 0;

		StatsPoints() {};
	}

	[Hook]
	void GameModeConstructor(Campaign@ campaign)
	{
		AddFunction("add_point_to", { cvar_type::String }, AddPointTo, cvar_flags::Cheat,
			"Gives a point to a chosen stat (add_point_to <health>/<health_regen>/<mana>), etc");

		AddFunction("reset_points", { cvar_type::Bool }, ResetPointsUnused, cvar_flags::Cheat);
	}

	[Hook]
	void GameModeInitializePlayer(Campaign@ campaign, PlayerRecord@ record)
	{
	}

	[Hook]
	void GameModeSpawnPlayer(Campaign@ campaign, PlayerRecord@ record)
	{
		@m_record = record;


		// Level up values, set this to 0 because we want to give
		// the player stat points instead of static level up stats
		m_record.classStats.level_health = 0;
		m_record.classStats.level_health_regen = 0;
		m_record.classStats.level_mana = 0;
		m_record.classStats.level_mana_regen = 0;
		m_record.classStats.level_armor = 0;
		m_record.classStats.level_resistance = 0;

		// Our own custom level up values
		m_record.classStats.base_health = m_record.classStats.base_health + float(stats.statsDict["points_health"]) * 1;
		m_record.classStats.base_health_regen = m_record.classStats.base_health_regen + float(stats.statsDict["points_health_regen"]) * 0.1;
		m_record.classStats.base_mana = m_record.classStats.base_mana + float(stats.statsDict["points_mana"]) * 1;
		m_record.classStats.base_mana_regen = m_record.classStats.base_mana_regen + float(stats.statsDict["points_mana_regen"]) * 0.2;
		m_record.classStats.base_armor = m_record.classStats.base_armor + float(stats.statsDict["points_armor"]) * 1;
		m_record.classStats.base_resistance = m_record.classStats.base_resistance + float(stats.statsDict["points_resistance"]) * 1;
	}

	[Hook]
	void PlayerRecordLoad(PlayerRecord@ record, SValue@ sval)
	{
		@m_record = record;

		stats.currentLevel = record.EffectiveLevel();

		print(stats.currentLevel);
		stats.statsDict["points_health"] = GetParamFloat(UnitPtr(), sval, "points_health", false);
		stats.statsDict["points_health_regen"] = GetParamFloat(UnitPtr(), sval, "points_health_regen", false);
		stats.statsDict["points_mana"] = GetParamFloat(UnitPtr(), sval, "points_mana", false);
		stats.statsDict["points_mana_regen"] = GetParamFloat(UnitPtr(), sval, "points_mana_regen", false);
		stats.statsDict["points_armor"] = GetParamFloat(UnitPtr(), sval, "points_armor", false);
		stats.statsDict["points_resistance"] = GetParamFloat(UnitPtr(), sval, "points_resistance", false);
		stats.statsDict["points_unused"] = GetParamInt(UnitPtr(), sval, "points_unused", false, stats.pointsOnLevelUp * stats.currentLevel );
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		// Save user data
		builder.PushFloat("points_health", float(stats.statsDict["points_health"]));
		builder.PushFloat("points_mana", float(stats.statsDict["points_health_regen"]));
		builder.PushFloat("points_health_regen", float(stats.statsDict["points_mana"]));
		builder.PushFloat("points_mana_regen", float(stats.statsDict["points_mana_regen"]));
		builder.PushFloat("points_armor", float(stats.statsDict["points_armor"]));
		builder.PushFloat("points_resistance", float(stats.statsDict["points_resistance"]));
		builder.PushInteger("points_unused", int(stats.statsDict["points_unused"]));


		//TODO: Implement
		//builder.PushInteger("points_attack_speed", stats.points_attack_speed);
		//builder.PushInteger("points_cast_cooldown", stats.points_cast_cooldown);
	}

	int totalSpentPoints()
	{
		int totalSpentPoints = 0;

		for(uint i = 0; i < stats.statsDict.getKeys().length(); i++)
		{
			totalSpentPoints += int(stats.statsDict[ stats.statsDict.getKeys()[i] ]);
		}

		return totalSpentPoints;
	}

	// For testing, but we still want to call the same function
	// instead of creating 2 functions which do the same
	void AddPointTo(cvar_t@ arg0)
	{
		AddPointTo(arg0.GetString());
	}

	void ResetPointsUnused(cvar_t@ arg0)
	{
		if(arg0.GetBool())
			stats.statsDict["points_unused"] = 5;
	}

	bool LevelChanged()
	{
		return (stats.currentLevel < m_record.EffectiveLevel());
	}

	void AddPointTo(string statName)
	{
		
		print("Adding a point to " + statName);
		stats.statsDict["points_unused"] = int(stats.statsDict["points_unused"]) - 1;

		// Maybe possible to use a switch instead?
		// But can only use integral
		if(statName == "health")
		{
			stats.statsDict["points_health"] = float(stats.statsDict["points_health"]) + 1;
			m_record.classStats.base_health += 1 * 1;
			print( float(stats.statsDict["points_health"]) );
		}else if(statName == "health_regen"){
			stats.statsDict["points_health_regen"] = float(stats.statsDict["points_health_regen"]) + 1;
			m_record.classStats.base_health_regen += 1 * 1;
			print( float(stats.statsDict["points_health_regen"]) );
		}else if(statName == "mana"){
			stats.statsDict["points_mana"] = float(stats.statsDict["points_mana"]) + 1;
			m_record.classStats.base_mana += 1 * 1;
			print( float(stats.statsDict["points_mana"]) );
		}else if(statName == "mana_regen"){
			stats.statsDict["points_mana_regen"] = float(stats.statsDict["points_mana_regen"]) + 1;
			m_record.classStats.base_mana_regen += 1 * 1;
			print( float(stats.statsDict["points_mana_regen"]) );
		}else if(statName == "armor"){
			stats.statsDict["points_armor"] = float(stats.statsDict["points_armor"]) + 1;
			m_record.classStats.base_armor += 1 * 1;
			print( float(stats.statsDict["points_armor"]) );
		}else if(statName == "resistance"){
			stats.statsDict["points_resistance"] = float(stats.statsDict["points_resistance"]) + 1;
			m_record.classStats.base_resistance += 1 * 1;
			print( float(stats.statsDict["points_resistance"]) );
		}
	}

	[Hook]
	void GameModeUpdate(Campaign@ campaign, int dt, GameInput& gameInput, MenuInput& menuInput)
	{
		if (g_interface is null)
			return;

		if (Platform::GetKeyState(61).Pressed) // F4
			campaign.ToggleUserWindow(g_interface);

		if(LevelChanged())
		{
			// For now only works per level, if multiple levels are gained as one level up
			// you still only gain 5 points
			stats.statsDict["points_unused"] = int(stats.statsDict["points_unused"]) + 5;
			g_interface.RefreshList();
		}
	}

	[Hook]
	void GameModeStart(Campaign@ campaign, SValue@ save)
	{
		campaign.m_userWindows.insertLast(@g_interface = StatsSystem(campaign.m_guiBuilder));
	}
}