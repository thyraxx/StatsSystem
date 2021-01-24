namespace StatsSystemNS
{
	class StatsSystem : UserWindow
	{
		ScrollableWidget@ m_wList;
		Widget@ m_wTemplateButton;
		Widget@ m_wPointsUnspentRect;
		TextWidget@ m_wTemplateText;
		TextWidget@ m_wPointsUnspentText;
		GroupWidget@ m_wTemplateRectWidget;
		
		// Should I use this, or rather a combination of this and .lang file?
		dictionary dict = { {"health", "Health"}, {"health_regen", "Health Regen"}, {"mana", "Mana"}, {"mana_regen", "Mana Regen"}, {"armor", "Armor"}, {"resistance", "Resistance"}, {"attack_speed", "Attack Speed"}, {"skill_speed", "Cooldown"}, {"attack_damage", "Attack Damage"}, {"skill_damage", "Skill Power"} };

		StatsSystem(GUIBuilder@ b)
		{
			super(b, "gui/statssystem.gui");

			@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
			@m_wTemplateButton = m_widget.GetWidgetById("template-button");
			@m_wTemplateText = cast<TextWidget>(m_widget.GetWidgetById("stat-title"));
			@m_wTemplateRectWidget = cast<GroupWidget>(m_widget.GetWidgetById("stat-and-title"));
			@m_wPointsUnspentText = cast<TextWidget>(m_widget.GetWidgetById("points-unspent"));
			@m_wPointsUnspentRect = m_widget.GetWidgetById("points-unspent-rect");			
		}

		void Show() override
		{

			CreateList();
		}

		void CreateList()
		{
			m_wList.PauseScrolling();
			m_wList.ClearChildren();

			m_wPointsUnspentText.SetText("Unspent: " + int(stats.statsDict["points_unused"]) );

			Widget@ wNewButton = null;
			GroupWidget@ wRectWidget = null;

			for(uint i = 0; i < stats.statsDict.getKeys().length() - 1; i++)
			{
				auto wNewButtonStat = cast<ScalableSpriteButtonWidget>(m_wTemplateButton.Clone());
				auto wNewTextTitle = cast<TextWidget>(m_wTemplateText.Clone());
				auto wNewRectWidget = cast<GroupWidget>(m_wTemplateRectWidget.Clone());

				wNewButtonStat.m_func = "action " + string(stats.statsDict.getKeys()[i]);
				wNewButtonStat.SetText("+");
				wNewButtonStat.m_enabled = ( int(stats.statsDict["points_unused"]) > 0 );
				@wNewButton = wNewButtonStat;
				@wRectWidget = wNewRectWidget;
				wNewButton.m_tooltipText = int(stats.statsDict[ stats.statsDict.getKeys()[i] ]);
				wNewTextTitle.SetText( string( dict[ stats.statsDict.getKeys()[i] ] ));

				wNewButton.m_visible = true;
				wNewTextTitle.m_visible = true;
				wNewButton.SetID("");

				wRectWidget.AddChild(wNewButtonStat);
				wRectWidget.AddChild(wNewTextTitle);
				m_wList.AddChild(wRectWidget);
			}

			m_wList.ResumeScrolling();

			UserWindow::Show();
		}

		void RefreshList()
		{
			m_wPointsUnspentText.SetText("Unspent: " + int(stats.statsDict["points_unused"]) );

			auto statAndTitleGroup = m_wList.GetWidgetsById("stat-and-title");
			for(uint i = 0; i < statAndTitleGroup.length(); i++)
			{
				auto m_wItem = cast<ScalableSpriteButtonWidget>(statAndTitleGroup[i].m_children[0]);
				m_wItem.m_enabled = ( int(stats.statsDict["points_unused"]) > 0 );
				m_wItem.m_tooltipText = int(stats.statsDict[ stats.statsDict.getKeys()[i] ]);
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");

			if (parse[0] == "action")
			{
				StatsSystemNS::AddPointTo(parse[1]);
				RefreshList();
			}
			else
				UserWindow::OnFunc(sender, name);
		}
	}
}
