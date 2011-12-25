#include <string>
#include <sstream>
#include <iostream>
#include <fstream>
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
#include "../upgrayedd/Loop.hpp"
#include "../upgrayedd/Sprite.hpp"

#include "yaml-cpp/yaml.h"
#pragma comment(lib, "yaml-cpp.lib")

using namespace upgrayedd;

struct SpriteDef
{
	std::string name;
	std::string texture;
	sf::IntRect sub;
};

void operator>>(const YAML::Node& node, sf::IntRect& rect)
{
	if( node.GetType() == YAML::CT_MAP )
	{
		node["left"] >> rect.Left;
		node["right"] >> rect.Right;
		node["top"] >> rect.Top;
		node["bottom"] >> rect.Bottom;
	}
	else if( node.GetType() == YAML::CT_SEQUENCE )
	{
		node[0] >> rect.Left;
		node[1] >> rect.Right;
		node[2] >> rect.Top;
		node[3] >> rect.Bottom;
	}
	else throw "rect, either a map or a seq";
}

void operator>>(const YAML::Node& node, SpriteDef& sp)
{
	node["name"] >> sp.name;
	node["texture"] >> sp.texture;

	if( const YAML::Node* sub = node.FindValue("sub") )
	{
		*sub >> sp.sub;
	}
	else
	{
		sp.sub = sf::IntRect(0,0,0,0);
	}
}

bool IsValid(const sf::IntRect& re)
{
	const bool invalid = re.Left == 0 && re.Right == 0 && re.Top == 0 && re.Bottom == 0;
	return !invalid;
}

struct SpriteDefPool
{
public:
	SpriteDefPool(ImgPool& ip)
		: img(ip)
	{
	}

	void add(const std::string& file)
	{
		using namespace YAML;

		std::ifstream ifs(file.c_str());
		if( ifs.good() == false ) throw "failed to load " + file;
		Parser parser(ifs);
		Node doc;
		if( parser.GetNextDocument(doc) == false ) throw "no document in " + file;
		const std::size_t count = doc.size();
		for(size_t i=0; i<count; ++i)
		{
			SpriteDef def;
			doc[i] >> def;
			add(def);
		}
	}

	void add(const SpriteDef& def)
	{
		defs[def.name] = def;
	}

	Sprite get(const std::string& name)
	{
		spmap::iterator iter = defs.find(name);
		if( iter == defs.end() ) throw "missing sprite " + name;
		SpriteDef& def = iter->second;
		Sprite sp(img.load(def.texture));
		if( IsValid(def.sub) )
		{
			sp->SetSubRect(def.sub);
		}
		return sp;
	}
private:
	typedef std::map<std::string, SpriteDef> spmap;
	spmap defs;
	ImgPool& img;
};

class GameLoop : public Loop
{
public:
	GameLoop(sf::RenderWindow& app, SpriteDefPool& pool)
		: App(app)
		, sp(pool.get("bkg"))
		, camera(sf::Vector2f(320,240), sf::Vector2f(640,480))
	{
		sp->Resize(640,480);
		App.SetView(camera);
	}

	void onUpdate(float delta)
	{
		sf::Event Event;
		while (App.GetEvent(Event))
		{
			if (Event.Type == sf::Event::Closed)
				abort();

			if ((Event.Type == sf::Event::KeyPressed) && (Event.Key.Code == sf::Key::Escape))
				abort();
		}

		const float speed = App.GetInput().IsKeyDown(sf::Key::LShift) || App.GetInput().IsKeyDown(sf::Key::RShift)
			? 70.0f : 25.0f;

		camera.Move(GetNormalized(sf::Vector2f(KeyFloat(App, sf::Key::Right, sf::Key::Left),
			KeyFloat(App, sf::Key::Down, sf::Key::Up))) * delta * speed);
	}

	void onRender(float)
	{
		App.Clear();
		App.Draw(sp);
		App.Display();
	}
private:
	sf::RenderWindow& App;
	Sprite sp;
	sf::View camera;
};

void game()
{
	const std::string title = std::string("upgrayedd-test") + (IsDebug()? " (debug build)" : "");
	sf::RenderWindow App(sf::VideoMode(800, 600, 32), title);

	ImgPool img;
	SpriteDefPool spd(img);
	spd.add("../sprites.yaml");

	GameLoop loop(App, spd);
	loop.run();
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
