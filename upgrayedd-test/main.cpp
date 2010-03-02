#include <string>
#include <sstream>
#include <iostream>
#include <boost/shared_ptr.hpp>
#include <boost/noncopyable.hpp>
#include <SFML/Graphics.hpp>
#include "../upgrayedd/libraries.hpp"
#include "../upgrayedd/sfml-math.hpp"
#include <SOIL.h>

using namespace upgrayedd;

#ifdef _WINDOWS
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#undef WIN32_LEAN_AND_MEAN
#endif

typedef boost::shared_ptr<sf::Image> Img;

bool IsDebug()
{
#ifdef _DEBUG
	return true;
#else
	return false;
#endif
}

class StringBuilder : boost::noncopyable
{
public:
	StringBuilder()
	{
	}

	template<typename T>
	StringBuilder& operator<<(const T& t)
	{
		ss << t;
		return *this;
	}

	std::string str() const
	{
		return ss.str();
	}

	operator std::string() const
	{
		return str();
	}
private:
	std::ostringstream ss;
};

// copied from sfml/src/SFML/Graphics/ImageLoader.cpp, modified to throw exception instead of printing to cerr, and loading to sf::Image instead of a color vector
void LoadImageFromFile(const std::string& filename, sf::Image& img)
{
	int width, height, channels;
	unsigned char* ptr = SOIL_load_image(filename.c_str(), &width, &height, &channels, SOIL_LOAD_RGBA);

	if (ptr)
	{
		bool result = img.LoadFromPixels(width, height, ptr);
		SOIL_free_image_data(ptr);

		if( result == false ) throw (StringBuilder() << "Failed to load pixels from loaded \"" << filename << "\"").str();
	}
	else
	{
		throw (StringBuilder() << "Failed to load image \"" << filename << "\", reason : " << SOIL_last_result()).str();
	}
}

Img Load(const std::string& path)
{
	Img img(new sf::Image());
	LoadImageFromFile(path, *img);
	return img;
}

float Key(sf::Window& App, sf::Key::Code key)
{
	return App.GetInput().IsKeyDown(key) ? 1.0f : 0.0f;
}

void game()
{
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), "upgrayedd test");

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
			? 70 : 25;

		camera.Move(GetNormalized(sf::Vector2f(Key(App, sf::Key::Right) - Key(App, sf::Key::Left),
			Key(App, sf::Key::Down) - Key(App, sf::Key::Up))) * delta * speed);


		App.Clear();
		App.Draw(sp);
		App.Display();
	}
}

struct ExceptionInformation
{
	ExceptionInformation()
	{
		try
		{
			throw;
		}
		catch(const std::string& str)
		{
			message = str;
		}
		catch(char* str)
		{
			message = str;
		}
		catch(...)
		{
			message = "unknown";
		}
	}

	std::string message;
};

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
#if _WINDOWS
			MessageBoxA(0, ex.message.c_str(), "Error!", MB_OK | MB_ICONERROR);
#else
			std::cerr << "Error: " << ex.message << std::endl;
#endif
		}
	}
}
