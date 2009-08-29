#include <string>
#include <stdexcept>
#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>

#include <SFML/Graphics.hpp>
#include <AntTweakBar.h>
#include <Box2D.h>

#ifdef NDEBUG
#pragma comment(lib, "sfml-main.lib")
#pragma comment(lib, "sfml-system.lib")
#pragma comment(lib, "sfml-window.lib")
#pragma comment(lib, "sfml-graphics.lib")
#pragma comment(lib, "box2d.lib")
#else
#pragma comment(lib, "sfml-main-d.lib")
#pragma comment(lib, "sfml-system-d.lib")
#pragma comment(lib, "sfml-window-d.lib")
#pragma comment(lib, "sfml-graphics-d.lib")
#pragma comment(lib, "box2d_d.lib")
#endif

using namespace sf;

struct ExceptionInformation
{
	std::string message;

	explicit ExceptionInformation(const std::string& m)
		: message(m)
	{
	}

	// useless atm
	ExceptionInformation& append(const std::string& str)
	{
		return *this;
	}

	static ExceptionInformation Collect()
	{
		try 
		{
			throw;
		}
		catch(const char* c)
		{
			return ExceptionInformation(c);
		}
		catch(const std::string& s)
		{
			return ExceptionInformation(s);
		}
		catch(const ExceptionInformation& e)
		{
			return e;
		}

		return ExceptionInformation("");
	}
};

