#include <SFML/Graphics.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/random.hpp>
#include <sstream>

#define SFML_DEBUG_EXTRA_NAME "-d"
#define SFML(x) "sfml-" #x SFML_DEBUG_EXTRA_NAME ".lib"

#pragma comment(lib, SFML(system) )
#pragma comment(lib, SFML(main) )
#pragma comment(lib, SFML(graphics) )
#pragma comment(lib, SFML(audio) )
#pragma comment(lib, SFML(window) )

typedef boost::shared_ptr<sf::Image> Img;

Img LoadImage(const std::string& file)
{
	Img img( new sf::Image() );
	const bool result = img->LoadFromFile(file);
	if( false == result ) throw "Failed to load image resource";
	return img;
}

struct Streamer
{
	std::stringstream ss;
	template<typename T>
	Streamer& operator<<(const T& t)
	{
		ss << t;
		return *this;
	}
};

const int kNumberOfSubs = 1;

struct Graphics
{
	Img Unknown;
	Img Over;
	Img Player;
	Img Steps;

	Img Water[kNumberOfSubs];
	Img Grass[kNumberOfSubs];

	Graphics()
	{
		Unknown = LoadImage("unknown.png");
		Over = LoadImage("over.png");
		Player = LoadImage("player.png");
		Steps = LoadImage("steps.png");
		for(int i=0; i<kNumberOfSubs; ++i)
			Water[i] = LoadImage( (Streamer() << "water" << (i+1) << ".png").ss.str() );
		for(int i=0; i<kNumberOfSubs; ++i)
			Grass[i] = LoadImage( (Streamer() << "grass" << (i+1) << ".png").ss.str() );
	}
};

const int Width = 24;
const int Height = 18;

struct Random
{
public:
	typedef boost::mt19937 Rng;
private:
	Rng rng;
	boost::uniform_int<> water;
	boost::uniform_int<> index;
	boost::uniform_int<> worldx;
	boost::uniform_int<> worldy;
public:
	boost::variate_generator<Rng&, boost::uniform_int<> > waterGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > indexGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > worldxGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > worldyGen;

	Random()
		: water(0,2)
		, index(0, kNumberOfSubs-1)
		, worldx(0, Width-1)
		, worldy(0, Height-1)
		, waterGen(rng, water)
		, indexGen(rng, index)
		, worldxGen(rng, worldx)
		, worldyGen(rng, worldy)
	{
	}
};

const int kBlockSize = 32;
const int kHalfBlockSize = kBlockSize / 2;

const int kOffsetX = 32;
const int kOffsetY = 28;

sf::Sprite CreateSprite(int x, int y)
{
	sf::Sprite sp;
	sp.SetPosition(static_cast<float>(kBlockSize*x + kOffsetX), static_cast<float>(kBlockSize*y + kOffsetY));
	sp.SetOrigin(static_cast<float>(kHalfBlockSize), static_cast<float>(kHalfBlockSize));
	return sp;
}

struct Block
{
	Block()
		: visible(false)
		, isWater(false)
		, index(0)
	{
	}

	int x;
	int y;

	void setup(Random* r, int ax, int ay)
	{
		x = ax;
		y = ay;
		isWater = r->waterGen() == 0;
		index = r->indexGen();
	}

	void draw(sf::RenderWindow* app, Graphics* g, bool over)
	{
		sf::Sprite sp = CreateSprite(x,y);
		sp.SetImage(img(g));
		app->Draw(sp);
		if( over )
		{
			sp.SetImage(*g->Over);
			app->Draw(sp);
		}
	}

	bool isOver(int ox, int oy)
	{
		sf::Rect<int> r(kBlockSize*x, kBlockSize*y, kBlockSize*(x+1), kBlockSize*(y+1) );
		return r.Contains(ox+kHalfBlockSize-kOffsetX, oy+kHalfBlockSize-kOffsetY);
	}

	sf::Image& img(Graphics* g)
	{
		if( visible == false )
		{
			return *g->Unknown;
		}
		else
		{
			if( isWater ) return *g->Water[index];
			else return *g->Grass[index];
		}
	}

	bool visible;
	bool isWater;
	int index;
};

struct Pos
{
	Pos()
		: x(0)
		, y(0)
	{
	}

	Pos(int ax, int ay)
		: x(ax)
		, y(ay)
	{
	}

