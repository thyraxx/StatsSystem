namespace StatsSystem
{

	PlayerRecord@ m_record;
	Stats@ stats = Stats();
	SValue@ sval;


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
		int points_attack_speed = 0;
		int points_cast_cooldown = 0;

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
		@m_record = record;

		//record.userdata.set("points_health", 0);
		//record.userdata.set("points_mana", 0);
		//record.userdata.set("points_health_regen", 0);
		//record.userdata.set("points_mana_regen", 0);
		//record.userdata.set("points_armor", 0);
		//record.userdata.set("points_resistance", 0);
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
		RefreshPlayerStats(m_record);

		print("PlayerLevel: " + (record.EffectiveLevel()) );
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		print("m_record: " + m_record.classStats.base_health);
		// Save user spended and still spendable points
		m_record.userdata["points_health"] = m_record.classStats.base_health;
		//record.userdata.set("points_mana", record.classStats.base_mana);
		//record.userdata.set("points_health_regen", record.classStats.base_health_regen);
		//record.userdata.set("points_mana_regen", record.classStats.base_mana_regen);
		//record.userdata.set("points_armor", record.classStats.base_armor);
		//record.userdata.set("points_resistance", record.classStats.base_resistance);

		//record.userdata.set("points_unspended", GetAmountUnSpentPoints());

		//TODO: implement
		record.userdata.set("points_attack_speed", stats.points_attack_speed);
		record.userdata.set("points_cast_cooldown", stats.points_cast_cooldown);
	}


	int GetAmountUnSpentPoints()
	{
		int spendedPoints = 0;

		for(uint i = 0; i < m_record.userdata.getKeys().length(); i++)
			spendedPoints += int(m_record.userdata[ m_record.userdata.getKeys()[i] ]);

		return stats.pointsOnLevelUp * m_record.EffectiveLevel() - spendedPoints;;
	}

	void RefreshPlayerStats(PlayerRecord@ record)
	{
		print(int(record.userdata["points_health"]));
		record.classStats.base_health += int(record.userdata["points_health"]);
		record.classStats.base_mana += int(record.userdata["base_mana"]);
		record.classStats.base_health_regen += int(record.userdata["base_health_regen"]);
		record.classStats.base_mana_regen += int(record.userdata["base_mana_regen"]);
		record.classStats.base_armor += int(record.userdata["base_armor"]);
		record.classStats.base_resistance += int(record.userdata["base_resistance"]);
	}

	bool LeftOverPoints()
	{
		return (GetAmountUnSpentPoints() > 0);
	}

	void AddPointToStat(string statName)
	{
		if(m_record.userdata.getKeys().find(statName) <= 0)
		{
			print("This stat name doesn't exist!");
			return;
		}

		int plusOne = int(m_record.userdata[statName]) + 1;
		m_record.userdata.set(statName, plusOne);
		print( int(m_record.userdata[statName]) );

		m_record.classStats.base_health += 1;

		//RefreshPlayerStats(m_record);


		//switch(statName)
		//{
		//	case "points_health":
		//		stats.points_health += 1;
		//		record.classStats.base_health += stats.points_health;
		//		break;
//
		//	case "points_mana":
		//		stats.points_mana += 1;
		//		record.classStats.base_mana += stats.points_mana;
		//		break;
//
		//	case "points_health_regen":
		//		stats.points_health_regen += 1;
		//	record.classStats.base_health_regen += stats.points_health_regen;
		//		break;
//
		//	case "points_mana_regen":
		//		stats.points_mana_regen += 1;
		//		record.classStats.base_mana_regen += stats.points_mana_regen;
		//		break;
//
		//	case "points_armor":
		//		stats.points_armor += 1;
		//		record.classStats.base_armor += stats.points_armor;
		//		break;
//
		//	case "points_resistance":
		//		stats.points_resistance += 1;
		//		record.classStats.base_resistance += stats.points_resistance;
		//		break;
		//}
	}

	// Test Function
	void AddPointsToHealthStats(cvar_t@ arg0)
	{
		print("Adding a point to health");
		//m_record.classStats.base_health += arg0.GetInt();
		AddPointToStat(arg0.GetString());


	}
}