void LoadImage(Image* img, const std::string& file)
{
	bool result = img->LoadFromFile(file);
	if( result ) return;
	std::string message = "Failed to load image " + file;
	throw message;
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

void TW_CALL BreakOnError(const char *errorMessage)
{
	OutputDebugStringA(errorMessage);
	throw errorMessage;
}

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

struct Images
{
	Image grass;

	// player
	Image bodyclosed;
	Image bodyopen;
	Image headleft;
	Image headright;
	Image wingsdown;
	Image wingsmiddle;
	Image wingsup;


	Images()
	{
		LoadImage(&grass, "..\\grass.png");

		LoadImage(&bodyclosed, "..\\player\\bodyclosed.png");
		LoadImage(&bodyopen, "..\\player\\bodyopen.png");
		LoadImage(&headleft, "..\\player\\headleft.png");
		LoadImage(&headright, "..\\player\\headright.png");
		LoadImage(&wingsdown, "..\\player\\wingsdown.png");
		LoadImage(&wingsmiddle, "..\\player\\wingsmiddle.png");
		LoadImage(&wingsup, "..\\player\\wingsup.png");
	}
};

void RenderAt(Sprite* sp, RenderWindow* rw, const Vector2f& pos)
{
	sp->SetPosition(pos);
	rw->Draw(*sp);
}

float kTimePerFlap = 0.3f;
float kPukeTime = 0.7f;

struct Player
{
	Sprite bodyclosed;
	Sprite bodyopen;
	Sprite headleft;
	Sprite headright;
	Sprite wingsdown;
	Sprite wingsmiddle;
	Sprite wingsup;

	sf::Vector2f position;

	float flaptime;
	float puketime;
	float flapbonus;
	bool facingLeft;

	Player(Images& imgs)
		: bodyclosed(imgs.bodyclosed)
		, bodyopen(imgs.bodyopen)
		, headleft(imgs.headleft)
		, headright(imgs.headright)
		, wingsdown(imgs.wingsdown)
		, wingsmiddle(imgs.wingsmiddle)
		, wingsup(imgs.wingsup)
		, position(0,0)
		, flaptime(0)
		, puketime(0)
		, flapbonus(0)
		, facingLeft(false)
	{
	}

	void draw(RenderWindow* rw)
	{
		drawBody(rw);
		drawWings(rw);
		drawHead(rw);
	}

	void step(float delta)
	{
		if( puketime > 0 ) puketime -= delta;

		if( flapbonus > 0 ) flaptime += delta * (flapbonus + 1);
		else flaptime += delta;

		if( flapbonus > 0 ) flapbonus -= flapbonus * delta;
	}

private:
	void render(Sprite* sp, RenderWindow* rw)
	{
		RenderAt(sp, rw, position - Vector2f(23, 22));
	}

	void drawWings(RenderWindow* rw)
	{
		int index = 0;

		const int kMaxFlaps = 4;
		while(flaptime > kTimePerFlap*kMaxFlaps ) flaptime -= kTimePerFlap * kMaxFlaps;
		     if( flaptime < kTimePerFlap*1 ) index = 0;
		else if( flaptime < kTimePerFlap*2 ) index = 1;
		else if( flaptime < kTimePerFlap*3 ) index = 2;
		else if( flaptime < kTimePerFlap*4 ) index = 1;

		switch(index) 
		{
		case 0: render(&wingsup, rw); break;
		case 1: render(&wingsmiddle, rw); break;
		default:
		case 2: render(&wingsdown, rw); break;
		}
	}

	void drawBody(RenderWindow* rw)
	{
		if( puketime > 0.1f ) render(&bodyopen, rw);
		else render(&bodyclosed, rw);
	}

	void drawHead(RenderWindow* rw)
	{
		if( facingLeft ) render(&headleft, rw);
		else render(&headright, rw);
	}
};

RenderWindow* gWindow = 0; // yuck!

void DrawSprite(const Sprite& s)
{
	if( gWindow ) gWindow->Draw(s);
}

struct Level
{
	Level(const std::string& level)
	{
		std::ifstream f(level.c_str());
		if( f.good() == false ) throw level + " - file not found";

		int width=0; int height=0;

		f >> width;
		f >> height;

		if( f.good() == false ) throw level + " - failed to load size";

		for(int y=h-1; y>=0; --y)
		{
			for(int x==0; x<w; ++x)
			{
				int type = 0;
				f >> type;

				switch(type)
				{
				case 0: // air
					break;
				case 1: // cloud
					break;
				case 2: // grass
					break;
				case 3: // dirt
					break;
				}
			}

			if( f.good() == false )
			{
				std::stringstream ss;
				ss << level << " - failed to load row" << y << "(" << w << ", "<< h << ")";
				throw ss.str();
			}
		}
	}

	void drawHead(RenderWindow* rw)
	{
		gWindow = rw;
		std::for_each(sprites.begin(), sprites.end(), DrawSprite);
		gWindow = 0;
	}
private:
	std::vector<Sprite> sprites;
};

void game()
{
	TwHandleErrors(BreakOnError);

	TweakBar tweaker;

	TwBar* bar = TwNewBar("main");
	TwWindowSize(800, 600); // call this or get a bad-size error on draw

	b2AABB worldAABB;
	worldAABB.lowerBound.Set(-100.0f, -100.0f);
	worldAABB.upperBound.Set(100.0f, 100.0f);


	TwAddVarRW(bar, "Time per flap", TW_TYPE_FLOAT, &kTimePerFlap, " min=0.05 max=1 step=0.01 ");
	TwAddVarRW(bar, "Puke time", TW_TYPE_FLOAT, &kPukeTime,        " min=0.05 max=2 step=0.01 ");
	b2Vec2 gravity(0.0f, -10.0f);
	bool doSleep = true;
	b2World world(worldAABB, gravity, doSleep);


	RenderWindow App(sf::VideoMode(800, 600, 32), "SFML Graphics");
	Color bkg(25, 115, 201);
	Images img;

	Sprite grass(img.grass);
	Player player(img);

	sf::Clock Clock;

	bool flipbuttons = false;
	bool debug = false;

	while (App.IsOpened())
	{
		Event Event;

		int pukes = 0;
		int flaps = 0;

		const float delta = Clock.GetElapsedTime();
		Clock.Reset();

		while (App.GetEvent(Event))
		{
			if (Event.Type == sf::Event::Closed)
				App.Close();

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
			else 
			{
				if( Event.Type == sf::Event::MouseButtonReleased )
				{
					if( Event.MouseButton.Button == Mouse::Left )
					{
						if( flipbuttons ) ++pukes;
						else ++flaps;
					}
					else if( Event.MouseButton.Button == Mouse::Right )
					{
						if( flipbuttons ) ++flaps;
						else ++pukes;
					}
				}
			}
		}

		if( !debug )
		{
			if( pukes > 0 && player.puketime < 0.1f)
			{
				player.puketime = kPukeTime;
			}

			if( flaps > 0)
			{
				player.flapbonus += flaps;
			}

			player.position = Vector2f( static_cast<float>(App.GetInput().GetMouseX()),
				static_cast<float>(App.GetInput().GetMouseY()));
			player.step(delta);
		}

		App.Clear(bkg);
		App.Draw(grass);
		player.draw(&App);

		if( debug ) TwDraw();

		App.Display();
	}
}

void main()
{
#ifdef NDEBUG
	try 
	{
		game();
	}
	catch(...)
	{
		const ExceptionInformation& e = ExceptionInformation::Collect();
		MessageBox(0, e.message.c_str(), "Failed", MB_OK);
	}
#else
	game(); // let msvc catch thoose exceptions instead
#endif
}