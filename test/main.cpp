#include <SFML/Graphics.hpp>
#include <AntTweakBar.h>

#include <string>
#include <stdexcept>

#ifdef NDEBUG
#pragma comment(lib, "sfml-main.lib")
#pragma comment(lib, "sfml-system.lib")
#pragma comment(lib, "sfml-window.lib")
#pragma comment(lib, "sfml-graphics.lib")
#else
#pragma comment(lib, "sfml-main-d.lib")
#pragma comment(lib, "sfml-system-d.lib")
#pragma comment(lib, "sfml-window-d.lib")
#pragma comment(lib, "sfml-graphics-d.lib")
#endif

void Load(sf::Image* img, const std::string& file)
{
	const bool result = img->LoadFromFile(file);
	if( result == true ) return;
	std::string message = "Failed to load image" + file;
	throw std::exception(message.c_str());
}

struct TweakBar
{
	TweakBar()
	{
		TwInit(TW_OPENGL, NULL);
	}

	~TweakBar()
	{
		TwTerminate();
	}
};

bool SfmlHandle(const sf::Event& event)
{
	bool handled = 0;

	switch( event.Type )
	{
	case sf::Event::KeyPressed:
		/*if ( event->key.keysym.unicode!=0 && (event->key.keysym.unicode & 0xFF00)==0 )
		{
			if( (event->key.keysym.unicode & 0xFF)<32 && (event->key.keysym.unicode & 0xFF)!=event->key.keysym.sym )
				handled = TwKeyPressed((event->key.keysym.unicode & 0xFF)+'a'-1, event->key.keysym.mod);
			else
				handled = TwKeyPressed(event->key.keysym.unicode & 0xFF, event->key.keysym.mod);
		}
		else*/
		{
			int mod = TW_KMOD_NONE;
			if( event.Key.Shift ) mod |= TW_KMOD_SHIFT;
			if( event.Key.Control ) mod |= TW_KMOD_CTRL;
			if( event.Key.Alt ) mod |= TW_KMOD_ALT;
			handled = TwKeyPressed(event.Key.Code, mod) != 0;
		}
		break;
	case sf::Event::MouseMoved:
		handled = TwMouseMotion(event.MouseMove.X, event.MouseMove.Y)  != 0;
		break;
	case sf::Event::MouseButtonPressed:
	case sf::Event::MouseButtonReleased:
		/*if( event->type==SDL_MOUSEBUTTONDOWN && (event->button.button==4 || event->button.button==5) )  // mouse wheel
		{
			static int s_WheelPos = 0;
			if( event->button.button==4 )
				++s_WheelPos;
			else
				--s_WheelPos;
			handled = TwMouseWheel(s_WheelPos);
		}
		else*/
		{
			TwMouseButtonID btn;
			bool mh = true;
			switch(event.MouseButton.Button)
			{
			case sf::Mouse::Left: btn = TW_MOUSE_LEFT; break;
			case sf::Mouse::Middle: btn = TW_MOUSE_MIDDLE; break;
			case sf::Mouse::Right: btn = TW_MOUSE_RIGHT; break;
			default: mh = false; break;
			}
			if( mh ) handled = TwMouseButton((event.Type==sf::Event::MouseButtonReleased)?TW_MOUSE_RELEASED:TW_MOUSE_PRESSED, btn) != 0;
		}
		break;
	case sf::Event::Resized:
		TwWindowSize(event.Size.Width, event.Size.Height);
		break;
	}

	return handled;
}

void TW_CALL BreakOnError(const char *errorMessage)
{
	OutputDebugStringA(errorMessage);
	throw errorMessage;
}

void main()
{
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), "SFML Graphics");

	TwHandleErrors(BreakOnError);

	TweakBar tweaker;

	TwBar* bar = TwNewBar("main");
	TwWindowSize(800, 600); // call this or get a bad-size error on draw

	sf::Image img;
	Load(&img, "..\\img1.png");

	float x = 0;
	float y = 0;
	
	TwAddVarRW(bar, "x", TW_TYPE_FLOAT, &x, " min=0 max=600 step=0.5 ");
	TwAddVarRW(bar, "y", TW_TYPE_FLOAT, &y, " min=0 max=600 step=0.5 ");

	sf::Sprite sprite(img);

	bool debug = true;

	// Start game loop
	while (App.IsOpened())
	{
		// Process events
		sf::Event Event;
		while (App.GetEvent(Event))
		{
			if( Event.Type == sf::Event::KeyReleased )
			{
				if( Event.Key.Code == sf::Key::Tab )
				{
					debug = !debug;
				}
				else if (Event.Key.Code == sf::Key::Escape )
				{
					App.Close();
				}
			}

			if( debug ) SfmlHandle(Event);
		}

		sprite.SetX(x);
		sprite.SetY(y);

		// Clear the screen (fill it with black color)
		App.Clear();
		App.Draw(sprite);
		if( debug ) TwDraw();
		// Display window contents on screen
		App.Display();
	}
}