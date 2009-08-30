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

#pragma comment(lib, "opengl32.lib")

using namespace sf;

const float kPhysicsScale = 5.0f; // pixels is 1 meter
const int kTileSize = 80;
const int kTileSpace = 10;
const float kExtraPhysics = 600.0f;
const float kPhysTime = 0.01f;

float physics2world(float p)
{
	return p * kPhysicsScale;
}
float world2physics(float p)
{
	return p / kPhysicsScale;
}

const float kGravity = 8.0f;

void trVertex2f(float x, float y)
{
	glVertex2f(physics2world(x), physics2world(y));
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// from box2d samples
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This class implements debug drawing callbacks that are invoked
// inside b2World::Step.
class DebugDraw : public b2DebugDraw
{
public:
	void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);

	void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);

	void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);

	void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);

	void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);

	void DrawXForm(const b2XForm& xf);
};

void DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glColor3f(color.r, color.g, color.b);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < vertexCount; ++i)
	{
		trVertex2f( vertices[i].x, vertices[i].y);
	}
	glEnd();
}

void DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color)
{
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(0.5f * color.r, 0.5f * color.g, 0.5f * color.b, 0.5f);
	glBegin(GL_TRIANGLE_FAN);
	for (int32 i = 0; i < vertexCount; ++i)
	{
		trVertex2f(vertices[i].x, vertices[i].y);
	}
	glEnd();
	glDisable(GL_BLEND);

	glColor4f(color.r, color.g, color.b, 1.0f);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < vertexCount; ++i)
	{
		trVertex2f(vertices[i].x, vertices[i].y);
	}
	glEnd();
}

void DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	glColor3f(color.r, color.g, color.b);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		trVertex2f(v.x, v.y);
		theta += k_increment;
	}
	glEnd();
}

void DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(0.5f * color.r, 0.5f * color.g, 0.5f * color.b, 0.5f);
	glBegin(GL_TRIANGLE_FAN);
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		trVertex2f(v.x, v.y);
		theta += k_increment;
	}
	glEnd();
	glDisable(GL_BLEND);

	theta = 0.0f;
	glColor4f(color.r, color.g, color.b, 1.0f);
	glBegin(GL_LINE_LOOP);
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
		trVertex2f(v.x, v.y);
		theta += k_increment;
	}
	glEnd();

	b2Vec2 p = center + radius * axis;
	glBegin(GL_LINES);
	trVertex2f(center.x, center.y);
	trVertex2f(p.x, p.y);
	glEnd();
}

void DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	glColor3f(color.r, color.g, color.b);
	glBegin(GL_LINES);
	trVertex2f(p1.x, p1.y);
	trVertex2f(p2.x, p2.y);
	glEnd();
}

