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
const int kNumberOfTreasures = 1;

struct Graphics
{
	Img Unknown;
	Img Over;
	Img Player;
	Img Steps;
	Img Action;

	Img Treasure[kNumberOfTreasures];

	Img Water[kNumberOfSubs];
	Img Grass[kNumberOfSubs];

	Graphics()
	{
		Unknown = LoadImage("unknown.png");
		Over = LoadImage("over.png");
		Player = LoadImage("player.png");
		Steps = LoadImage("steps.png");
		Action = LoadImage("action.png");

		for(int i=0; i<kNumberOfTreasures; ++i)
			Treasure[i] = LoadImage( (Streamer() << "treasure" << (i+1) << ".png").ss.str() );
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
	boost::uniform_int<> treasure;
public:
	boost::variate_generator<Rng&, boost::uniform_int<> > waterGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > indexGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > worldxGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > worldyGen;
	boost::variate_generator<Rng&, boost::uniform_int<> > treasureGen;

	Random()
		: water(0,2)
		, index(0, kNumberOfSubs-1)
		, worldx(0, Width-1)
		, worldy(0, Height-1)
		, treasure(1, kNumberOfTreasures)
		, waterGen(rng, water)
		, indexGen(rng, index)
		, worldxGen(rng, worldx)
		, worldyGen(rng, worldy)
		, treasureGen(rng, treasure)
	{
		// create a better startup seed
		rng.seed(static_cast<unsigned int>(std::time(0)));
	}
};

const int kBlockSize = 32;
const int kHalfBlockSize = kBlockSize / 2;

const int kOffsetX = 32;
const int kOffsetY = 28;

sf::Sprite CreateSprite(int x, int y, bool offset=true)
{
	sf::Sprite sp;
	if( offset )
	{
		sp.SetPosition(static_cast<float>(kBlockSize*x + kOffsetX), static_cast<float>(kBlockSize*y + kOffsetY));
	}
	else
	{
		sp.SetPosition(static_cast<float>(kBlockSize*x + kHalfBlockSize), static_cast<float>(kBlockSize*y + kHalfBlockSize));
	}
	sp.SetOrigin(static_cast<float>(kHalfBlockSize), static_cast<float>(kHalfBlockSize));
	return sp;
}

struct Block
{
	Block()
		: visible(false)
		, isWater(false)
		, index(0)
		, treasure(0)
	{
	}

	int x;
	int y;
	int treasure; // > 0 == treasure

	void setup(Random* r, int ax, int ay)
	{
		x = ax;
		y = ay;
		treasure = 0;
		isWater = r->waterGen() == 0;
		index = r->indexGen();
	}

