namespace StatsSystemNS
{

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
}