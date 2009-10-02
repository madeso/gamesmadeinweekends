
////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#include "wxSFMLCanvas.hpp"
#include <SFML/Graphics.hpp>
#include <SFML/OpenGL.hpp>
#include <boost/foreach.hpp>
#include <iostream>
#include <boost/shared_ptr.hpp>

#include <CGAL/basic.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Partition_traits_2.h>
#include <CGAL/partition_2.h>

#ifdef _DEBUG
#define OPTIONS "-s-d"
#else
#define OPTIONS "-s"
#endif

#pragma comment(lib, "sfml-graphics" OPTIONS ".lib")
#pragma comment(lib, "sfml-system" OPTIONS ".lib")
#pragma comment(lib, "sfml-window" OPTIONS ".lib")

class Tri
{
public:
	std::vector<sf::Vector2f> points;
};

class TriList
{
public:
	std::vector<Tri> tris;
};

class MyPolygon
{
public:
	void draw(sf::RenderTarget* target, sf::Vector2f* last)
	{
		const std::size_t size = positions.size();
		if( size < 1 ) return;

		sf::Vector2f first = positions[0];
		sf::Vector2f second = first;

		for(std::size_t index=1; index < size; ++index)
		{
			const sf::Vector2f second = positions[index];
			target->Draw(sf::Shape::Line(first.x, first.y, second.x, second.y, 1, sf::Color(0,0,0)));
			first = second;
		}

		second = last ? *last : positions[0];
		target->Draw(sf::Shape::Line(first.x, first.y, second.x, second.y, 1, sf::Color(0,0,0)));
	}

	bool isValid() const
	{
		return positions.size() > 2;
	}

	void triangulate()
	{
		typedef CGAL::Exact_predicates_inexact_constructions_kernel K;
		typedef CGAL::Partition_traits_2<K>                         Traits;
		typedef Traits::Point_2                                     Point_2;
		typedef Traits::Polygon_2                                   Polygon_2;
		typedef std::list<Polygon_2>                                Polygon_list;
		typedef CGAL::Creator_uniform_2<int, Point_2>               Creator;

		Polygon_2    polygon;
		Polygon_list partition_polys;

		BOOST_FOREACH(const sf::Vector2f& pos, positions)
		{
			polygon.push_back(Point_2(pos.x, pos.y));
		}

		CGAL::y_monotone_partition_2(polygon.vertices_begin(),
			polygon.vertices_end(),
			std::back_inserter(partition_polys));

		if( tris ) tris->tris.resize(0);
		else tris.reset( new TriList() );

		BOOST_FOREACH(const Polygon_2& poly, partition_polys)
		{
			Tri tri;
			int i = 0;
			for(Polygon_2::Vertex_iterator p = poly.vertices_begin(); p != poly.vertices_end(); ++p)
			{
				tri.points.push_back( sf::Vector2f(p->x(), p->y()) );
			}
			/*for(int i=0; i<3; ++i)
			{
				tri.points[i] = sf::Vector2f(poly[i].x(), poly[i].y());
			}*/
			tris->tris.push_back(tri);
		}
	}

	std::vector<sf::Vector2f> positions;
	std::vector<sf::Shape> shapes;
	boost::shared_ptr<TriList> tris;
};

class MyCanvas : public wxSFMLCanvas
{
public :
	MyCanvas(wxWindow* parent, wxWindowID id, const wxPoint& position, const wxSize& size, long style = 0)
		: wxSFMLCanvas(parent, id, position, size, style)
		, zoom(0)
	{
		Connect(wxEVT_MOTION, wxMouseEventHandler(MyCanvas::OnMouseMove));
		Connect(wxEVT_MOUSEWHEEL, wxMouseEventHandler(MyCanvas::OnMouseMove));

		view = GetDefaultView();
	}

private :
	virtual void OnUpdate()
	{
		static bool previous = false;
		const sf::Input& Input = GetInput();
		const bool down = Input.IsMouseButtonDown(sf::Mouse::Left);
		const bool move = Input.IsMouseButtonDown(sf::Mouse::Middle);

		static bool previousAbort = false;
		const bool abortDown = Input.IsKeyDown(sf::Key::Escape);
		const bool abort = abortDown && !previousAbort;
		previousAbort = abortDown;
		
		static bool previousAccept = false;
		const bool acceptDown = Input.IsKeyDown(sf::Key::Return);
		const bool accept = acceptDown && !previousAccept;
		previousAccept = acceptDown;

		if( move )
		{
			view.Move(-diff);
		}

		if( zoom != 0 ) {
			const sf::Vector2f oc = view.GetCenter();
			const sf::Vector2f omp = ConvertCoords(pos.x, pos.y);
			view.SetCenter(mp);
			view.Zoom(1.0f + 0.2 * zoom );
			const sf::Vector2f nc = view.GetCenter();
			const sf::Vector2f nmp = ConvertCoords(pos.x, pos.y);
			view.SetCenter( nmp - (omp-oc) );

			/*view.SetCenter(

			viewPortCenter = new PointF(
				viewPortCenter.X + ( (e.X - hafWidth) /(2* Zoom)),
				viewPortCenter.Y + ((e.Y - (panel1.Height/2)) / (2*Zoom)));*/

		}

		if( down && !previous )
		{
			current.positions.push_back(mp);
			
		}
		previous = down;

		if( abort ) current.positions.resize(0);
		if( accept )
		{
			if( current.isValid() )
			{
				polygons.push_back(current);
			}
			current = MyPolygon();
		}

		diff = sf::Vector2f(0,0);
		zoom = 0;

		SetView(view);

		// Clear the view
		Clear(sf::Color(255, 255, 255));

		BOOST_FOREACH(MyPolygon& shape, polygons)
		{
			shape.draw(this, 0);
		}

		current.draw(this, &mp);
	}

	void OnMouseMove(wxMouseEvent& event)
	{
		pos = sf::Vector2f(event.GetX(), event.GetY());
		static sf::Vector2f old = pos;
		mp = ConvertCoords(pos.x, pos.y);
		diff = mp - ConvertCoords(old.x, old.y);
		old = pos;
		if( event.m_wheelRotation != 0 )
		{
			zoom -= event.m_wheelRotation / static_cast<float>(event.m_wheelDelta);
		}
	}

	sf::Vector2f pos;

	sf::Vector2f mp;
	sf::Vector2f diff;
	sf::View view;
	float zoom;

	MyPolygon current;
	std::vector<MyPolygon> polygons;
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
