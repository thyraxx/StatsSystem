namespace StatsSystemNS
{
	// TODO: Create stat add value getters
	// Now all numbers are put there manually, it's awful if
	// I want to change something for balancing.

	PlayerRecord@ m_record;
	StatsPoints@ stats = StatsPoints();
	SValue@ sval;
	StatsSystem@ g_interface;
	//Modifiers::ModifierList modifierList;
	Modifiers::Damage@ modi;
	bool alreadyExecuted = false;
		
	int addedValue = 1;


	// TODO: seperate class
	class StatsPoints
	{
		int currentLevel = 0;
		int pointsOnLevelUp = 5;

		int healthAdd = 5;
		int manaAdd = 5;
		float healthRegenAdd = 0.1f;
		float manaRegenAdd = 0.2f;
		int armorAdd = 1;
		int resistanceAdd = 1;
		float attackSpeedAdd = 0.1f;
		float skillSpeedAdd = 0.1f;
		int attackDamageAdd = 1;
		int SkillPowerAdd = 1;

		dictionary statsDict = { 
			{"points_health", 0},
			{"points_mana", 0},
			{"points_health_regen", 0},
			{"points_mana_regen", 0},
			{"points_armor", 0},
			{"points_resistance", 0},
			{"points_attack_speed", 0}, // is the first "skill", aka primary attack
			{"points_skill_speed", 0}, // aka cooldown
			{"points_attack_damage", 0},
			{"points_skill_damage", 0},
			{"points_unused", 5}
		};

		// Experiment to put everything into 1 dict
		// Way to annoying to retrieve values etc
		// KISS ;)
       	dictionary dictStatName;
       	dictionary dictNameAndValue;

     	dictionary statsDictTest = { 
			{0, dictionary = {{"points_health", dictionary = {{"Health", 1}} }} },
			{1, dictionary = {{"points_mana", dictionary = {{"Mana", 0}} }} },
			{2, dictionary = {{"points_health_regen", dictionary = {{"Health Regen", 0}}  }} },
			{3, dictionary = {{"points_mana_regen", dictionary = {{"Mana Regen", 0}}  }} },
			{4, dictionary = {{"points_armor", dictionary = {{"Armor", 0}} }} },
			{5, dictionary = {{"points_resistance", dictionary = {{"Resistance", 0}}  }} },
			{6, dictionary = {{"points_attack_speed", dictionary = {{"Attack Speed", 0}}  }} },
			{7, dictionary = {{"points_skill_speed", dictionary = {{"Cooldown", 0}}  }} },
			{8, dictionary = {{"points_attack_damage", dictionary = {{"Attack Damage", 0}}  }} },
			{9, dictionary = {{"points_skill_damage", dictionary = {{"Skill Damage", 0}}  }} },
			{"points_unused", 0} // Always keep this one as last
		};


		StatsPoints() {}
	}

	[Hook]
	void GameModeConstructor(Campaign@ campaign)
	{
		AddFunction("add_point_to", { cvar_type::String }, AddPointTo, cvar_flags::Cheat,
			"Gives a point to a chosen stat (add_point_to <health>/<health_regen>/<mana>), etc");

		AddFunction("reset_points", { cvar_type::Bool }, ResetPointsUnused);

		// So Blood altars won't spawn
		// I'll be honest, I don't know for sure if this works
		// But with some extensive testing I didn't saw any BR's spawning anymore.
		// I think this overwrite the usual Flag which should contain WH, to check if
		// you have this DLC, but since I changed it to something nonexistent, it can't spawn anymore.
		g_flags.m_flags["special_blood_altar"] = "NOBR";


	}

	[Hook]
	void GameModeSpawnPlayer(Campaign@ campaign, PlayerRecord@ record)
	{
		if(!record.local || alreadyExecuted == true)
			return;

		if(m_record == null)
			@m_record = GetLocalPlayerRecord();

		m_record.bloodAltarRewards.removeRange(0, m_record.bloodAltarRewards.length());

		// Level up values, set this to 0 because we want to give
		// the player stat points instead of static level up stats
		m_record.classStats.level_health = 0;
		m_record.classStats.level_health_regen = 0;
		m_record.classStats.level_mana = 0;
		m_record.classStats.level_mana_regen = 0;
		m_record.classStats.level_armor = 0;
		m_record.classStats.level_resistance = 0;

		// Our own custom level up values
		SetCustomStats();

		alreadyExecuted = true;
	}

	[Hook]
	void PlayerRecordLoad(PlayerRecord@ record, SValue@ sval)
	{
		if(!record.local)
			return;

		//@m_record = record; // bugged?
		if(m_record == null)
			@m_record = GetLocalPlayerRecord();

		stats.currentLevel = m_record.EffectiveLevel();

		stats.statsDict["points_health"] = GetParamFloat(UnitPtr(), sval, "points_health", false);
		stats.statsDict["points_health_regen"] = GetParamFloat(UnitPtr(), sval, "points_health_regen", false);
		stats.statsDict["points_mana"] = GetParamFloat(UnitPtr(), sval, "points_mana", false);
		stats.statsDict["points_mana_regen"] = GetParamFloat(UnitPtr(), sval, "points_mana_regen", false);
		stats.statsDict["points_armor"] = GetParamFloat(UnitPtr(), sval, "points_armor", false);
		stats.statsDict["points_resistance"] = GetParamFloat(UnitPtr(), sval, "points_resistance", false);
		stats.statsDict["points_attack_speed"] = GetParamFloat(UnitPtr(), sval, "points_attack_speed", false);
		stats.statsDict["points_skill_speed"] = GetParamFloat(UnitPtr(), sval, "points_skill_speed", false);
		stats.statsDict["points_attack_damage"] = GetParamFloat(UnitPtr(), sval, "points_attack_damage", false);
		stats.statsDict["points_skill_damage"] = GetParamFloat(UnitPtr(), sval, "points_skill_damage", false);


		stats.statsDict["points_unused"] = GetParamInt(UnitPtr(), sval, "points_unused", false, stats.pointsOnLevelUp * stats.currentLevel );

		g_allModifiers.m_modsAttackTimeMulConst = float( stats.statsDict["points_attack_speed"] ) * 0.01f + 1; // Attack speed starts at 1.0f, always + 1
		g_allModifiers.m_modsSkillTimeMulConst = float( stats.statsDict["points_skill_speed"] ) * 0.01f + 1; // Skill speed starts at 1.0f, always + 1


		// TODO: BUGGED?!
		//g_allModifiers.m_modsAttackDamageAddConst.x = int( stats.statsDict["points_attack_damage"] ) * 1;
		//g_allModifiers.m_modsAttackDamageAddConst.y = int( stats.statsDict["points_skill_damage"] ) * 1;

		auto damagesval = Resources::GetSValue("sval/modifierdamage.sval");
		@modi = Modifiers::Damage(UnitPtr(), damagesval);
		modi.m_power = ivec2(1 * int(stats.statsDict["points_attack_damage"]), 1 * int(stats.statsDict["points_skill_damage"]) );
		//print("Before: " + modi.m_power);


 		m_record.modifiers.Add(modi);
 		m_record.RefreshModifiers();
 		//m_record.modifiersUpgrades.Add();
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		if(!record.local)
			return;

		if(m_record == null)
			@m_record = GetLocalPlayerRecord();

		// Save user data
		builder.PushFloat("points_health", float(stats.statsDict["points_health"]));
		builder.PushFloat("points_health_regen", float(stats.statsDict["points_health_regen"]));
		builder.PushFloat("points_mana", float(stats.statsDict["points_mana"]));
		builder.PushFloat("points_mana_regen", float(stats.statsDict["points_mana_regen"]));
		builder.PushFloat("points_armor", float(stats.statsDict["points_armor"]));
		builder.PushFloat("points_resistance", float(stats.statsDict["points_resistance"]));
		builder.PushFloat("points_attack_speed", float(stats.statsDict["points_attack_speed"]));
		builder.PushFloat("points_skill_speed", float(stats.statsDict["points_skill_speed"]));
		builder.PushFloat("points_attack_damage", float(stats.statsDict["points_attack_damage"]));
		builder.PushFloat("points_skill_damage", float(stats.statsDict["points_skill_damage"]));

		builder.PushInteger("points_unused", int(stats.statsDict["points_unused"]));
	}

	void SetCustomStats()
	{
		m_record.classStats.base_health = m_record.classStats.base_health + float(stats.statsDict["points_health"]) * 5;
		m_record.classStats.base_health_regen = m_record.classStats.base_health_regen + float(stats.statsDict["points_health_regen"]) * 0.1;
		m_record.classStats.base_mana = m_record.classStats.base_mana + float(stats.statsDict["points_mana"]) * 5;
		m_record.classStats.base_mana_regen = m_record.classStats.base_mana_regen + float(stats.statsDict["points_mana_regen"]) * 0.2;
		m_record.classStats.base_armor = m_record.classStats.base_armor + float(stats.statsDict["points_armor"]) * 1;
		m_record.classStats.base_resistance = m_record.classStats.base_resistance + float(stats.statsDict["points_resistance"]) * 1;
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
		{
			int totalSpentPoints = 0;

			for(uint i = 0; i < stats.statsDict.getKeys().length(); i++)
			{
				totalSpentPoints += int(stats.statsDict[ stats.statsDict.getKeys()[i] ]);
				stats.statsDict[ stats.statsDict.getKeys()[i] ] = 0;
			}
			
			stats.statsDict["points_unused"] = totalSpentPoints;

			g_allModifiers.m_modsAttackTimeMulConst = 1.0f;
			g_allModifiers.m_modsSkillTimeMulConst = 1.0f;

			SetCustomStats();
			m_record.RefreshModifiers();
			g_interface.RefreshList();
		}
	}

	// Old function I used inside GameModeUpdate, now created my own hook
	bool LevelChanged()
	{
		return (stats.currentLevel < m_record.EffectiveLevel());
	}

	void AddPointTo(string statName)
	{
		print("Adding " + addedValue + " point to " + statName);
		stats.statsDict["points_unused"] = int(stats.statsDict["points_unused"]) - addedValue;

		// Maybe possible to use a switch instead?
		// But can only use integral, need to change to enums possibly
		if(statName == "points_health")
		{
			stats.statsDict["points_health"] = float(stats.statsDict["points_health"]) + addedValue;
			m_record.classStats.base_health += 5 * addedValue;
			//print( float(stats.statsDict["points_health"]) );
		}else if(statName == "points_health_regen"){
			stats.statsDict["points_health_regen"] = float(stats.statsDict["points_health_regen"]) + addedValue;
			m_record.classStats.base_health_regen += 0.1f * addedValue;
			//print( float(stats.statsDict["points_health_regen"]) );
		}else if(statName == "points_mana"){
			stats.statsDict["points_mana"] = float(stats.statsDict["points_mana"]) + addedValue;
			m_record.classStats.base_mana += 5 * addedValue;
			//print( float(stats.statsDict["points_mana"]) );
		}else if(statName == "points_mana_regen"){
			stats.statsDict["points_mana_regen"] = float(stats.statsDict["points_mana_regen"]) + addedValue;
			m_record.classStats.base_mana_regen += 0.2f * addedValue;
			//print( float(stats.statsDict["points_mana_regen"]) );
		}else if(statName == "points_armor"){
			stats.statsDict["points_armor"] = float(stats.statsDict["points_armor"]) + addedValue;
			m_record.classStats.base_armor += 1 * addedValue;
			//print( float(stats.statsDict["points_armor"]) );
		}else if(statName == "points_resistance"){
			stats.statsDict["points_resistance"] = float(stats.statsDict["points_resistance"]) + addedValue;
			m_record.classStats.base_resistance += 1 * addedValue;
			//print( float(stats.statsDict["points_resistance"]) );
		}else if(statName == "points_attack_speed"){
			stats.statsDict["points_attack_speed"] = float(stats.statsDict["points_attack_speed"]) + addedValue;
			g_allModifiers.m_modsAttackTimeMulConst += 0.01f * addedValue;
			//print(g_allModifiers.m_modsAttackTimeMulConst);
			//print( float(stats.statsDict["points_attack_speed"]) );
		}else if(statName == "points_skill_speed"){
			stats.statsDict["points_skill_speed"] = float(stats.statsDict["points_skill_speed"]) + addedValue;
			g_allModifiers.m_modsSkillTimeMulConst += 0.01f * addedValue;
			//print(g_allModifiers.m_modsSkillTimeMulConst);
			//print( float(stats.statsDict["points_skill_speed"]) );
		}else if(statName == "points_attack_damage"){
			stats.statsDict["points_attack_damage"] = float(stats.statsDict["points_attack_damage"]) + addedValue;
			//g_allModifiers.m_modsAttackDamageAddConst.x += addedValue;
			modi.m_power = ivec2(1 * int(stats.statsDict["points_attack_damage"]), 1 * int(stats.statsDict["points_skill_damage"]) );

			//print(g_allModifiers.m_modsAttackDamageAddConst.x);
			//print( float(stats.statsDict["points_attack_damage"]) );
		}else if(statName == "points_skill_damage"){
			stats.statsDict["points_skill_damage"] = float(stats.statsDict["points_skill_damage"]) + addedValue;
			//g_allModifiers.m_modsAttackDamageAddConst.y += addedValue;
			modi.m_power = ivec2(1 * int(stats.statsDict["points_attack_damage"]), 1 * int(stats.statsDict["points_skill_damage"]) );

			//print(g_allModifiers.m_modsAttackDamageAddConst.y);
			//print( float(stats.statsDict["points_skill_damage"]) );
		}


		m_record.modifiers.Remove(modi);
		m_record.modifiers.Add(modi);
		m_record.RefreshModifiers();
	}

	[Hook]
	void GameModeUpdate(Campaign@ campaign, int dt, GameInput& gameInput, MenuInput& menuInput)
	{
		if (g_interface is null)
			return;

		if (Platform::GetKeyState(63).Pressed) // F6
			campaign.ToggleUserWindow(g_interface);

		// Setting value each tick? I dislike this
		if( int(stats.statsDict["points_unused"]) >= 10 && (Platform::GetKeyState(224).Down || Platform::GetKeyState(228).Down) ) // Left ctrl or Right ctrl
		{
			addedValue = 10;
		}else if( int(stats.statsDict["points_unused"]) >= 5 && (Platform::GetKeyState(225).Down || Platform::GetKeyState(229).Down) ){ // Left shift or Right shift
			addedValue = 5;
		}else{
			addedValue = 1;
		}
	}

	[Hook]
	void GameModeStart(Campaign@ campaign, SValue@ save)
	{
		campaign.m_userWindows.insertLast(@g_interface = StatsSystem(campaign.m_guiBuilder));
	}

	// Created a MoreHooks mod
	[Hook]
	void PlayerRecordOnLevelUp(PlayerRecord@ record)
	{
		stats.currentLevel = m_record.EffectiveLevel();
		stats.statsDict["points_unused"] = int(stats.statsDict["points_unused"]) + stats.pointsOnLevelUp;
		
		// Refresh modifiers because of extra unspent points
		m_record.RefreshModifiers();
		
		g_interface.RefreshList();
	}
}