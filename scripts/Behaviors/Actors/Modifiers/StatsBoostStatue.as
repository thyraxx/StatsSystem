namespace Modifiers
{
	class StatsBoostStatue : StackedModifier
	{
		vec2 m_mul;

		StatsBoostStatue(){}
		StatsBoostStatue(UnitPtr unit, SValue& params)
		{
			m_mul = vec2(
                GetParamFloat(unit, params, "attack-mul-add", false, 0.0f),
                GetParamFloat(unit, params, "spell-mul-add", false, 0.0f)
            );
		}

		Modifier@ Instance() override
		{
			auto ret = StatsBoostStatue();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasDamageMul() override { return true; }
		vec2 DamageMul(PlayerBase@ player, Actor@ enemy) override
		{
			vec2 dmg = vec2(1.0f, 1.0f) + (m_mul * m_stackCount) * float(StatsSystemNS::stats.statsDict["points_unused"]);
            return dmg;
		}
	}
}