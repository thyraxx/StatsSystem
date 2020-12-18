namespace StatsSystem
{

	class Stats
	{
		int currentLevel = 0;
		int spendablePoints = 5;

		int points_health = 1;
		int points_mana = 0;
		int points_health_regen = 0;
		int points_mana_regen = 0;
		int points_armor = 0;
		int points_resistance = 0;

		Stats() {};

	}

	//AddFunction("give_gold", cfuncParams, GiveGoldCFunc, cvar_flags::Cheat);
	PlayerRecord@ m_record;
	Stats@ stats = Stats();

	[Hook]
	void GameModeConstructor(Campaign@ campaign)
	{
		AddFunction("add_stats_hp", { cvar_type::Int }, AddPointsToHealthStats, cvar_flags::Cheat);
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

		// Level up values, set this to 0 because we want to give
		// the player points instead of static level up stats
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
		//record.userdata.get("points_health", stats.points_health);
		stats.points_health = GetParamInt(UnitPtr(), sval, "points-health", false);
		print(stats.points_health);

		m_record.classStats.base_health += stats.points_health;

		// stats.points_attack_speed
		// stats.points_skill_cooldown
		
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		// Save user spended and still spendable points
		//record.userdata.set("points_health", stats.points_health);
		//record.userdata.set("points_mana", stats.points_mana);
		//record.userdata.set("points_health_regen", stats.points_health_regen);
		//record.userdata.set("points_mana_regen", stats.points_mana_regen);
		//record.userdata.set("points_armor", stats.points_armor);
		//record.userdata.set("points_resistance", stats.points_resistance);

		builder.PushDictionary("stats");
		builder.PushInteger("points-health", stats.points_health);
		builder.PopDictionary();
		print(stats.points_health);
	}

	void AddPointsToHealthStats(cvar_t@ arg0)
	{
		print("Adding a point to health");
		stats.points_health += arg0.GetInt();
		print(stats.points_health);

		m_record.classStats.base_health += stats.points_health;

	}
}