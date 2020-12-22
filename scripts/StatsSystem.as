namespace StatsSystem
{
	class StatsSystem : UserWindow
	{
		ScrollableWidget@ m_wList;
		Widget@ m_wTemplateCheck;
		Widget@ m_wTemplateButton;
		//StatsPoints@ stats;
		
		//array<string> arrayStats = { "health", "health_regen", "mana", "mana_regen", "armor", "resistance"};
		dictionary dict = { {"health", "Health"}, {"health_regen", "Health Regen"}, {"mana", "Mana"}, {"mana_regen", "Mana Regen"}, {"armor", "Armor"}, {"resistance", "Resistance"} };

		StatsSystem(GUIBuilder@ b)
		{
			super(b, "gui/statssystem.gui");

			@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
			@m_wTemplateButton = m_widget.GetWidgetById("template-button");
		}

		void Show() override
		{
			m_wList.PauseScrolling();
			m_wList.ClearChildren();

			Widget@ wNewButton = null;

			for(uint i = 0; i < dict.getKeys().length(); i++)
			{
				auto wNewButtonStat = cast<ScalableSpriteButtonWidget>(m_wTemplateButton.Clone());
				wNewButtonStat.m_func = "action " + string(dict.getKeys()[i]);
				wNewButtonStat.SetText("+");
				@wNewButton = wNewButtonStat;
				wNewButton.m_tooltipText = string(dict[ dict.getKeys()[i] ]);

				wNewButton.m_visible = true;
				wNewButton.SetID("");

				m_wList.AddChild(wNewButton);
			}

			m_wList.ResumeScrolling();

			UserWindow::Show();
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");
			auto statName = parse[1];

			if (parse[0] == "action")
			{
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
			}
			else
				UserWindow::OnFunc(sender, name);
		}
	}
}