	Pos change(int cx,int cy) const
	{
		return Pos(x+cx, y+cy);
	}

	bool operator==(const Pos& p) const
	{
		return x==p.x && y==p.y;
	}

	int x;
	int y;
};

struct Level;
Block* At(Level* level, int x, int y);

struct Player
{
	int x;
	int y;

	Player()
		: x(0)
		, y(0)
	{
	}

	void setup(Random* r, Level* l)
	{
		moveTo(At(l, r->worldxGen(), r->worldxGen()));
	}

	void draw(sf::RenderWindow* app, Graphics* g)
	{
		sf::Sprite sp = CreateSprite(x,y);
		sp.SetImage(*g->Player);
		app->Draw(sp);
	}

	bool nextTo(const Block& b)
	{
		const Pos me(x,y);
		const Pos bl(b.x, b.y);

		return me.change(1,0) == bl
			|| me.change(0, 1) == bl
			|| me.change(-1, 0) == bl
			|| me.change(0, -1) == bl;
	}

	std::vector<Pos> listMovement(Block* b)
	{
		std::vector<Pos> m;
		int mx = this->x;
		int my = this->y;
		for(int x=mx+1; x<=b->x; ++x) m.push_back(Pos(x,my));
		for(int x=mx-1; x>=b->x; --x) m.push_back(Pos(x,my));
		mx = b->x;
		for(int y=my+1; y<=b->y; ++y) m.push_back(Pos(mx,y));
		for(int y=my-1; y>=b->y; --y) m.push_back(Pos(mx,y));
		return m;
	}

	void move(Level* l, const Pos& p)
	{
		Block* b = At(l, p.x, p.y);
		moveTo(b);
	}

	void moveTo(Block* b)
	{
		x = b->x;
		y = b->y;
		b->visible = true;
	}
};

struct Level
{
	Block block[Width][Height];

	Player player;

	void setup(Random* r)
	{
		for(int w=0; w<Width; ++w)
		{
			for(int h=0; h<Height; ++h)
			{
				block[w][h].setup(r, w, h);
			}
		}

		player.setup(r, this);
	}

	void draw(sf::RenderWindow* app, Graphics* g, Block* bov, std::vector<Pos>& path)
	{
		for(int w=0; w<Width; ++w)
		{
			for(int h=0; h<Height; ++h)
			{
				Block* b = &(block[w][h]);
				b->draw(app, g, b==bov);
			}
		}

		for(std::size_t i=0; i<path.size(); ++i)
		{
			sf::Sprite sp = CreateSprite(path[i].x, path[i].y);
			sp.SetImage(*g->Steps);
			app->Draw(sp);
		}

		player.draw(app, g);
	}

	Block* over(int x, int y)
	{
		for(int w=0; w<Width; ++w)
		{
			for(int h=0; h<Height; ++h)
			{
				const bool isOver = block[w][h].isOver(x, y);
				if( isOver ) return &(block[w][h]);
			}
		}
		return 0;
	}
};

Block* At(Level* l, int x, int y)
{
	return &l->block[x][y];
}

int MX(const sf::RenderWindow& app)
{
	float mx = static_cast<float>(app.GetInput().GetMouseX());
	float x = mx / app.GetWidth();
	return static_cast<int>(x*800);
}

int MY(const sf::RenderWindow& app)
{
	float mx = static_cast<float>(app.GetInput().GetMouseY());
	float x = mx / app.GetHeight();
	return static_cast<int>(x*600);
}

void main()
{
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), "Exploration game");

	Graphics g;
	Random r;
	Level l;
	l.setup(&r);

	sf::Sprite sp;
	sp.SetImage(*g.Unknown);

	bool mb = false;

	while (App.IsOpened())
	{
		sf::Event Event;
		while (App.GetEvent(Event))
		{
			if (Event.Type == sf::Event::Closed)
				App.Close();
		}

		const bool down = App.GetInput().IsMouseButtonDown(sf::Mouse::Left);
		bool click = down && !mb;
		mb = down;

		Block* bov = l.over(MX(App), MY(App));
		Player* player = &l.player;

		std::vector<Pos> path;
		if( bov )
		{
			path = player->listMovement(bov);
		}

		if( click ) 
		{
			if( bov )
			{
				if( !path.empty() )
					player->move(&l, path[0]);
			}
		}

		App.Clear();

		l.draw(&App, &g, bov, path);

		App.Display();
	}
}