void DebugDraw::DrawXForm(const b2XForm& xf)
{
	b2Vec2 p1 = xf.position, p2;
	const float32 k_axisScale = 0.4f;
	glBegin(GL_LINES);
	
	glColor3f(1.0f, 0.0f, 0.0f);
	trVertex2f(p1.x, p1.y);
	p2 = p1 + k_axisScale * xf.R.col1;
	trVertex2f(p2.x, p2.y);

	glColor3f(0.0f, 1.0f, 0.0f);
	trVertex2f(p1.x, p1.y);
	p2 = p1 + k_axisScale * xf.R.col2;
	trVertex2f(p2.x, p2.y);

	glEnd();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

	Image puke;
	Image explosion;
	Image bang;


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

		LoadImage(&puke, "..\\puke.png");
		LoadImage(&explosion, "..\\explosion.png");
		LoadImage(&bang, "..\\bang.png");
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
		: phystime(0)
	{
		std::ifstream f(level.c_str());
		if( f.good() == false ) throw level + " - file not found";

		int w=0; int h=0;

		f >> w;
		f >> h;

		b2AABB worldAABB;
		worldAABB.lowerBound.Set( world2physics(-kExtraPhysics), world2physics(- kExtraPhysics));
		worldAABB.upperBound.Set(world2physics(w*kTileSize + kExtraPhysics), world2physics(h*kTileSize + kExtraPhysics));

		pworld.reset( new b2World(worldAABB, b2Vec2(0.0f, kGravity), true) );

		if( f.good() == false ) throw level + " - failed to load size";

		for(int y=h-1; y>=0; --y)
		{
			for(int x=0; x<w; ++x)
			{
				int type = 0;
				f >> type;

				Vector2f pos(x*kTileSize, (h-y)*kTileSize);
				b2Vec2 ppos( world2physics(pos.x), world2physics(pos.y + kTileSize) );

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
					{
						sprite.SetImage(imgs.grass);
						sprites.push_back( sprite );

						b2BodyDef groundBodyDef;
						groundBodyDef.position = ppos;
						b2Body* groundBody = pworld->CreateBody(&groundBodyDef);
						b2PolygonDef groundShapeDef;
						groundShapeDef.SetAsBox( world2physics(kTileSize), world2physics(kTileSize));
						groundBody->CreateShape(&groundShapeDef);
					}
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
		phystime += delta;
		while( phystime > kPhysTime ) 
		{
			pworld->Step(kPhysTime, 10);
			phystime -= kPhysTime;
		}

		gTime = delta;
		objects.insert(objects.end(), objectstoadd.begin(), objectstoadd.end());
		objectstoadd.resize(0);
		std::for_each(objects.begin(), objects.end(), UpdateObject);
		objects.erase(std::remove_if(objects.begin(), objects.end(), ShouldRemoveObject), objects.end());
	}

	void add(boost::shared_ptr<Object> o)
	{
		objectstoadd.push_back(o);
	}

	std::auto_ptr<b2World> pworld;
private:
	std::vector<Sprite> sprites;
	std::vector<boost::shared_ptr<Object> > objects;
	std::vector<boost::shared_ptr<Object> > objectstoadd;
	float phystime;
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

struct Fading : Object
{
	/*
	alpha: 1         1     ...          0
	time:  0 ... fadestart ... fadestart+fadetime <- remove
	*/
	float time;
	float fadestart;
	float fadetime;
	Sprite sp;
	Vector2f mo;
	float r;

	Fading(Level* l, Image& img, const Vector2f& p, const Vector2f& center, const Vector2f& move, const float rot, float fstart, float ftime)
		: Object(l)
		, time(0)
		, fadestart(fstart)
		, fadetime(ftime)
		, sp(img, p)
		, mo(move)
		, r(rot)
	{
		sp.SetCenter(center);
	}

	void update(float delta)
	{
		sp.SetPosition(sp.GetPosition() + mo*delta);
		sp.SetRotation(sp.GetRotation() + r*delta);
		time += delta;
		if( time > (fadestart + fadetime) )
		{
			doRemove = true;
		}
		else if( time > fadestart && fadetime > 0)
		{
			const float alpha = 1 - ((time - fadestart) / fadetime);
			if( alpha < -0.1f || alpha > 1.1f )
			{
				throw "oh noes!";
			}
			sp.SetColor(sf::Color(255,255,255, static_cast<Uint8>(255*alpha)));
		}
	}

	void draw(RenderWindow* rw)
	{
		rw->Draw(sp);
	}
};


struct Puke : Object
{
	b2Body* body;
	float time;
	Sprite sp;
	Images& imgs;

	Puke(Level* l, Images& img, sf::Vector2f p, sf::Vector2f dir)
		: Object(l)
		, body(0)
		, time(9)
		, sp(img.puke)
		, imgs(img)
	{
		sp.SetCenter(13, 13);
		b2BodyDef bodyDef;
		bodyDef.position.Set( world2physics(p.x), world2physics(p.y) );
		body = l->pworld->CreateBody(&bodyDef);

		b2CircleDef shapeDef;
		shapeDef.radius = world2physics(10.0f);
		shapeDef.localPosition.Set(0.0f, 0.0f);
		shapeDef.density = 0.7f;
		shapeDef.friction = 0.3f;
		shapeDef.restitution = 0.8f; // bouncyness
		body->CreateShape(&shapeDef);
		body->SetMassFromShapes();
	}

	~Puke()
	{
		level->pworld->DestroyBody(body);
	}

	virtual void update(float delta)
	{
		b2Vec2 pos = body->GetPosition();
		Vector2f sfpos( physics2world(pos.x), physics2world(pos.y) );

		if( time > 0 )
		{
			time -= delta;
		}
		else
		{
			if( shouldRemove() == false )
			{
				boost::shared_ptr<Fading> explosion( new Fading(level, imgs.explosion, sfpos, Vector2f(45,40), Vector2f(0,-5), 0, 3, 3));
				level->add(explosion);

				boost::shared_ptr<Fading> bang( new Fading(level, imgs.bang, sfpos, Vector2f(60,50), Vector2f(0,-15), 0, 2, 2));
				level->add(bang);
			}
			doRemove = true;
			return;
		}

		sp.SetPosition( sfpos );
	}

	virtual void draw(RenderWindow* rw)
	{
		rw->Draw(sp);
	}
};

struct Player : Object
{
	Images& images;

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
	b2Body* body;
	int flaps;
	int pukes;

	Player(Level* l, Images& imgs)
		: Object(l)
		, images(imgs)
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
		, body(0)
		, flaps(0)
		, pukes(0)
	{
		Vector2f center(25,25);
		bodyclosed.SetCenter(center);
		bodyopen.SetCenter(center);
		headleft.SetCenter(center);
		headright.SetCenter(center);
		wingsdown.SetCenter(center);
		wingsmiddle.SetCenter(center);
		wingsup.SetCenter(center);

		b2BodyDef bodyDef;
		bodyDef.position.Set(position.x, position.y);
		body = l->pworld->CreateBody(&bodyDef);

		b2CircleDef shapeDef;
		shapeDef.radius = world2physics(20.0f);
		shapeDef.localPosition.Set(0.0f, 0.0f);
		shapeDef.density = 0.3f;
		shapeDef.friction = 0.3f;
		shapeDef.restitution = 0.4f; // bouncyness
		body->CreateShape(&shapeDef);
		body->SetMassFromShapes();
	}

	void draw(RenderWindow* rw)
	{
		drawBody(rw);
		drawWings(rw);
		drawHead(rw);

		std::stringstream ss;
		ss << position.x << ", " << position.y;

		/*String Text(ss.str().c_str());
		Text.SetPosition(position);
		Text.SetColor(sf::Color(0,0,0));
		rw->Draw(Text);*/
	}

	void update(float delta)
	{
		flapbonus += flaps;

		if( puketime > 0 ) puketime -= delta;

		if( flapbonus > 0 ) flaptime += delta * (flapbonus + 1);
		else flaptime += delta;

		if( flapbonus > 0 ) flapbonus -= flapbonus * delta;
		
		const float bonus = Within(1, flapbonus+1, 5);

		const Vector2f dd = position - target;
		const float length = LengthOf(dd);
		const Vector2f direction = (dd / length) * Within(0.5f, length/150, 1) * -kGravity * 600;

		for(int i=0; i<flaps; ++i)
		{
			body->ApplyImpulse( b2Vec2(world2physics(direction.x), world2physics(direction.y)), body->GetWorldCenter());
		}

		if( pukes > 0 && puketime < 0.1f)
		{
			puketime = kPukeTime;
			boost::shared_ptr<Puke> p( new Puke(level, images, position + (-dd/length) * world2physics(350), direction) );
			level->add(p);
		}

		b2Vec2 p = body->GetPosition();
		position = Vector2f(physics2world(p.x), physics2world(p.y));

		facingLeft = target.x < position.x;
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

	DebugDraw debugdraw;
	level.pworld->SetDebugDraw(&debugdraw);

	bool phys_all = false;
	bool phys_shape = false;
	bool phys_join  = false;
	bool phys_coreshape = false;
	bool phys_aabb = false;
	bool phys_obb = false;
	bool phys_pair = false;
	bool phys_com = false;

	TwBar* bar_phys = TwNewBar("physics debug");
#define DEBUG_BOOL(x) TwAddVarRW(bar_phys, #x, TW_TYPE_BOOL8, &phys_##x, "");
	DEBUG_BOOL(all);
	DEBUG_BOOL(shape);
	DEBUG_BOOL(join);
	DEBUG_BOOL(coreshape);
	DEBUG_BOOL(aabb);
	DEBUG_BOOL(obb);
	DEBUG_BOOL(pair);
	DEBUG_BOOL(com);
#undef DEBUG_BOOL

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

			if( debug )
			{
				SfmlHandle(Event);
			}
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

		{
			uint32 flags = 0;
			if( phys_all || phys_shape)      flags += b2DebugDraw::e_shapeBit;
			if( phys_all || phys_join )      flags += b2DebugDraw::e_jointBit;
			if( phys_all || phys_coreshape)  flags += b2DebugDraw::e_coreShapeBit;
			if( phys_all || phys_aabb)       flags += b2DebugDraw::e_aabbBit;
			if( phys_all || phys_obb)        flags += b2DebugDraw::e_obbBit;
			if( phys_all || phys_pair)       flags += b2DebugDraw::e_pairBit;
			if( phys_all || phys_com)        flags += b2DebugDraw::e_centerOfMassBit;
			debugdraw.SetFlags(flags);
		}

		App.Clear(bkg);
		level.draw(&App);

		if( !debug )
		{
			player->flaps = flaps;
			player->pukes = pukes;

			player->target = App.ConvertCoords(App.GetInput().GetMouseX(), App.GetInput().GetMouseY());
			App.SetView( View(player->position, HalfSize) );
			
			level.update(delta);
		}

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