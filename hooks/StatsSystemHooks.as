namespace StatsSystem
{
	PlayerRecord@ m_record;
	StatsPoints@ stats = StatsPoints();
	SValue@ sval;
	StatsSystem@ g_interface;

	class StatsPoints
	{
		int currentLevel = 0;
		int pointsOnLevelUp = 5;

		int points_health = 0;
		int points_mana = 0;
		int points_health_regen = 0;
		int points_mana_regen = 0;
		int points_armor = 0;
		int points_resistance = 0;
		int points_unused = 0;

		// TODO: implement these
		//int points_attack_speed = 0;
		//int points_cast_cooldown = 0;

		StatsPoints() {};
	}

	[Hook]
	void GameModeConstructor(Campaign@ campaign)
	{
		AddFunction("add_point_to", { cvar_type::String }, AddPointTo, cvar_flags::Cheat);
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
		@m_record = record;

		stats.currentLevel = record.EffectiveLevel();

		// Level up values, set this to 0 because we want to give
		// the player stat points instead of static level up stats
		
		m_record.classStats.level_health = 0;
		m_record.classStats.level_health_regen = 0;
		m_record.classStats.level_mana = 0;
		m_record.classStats.level_mana_regen = 0;
		m_record.classStats.level_armor = 0;
		m_record.classStats.level_resistance = 0;

		m_record.classStats.base_health = m_record.classStats.base_health + stats.points_health * 1;
		m_record.classStats.base_health_regen = m_record.classStats.base_health_regen + stats.points_health_regen * 1;
		m_record.classStats.base_mana = m_record.classStats.base_mana + stats.points_mana * 1;
		m_record.classStats.base_mana_regen = m_record.classStats.base_mana_regen + stats.points_mana_regen * 1;
		m_record.classStats.base_armor = m_record.classStats.base_armor + stats.points_armor * 1;
		m_record.classStats.base_resistance = m_record.classStats.base_resistance + stats.points_resistance * 1;


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
		//GetParamInt(UnitPtr(), sval, "points_unused", false);


		print("stats.points_health: " + stats.points_health);
		print("stats.points_mana: " + stats.points_mana);
		print("stats.points_health_regen: " + stats.points_health_regen);
		print("stats.points_mana_regen: " + stats.points_mana_regen);
		print("stats.points_armor: " + stats.points_armor);
		print("stats.points_resistance: " + stats.points_resistance);

		print("PlayerLevel: " + (record.EffectiveLevel()) );
	}

	void RefreshPlayerStats()
	{
		m_record.classStats.base_health = stats.points_health;
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		print(stats.points_health);
		// Save user spended and still spendable points
		builder.PushInteger("points_health", stats.points_health);
		builder.PushInteger("points_mana", stats.points_mana);
		builder.PushInteger("points_health_regen", stats.points_health_regen);
		builder.PushInteger("points_mana_regen", stats.points_mana_regen);
		builder.PushInteger("points_armor", stats.points_armor);
		builder.PushInteger("points_resistance", stats.points_resistance);

		//TODO: fix and implement
		//builder.PushInteger("points_attack_speed", stats.points_attack_speed);
		//builder.PushInteger("points_cast_cooldown", stats.points_cast_cooldown);
		//record.userdata.set("points_cast_cooldown", stats.points_cast_cooldown);
		//builder.PushInteger("points_unused", GetAmountUnSpentPoints());

	}


	int GetAmountUnSpentPoints()
	{
		int spendedPoints = 0;

		for(uint i = 0; i < m_record.userdata.getKeys().length(); i++)
			spendedPoints += int(m_record.userdata[ m_record.userdata.getKeys()[i] ]);

		return stats.pointsOnLevelUp * m_record.EffectiveLevel() - spendedPoints;
	}

	bool LeftOverPoints()
	{
		return (GetAmountUnSpentPoints() > 0);
	}



	// Test Function
	void AddPointTo(cvar_t@ arg0)
	{
		print("Adding a point to health");
		//m_record.classStats.base_health += arg0.GetInt();
		//AddPointToStat(arg0.GetString());
		string statName = arg0.GetString();


		if(statName == "health")
		{
			stats.points_health += 1;
			m_record.classStats.base_health += 1 * 1;
			print(stats.points_health);
		}else if(statName == "health_regen"){
			stats.points_health_regen += 1;
			m_record.classStats.base_health_regen += 1 * 1;
			print(stats.points_health_regen);
		}else if(statName == "mana"){
			stats.points_mana += 1;
			m_record.classStats.base_mana += 1 * 1;
			print(stats.points_mana);
		}else if(statName == "mana_regen"){
			stats.points_mana_regen += 1;
			m_record.classStats.base_mana_regen += 1 * 1;
			print(stats.points_mana_regen);
		}else if(statName == "armor"){
			stats.points_armor += 1;
			m_record.classStats.base_armor += 1 * 1;
			print(stats.points_armor);
		}else if(statName == "resistance"){
			stats.points_resistance += 1;
			m_record.classStats.base_resistance += 1 * 1;
			print(stats.points_resistance);
		}


		//stats.points_health += 1;


		// Maybe possible to change it to enums
		// Switch only works with integral type
		//switch(statName)
		//{
		//	case 1:
		//		break;
		//	case 2:
		//		break;
		//	case 3:
		//		break;
		//	case 4:
		//		break;
		//	case 5:
		//		break;
		//	case 6:
		//		break;
		//}
	}

	[Hook]
	void GameModeUpdate(Campaign@ campaign, int dt, GameInput& gameInput, MenuInput& menuInput)
	{
		if (g_interface is null)
			return;

		if (Platform::GetKeyState(61).Pressed) // F4
			campaign.ToggleUserWindow(g_interface);

		//if (stats.points_unused == 0) // F3
		//	campaign.ToggleUserWindow(g_interface);
	}

	[Hook]
	void GameModeStart(Campaign@ campaign, SValue@ save)
	{
		campaign.m_userWindows.insertLast(@g_interface = StatsSystem(campaign.m_guiBuilder));
	}
}