	void draw(sf::RenderWindow* app, Graphics* g)
	{
		sf::Sprite sp = CreateSprite(x,y);
		sp.SetImage(img(g));
		app->Draw(sp);
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

const int kMaxSteps = 5;

struct Player;

struct Input
{
	Input()
		: click(false)
		, skip(false)
	{
	}

	bool click;
	bool skip;
};

struct Ai
{
	~Ai() {}
	virtual bool run(const Input& input, sf::RenderWindow* app, Level* l, Player* player) = 0;
	virtual void draw(sf::RenderWindow* app, Graphics* g, Level* l, Player* player) = 0;
};

typedef boost::shared_ptr<Ai> AI;

AI SelectHumanAi();

struct Player
{
	int x;
	int y;

	std::vector<int> treasures;
	int steps;

	AI ai;

	Player()
		: x(0)
		, y(0)
	{
	}

	void setup(Random* r, Level* l)
	{
		moveTo(At(l, r->worldxGen(), r->worldxGen()));
		steps = kMaxSteps;

		ai = SelectHumanAi();
	}

	void draw(sf::RenderWindow* app, Graphics* g, Level* l)
	{
		sf::Sprite sp = CreateSprite(x,y);
		sp.SetImage(*g->Player);
		app->Draw(sp);
		ai->draw(app, g, l, this);
	}

	void drawTreasures(sf::RenderWindow* app, Graphics* g)
	{
		for(std::size_t i=0; i<treasures.size(); ++i)
		{
			sf::Sprite sp = CreateSprite(static_cast<int>(i),0, false);
			const int t = treasures[i]-1;
			sp.SetImage(*g->Treasure[t]);
			app->Draw(sp);
		}

		for(int i=0; i<steps; ++i)
		{
			sf::Sprite sp = CreateSprite(i,0, false);
			sp.SetPosition(sp.GetPosition().x, 600-kHalfBlockSize);
			sp.SetImage(*g->Action);
			app->Draw(sp);
		}
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
		// a* would have been nice, i'll se if i can make it :)
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
		Block* at = At(l, x, y);
		const int stepsNeeded = at->isWater ? 2 : 1;
		if( steps >= stepsNeeded )
		{
			Block* b = At(l, p.x, p.y);
			moveTo(b);
			steps -= stepsNeeded;
		}
	}

	bool run(const Input& input, sf::RenderWindow* app, Level* l)
	{
		return ai->run(input, app, l, this) || steps == 0;
	}

	void moveTo(Block* b)
	{
		x = b->x;
		y = b->y;
		b->visible = true;
		if( b->treasure > 0 )
		{
			treasures.push_back(b->treasure);
			b->treasure = 0;
		}
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

		for(int i=0; i<kNumberOfTreasures*2; ++i)
		{
			Block& b = block[r->worldxGen()][r->worldyGen()];
			b.treasure = r->treasureGen();
		}

		player.setup(r, this);
	}

	void draw(sf::RenderWindow* app, Graphics* g)
	{
		for(int w=0; w<Width; ++w)
		{
			for(int h=0; h<Height; ++h)
			{
				Block* b = &(block[w][h]);
				b->draw(app, g);
			}
		}

		player.draw(app, g, this);
	}

	Player* currentPlayer()
	{
		return &player;
	}

	bool updateCurrentPlayer(const Input& input, sf::RenderWindow* app)
	{
		return currentPlayer()->run(input, app, this);
	}
	void selectNextPlayer()
	{
		Player* p = &player;
		p->steps = kMaxSteps;
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

struct HumanAi : public Ai
{
	bool run(const Input& input, sf::RenderWindow* app, Level* l, Player* player)
	{
		bov = l->over(MX(*app), MY(*app));
		if( bov )
		{
			path = player->listMovement(bov);
		}
		else
		{
			path.clear();
		}

		if( input.click ) 
		{
			if( bov )
			{
				if( !path.empty() )
				{
					player->move(l, path[0]);
				}
			}
		}

		return input.skip;
	}

	void draw(sf::RenderWindow* app, Graphics* g, Level* l, Player* player)
	{
		for(std::size_t i=0; i<path.size(); ++i)
		{
			sf::Sprite sp = CreateSprite(path[i].x, path[i].y);
			sp.SetImage(*g->Steps);
			app->Draw(sp);
		}

		player->drawTreasures(app, g);

		if( bov )
		{
			sf::Sprite sp = CreateSprite(bov->x, bov->y);
			sp.SetImage(*g->Over);
			app->Draw(sp);
		}
	}

	Block* bov;
	std::vector<Pos> path;
};

AI SelectHumanAi()
{
	AI ai( new HumanAi() );
	return ai;
}

void main()
{
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), "Exploration game");

	Graphics g;
	Random r;
	Input input;
	Level l;
	l.setup(&r);

	bool mb = false;

	while (App.IsOpened())
	{
		sf::Event Event;

		input.skip = false;

		while (App.GetEvent(Event))
		{
			if (Event.Type == sf::Event::Closed)
			{
				App.Close();
			}
			if( Event.Type == sf::Event::KeyReleased)
			{
				switch(Event.Key.Code)
				{
				case sf::Key::R:
					l.setup(&r);
					break;
				case sf::Key::Escape:
					input.skip = true;
					break;
				}
			}
		}

		const bool down = App.GetInput().IsMouseButtonDown(sf::Mouse::Left);
		input.click = down && !mb;
		mb = down;

		bool next = l.updateCurrentPlayer(input, &App);
		if( next )
		{
			l.selectNextPlayer();
		}

		App.Clear();

		l.draw(&App, &g);

		App.Display();
	}
}
