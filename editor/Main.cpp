
////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#include "wxSFMLCanvas.hpp"
#include <SFML/Graphics.hpp>
#include <boost/foreach.hpp>
#include <iostream>

#ifdef _DEBUG
#define OPTIONS "-s-d"
#else
#define OPTIONS "-s"
#endif

#pragma comment(lib, "sfml-graphics" OPTIONS ".lib")
#pragma comment(lib, "sfml-system" OPTIONS ".lib")
#pragma comment(lib, "sfml-window" OPTIONS ".lib")

////////////////////////////////////////////////////////////
/// Custom SFML canvas
////////////////////////////////////////////////////////////

class MyCanvas : public wxSFMLCanvas
{
public :

	////////////////////////////////////////////////////////////
	/// Construct the canvas
	///
	////////////////////////////////////////////////////////////
	MyCanvas(wxWindow* parent, wxWindowID id, const wxPoint& position, const wxSize& size, long style = 0)
		: wxSFMLCanvas(parent, id, position, size, style)
		, firstPlaced(false)
	{
		Connect(wxEVT_MOTION, wxMouseEventHandler(MyCanvas::OnMouseMove));

		view = GetDefaultView();
	}

private :
	virtual void OnUpdate()
	{
		static bool previous = false;
		const bool down = GetInput().IsMouseButtonDown(sf::Mouse::Left);

		const bool move = GetInput().IsMouseButtonDown(sf::Mouse::Middle);

		if( move )
		{
			view.Move(-diff);
		}

		if( down && !previous )
		{
			firstPlaced = !firstPlaced;

			if( firstPlaced == false ) 
			{
				lines.push_back(sf::Shape::Line(first.x, first.y, mp.x, mp.y, 1, sf::Color(0,0,0)));
			}

			first = mp;
		}
		previous = down;

		diff = sf::Vector2f(0,0);

		SetView(view);

		// Clear the view
		Clear(sf::Color(255, 255, 255));
		if( firstPlaced )
		{
			sf::Shape temp =  sf::Shape::Line(first.x, first.y, mp.x, mp.y, 1, sf::Color(0,0,0));
			Draw(temp);
		}

		BOOST_FOREACH(sf::Shape& shape, lines)
		{
			Draw(shape);
		}
	}

	void OnMouseMove(wxMouseEvent& event)
	{
		const sf::Vector2f pos = sf::Vector2f(event.GetX(), event.GetY());
		static sf::Vector2f old = pos;
		mp = ConvertCoords(pos.x, pos.y);
		diff = mp - ConvertCoords(old.x, old.y);
		old = pos;
	}

	sf::Vector2f mp;
	sf::Vector2f diff;
	sf::Vector2f first;
	sf::View view;
	bool firstPlaced;
	std::vector<sf::Shape> lines;
};


////////////////////////////////////////////////////////////
/// Our main window
////////////////////////////////////////////////////////////
class MyFrame : public wxFrame
{
public :

	////////////////////////////////////////////////////////////
	/// Default constructor : setup the window
	///
	////////////////////////////////////////////////////////////
	MyFrame() :
	   wxFrame(NULL, wxID_ANY, wxT("Eddie 2d"), wxDefaultPosition, wxSize(800, 600))
	   {
		   // Let's create a SFML view
		   new MyCanvas(this, wxID_ANY, wxPoint(20, 20), wxSize(400, 200));
	   }
};


////////////////////////////////////////////////////////////
/// Our application class
////////////////////////////////////////////////////////////
class MyApplication : public wxApp
{
private :

	////////////////////////////////////////////////////////////
	/// Initialize the application
	///
	////////////////////////////////////////////////////////////
	virtual bool OnInit()
	{
		// Create the main window
		MyFrame* mainFrame = new MyFrame;
		mainFrame->Show();

		return true;
	}
};

IMPLEMENT_APP(MyApplication);
