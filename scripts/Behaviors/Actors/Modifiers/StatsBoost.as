namespace Modifiers
{
	class StatsBoost : Modifier
	{
		vec2 m_damageMulAdd;

		StatsBoost(UnitPtr unit, SValue& params)
		{
			m_damageMulAdd = vec2(
				GetParamFloat(unit, params, "attack-mul-add", false, 0),
				GetParamFloat(unit, params, "spell-mul-add", false, 0)
			);
		}

		vec2 DamageMul(PlayerBase@ player, Actor@ enemy) override { 
			auto test = vec2(1.0f, 1.0f) + m_damageMulAdd * float( int(StatsSystemNS::stats.statsDict["points_unused"]) );
			print("damagemul: " + test);
			return test;
		}
	}
}