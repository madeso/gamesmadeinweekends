#include <string>
#include <stdexcept>
#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>

#include <SFML/Graphics.hpp>
#include <AntTweakBar.h>
#include <Box2D.h>
#include <boost/smart_ptr.hpp>

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
	Image cloud;
	Image grass;
	Image dirt;

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
		LoadImage(&cloud, "..\\cloud.png");
		LoadImage(&grass, "..\\grass.png");
		LoadImage(&dirt, "..\\dirt.png");

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

RenderWindow* gWindow = 0; // yuck!
float gTime = 0; // double yuck!!

void DrawSprite(const Sprite& s)
{
	if( gWindow ) gWindow->Draw(s);
}

const int kTileSize = 80;
const int kTileSpace = 10;

const float kExtraPhysics = 100.0f;

struct Level;

struct Object
{
	Object(Level* l)
		: level(l)
		, doRemove(false)
	{
	}

	virtual ~Object()
	{
	}

	virtual void update(float delta) = 0;

	virtual void draw(RenderWindow* rw) = 0;

	bool shouldRemove() const
	{
		return doRemove;
	}

	Level* level;
	bool doRemove;
};

void DrawObject(boost::shared_ptr<Object> obj)
{
	obj->draw(gWindow);
}


void UpdateObject(boost::shared_ptr<Object> obj)
{
	obj->update(gTime);
}

bool ShouldRemoveObject(boost::shared_ptr<Object> obj)
{
	return obj->shouldRemove();
}


struct Level
{
	Level(Images& imgs, const std::string& level)
	{
		std::ifstream f(level.c_str());
		if( f.good() == false ) throw level + " - file not found";

		int w=0; int h=0;

		f >> w;
		f >> h;

		b2AABB worldAABB;
		worldAABB.lowerBound.Set(-kExtraPhysics, -h*kTileSize - kExtraPhysics);
		worldAABB.upperBound.Set(w*kTileSize + kExtraPhysics, kExtraPhysics);

		b2World world(worldAABB, b2Vec2(0.0f, -10.0f), true);

		if( f.good() == false ) throw level + " - failed to load size";

		for(int y=h-1; y>=0; --y)
		{
			for(int x=0; x<w; ++x)
			{
				int type = 0;
				f >> type;

				Vector2f pos(x*kTileSize, (h-y)*kTileSize);

				Sprite sprite;
				sprite.SetPosition(pos);
				sprite.SetCenter(kTileSpace, kTileSpace);

				switch(type)
				{
				case 0: // air
					break;
				case 1: // cloud
					sprite.SetImage(imgs.cloud);
					sprites.push_back( sprite );
					break;
				case 2: // grass
					sprite.SetImage(imgs.grass);
					sprites.push_back( sprite );
					break;
				case 3: // dirt
					sprite.SetImage(imgs.dirt);
					sprites.push_back( sprite );
					break;
				}
			}

			if( f.fail() )
			{
				std::stringstream ss;
				ss << level << " - failed to load row" << y << "(" << w << ", "<< h << ")";
				throw ss.str();
			}
		}
	}

	void draw(RenderWindow* rw)
	{
		gWindow = rw;
		std::for_each(sprites.begin(), sprites.end(), DrawSprite);
		std::for_each(objects.begin(), objects.end(), DrawObject);
		gWindow = 0;
	}

	void update(float delta)
	{
		gTime = delta;
		std::for_each(objects.begin(), objects.end(), UpdateObject);
		objects.erase(std::remove_if(objects.begin(), objects.end(), ShouldRemoveObject), objects.end());
	}

	void add(boost::shared_ptr<Object> o)
	{
		objects.push_back(o);
	}
private:
	std::vector<Sprite> sprites;
	std::auto_ptr<b2World> pworld;
	std::vector<boost::shared_ptr<Object> > objects;
};

const float LengthOf(const Vector2f& source)
{
	return sqrt((source.x * source.x) + (source.y * source.y));
}

const Vector2f operator+(const Vector2f& l, const Vector2f& r)
{
	return Vector2f(l.x+r.x, l.y + r.y);
}
const Vector2f operator*(const Vector2f& l, float s)
{
	return Vector2f(l.x*s, l.y * s);
}
const Vector2f operator*(float s, const Vector2f& l)
{
	return Vector2f(l.x*s, l.y * s);
}
const Vector2f operator/(const Vector2f& l, float s)
{
	return Vector2f(l.x/s, l.y / s);
}
float Within(float min, float v, float max)
{
	if( v < min ) return min;
	else if( v > max ) return max;
	else return v;
}

struct Player : Object
{
	Sprite bodyclosed;
	Sprite bodyopen;
	Sprite headleft;
	Sprite headright;
	Sprite wingsdown;
	Sprite wingsmiddle;
	Sprite wingsup;

	sf::Vector2f position;
	sf::Vector2f target;

	float flaptime;
	float puketime;
	float flapbonus;
	bool facingLeft;

	Player(Level* l, Images& imgs)
		: Object(l)
		, bodyclosed(imgs.bodyclosed)
		, bodyopen(imgs.bodyopen)
		, headleft(imgs.headleft)
		, headright(imgs.headright)
		, wingsdown(imgs.wingsdown)
		, wingsmiddle(imgs.wingsmiddle)
		, wingsup(imgs.wingsup)
		, position(0,0)
		, target(0,0)
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

	void update(float delta)
	{
		if( puketime > 0 ) puketime -= delta;

		if( flapbonus > 0 ) flaptime += delta * (flapbonus + 1);
		else flaptime += delta;

		if( flapbonus > 0 ) flapbonus -= flapbonus * delta;
		
		const float bonus = Within(1, flapbonus+1, 5);

		const Vector2f dd =target - position;
		const float length = LengthOf(dd);
		const Vector2f direction = (dd / length) * Within(0.5f, length/150, 1) * 30 * delta;
		position += direction * bonus;
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

void game()
{
	TwHandleErrors(BreakOnError);

	TweakBar tweaker;

	TwBar* bar = TwNewBar("main");
	TwWindowSize(800, 600); // call this or get a bad-size error on draw
	const sf::Vector2f HalfSize(400, 300);
	RenderWindow App(sf::VideoMode(800, 600, 32), "SFML Graphics");

	TwAddVarRW(bar, "Time per flap", TW_TYPE_FLOAT, &kTimePerFlap, " min=0.05 max=1 step=0.01 ");
	TwAddVarRW(bar, "Puke time", TW_TYPE_FLOAT, &kPukeTime,        " min=0.05 max=2 step=0.01 ");

	Color bkg(25, 115, 201);
	Images img;

	Level level(img, "..\\game.lvl");

	boost::shared_ptr<Player> player( new Player(&level, img) );
	level.add(player);

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
			if( pukes > 0 && player->puketime < 0.1f)
			{
				player->puketime = kPukeTime;
			}

			if( flaps > 0)
			{
				player->flapbonus += flaps;
			}

			player->target = App.ConvertCoords(App.GetInput().GetMouseX(), App.GetInput().GetMouseY());
			App.SetView( View(player->position, HalfSize) );
			
			level.update(delta);
		}

		App.Clear(bkg);
		level.draw(&App);

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