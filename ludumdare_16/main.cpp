#include <SFML/Graphics.hpp>

#define SFML_DEBUG_EXTRA_NAME "-d"
#define SFML(x) "sfml-" #x SFML_DEBUG_EXTRA_NAME ".lib"

#pragma comment(lib, SFML(system) )
#pragma comment(lib, SFML(main) )
#pragma comment(lib, SFML(graphics) )
#pragma comment(lib, SFML(audio) )
#pragma comment(lib, SFML(window) )

void main()
{
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), "Exploration game");

	while (App.IsOpened())
	{
		sf::Event Event;
		while (App.GetEvent(Event))
		{
			if (Event.Type == sf::Event::Closed)
				App.Close();
		}

		App.Clear();

		App.Display();
	}
}
