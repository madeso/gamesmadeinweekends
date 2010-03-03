#include <string>
#include <sstream>
#include <iostream>
#include <boost/shared_ptr.hpp>
#include <boost/noncopyable.hpp>
#include <SFML/Graphics.hpp>
#include "../upgrayedd/libraries.hpp"
#include "../upgrayedd/sfml-math.hpp"
#include "../upgrayedd/message.hpp"
#include "../upgrayedd/imgpool.hpp"
#include "../upgrayedd/ExceptionInformation.hpp"
#include "../upgrayedd/debug.hpp"
#include "../upgrayedd/input.hpp"

using namespace upgrayedd;

void game()
{
	const std::string title = std::string("upgrayedd-test") + (IsDebug()? " (debug build)" : "");
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), title);

	Img img = Load("../gfx/bkg.jpg");
	sf::Sprite sp(*img);
	sp.Resize(640,480);

	sf::View camera(sf::Vector2f(320,240), sf::Vector2f(640,480));

	App.SetView(camera);

	bool isRunning = true;

	sf::Clock Clock;
	while (isRunning)
	{
		const float delta = Clock.GetElapsedTime();
		Clock.Reset();

		sf::Event Event;
		while (App.GetEvent(Event))
		{
			if (Event.Type == sf::Event::Closed) isRunning = false;

			if ((Event.Type == sf::Event::KeyPressed) && (Event.Key.Code == sf::Key::Escape))
				isRunning = false;
		}

		const float speed = App.GetInput().IsKeyDown(sf::Key::LShift) || App.GetInput().IsKeyDown(sf::Key::RShift)
			? 70.0f : 25.0f;

		camera.Move(GetNormalized(sf::Vector2f(KeyFloat(App, sf::Key::Right, sf::Key::Left),
			KeyFloat(App, sf::Key::Down, sf::Key::Up))) * delta * speed);


		App.Clear();
		App.Draw(sp);
		App.Display();
	}
}

void main()
{
	try
	{
		game();
	}
	catch(...)
	{
		if( IsDebug() )
		{
			throw;
		}
		else
		{
			ExceptionInformation ex;
			Message("Error!", ex.message());
		}
	}
}
