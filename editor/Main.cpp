
////////////////////////////////////////////////////////////
// Headers
////////////////////////////////////////////////////////////
#include "wxSFMLCanvas.hpp"
#include <SFML/Graphics.hpp>
#include <SFML/OpenGL.hpp>
#include <boost/foreach.hpp>
#include <iostream>
#include <boost/shared_ptr.hpp>
#include <list>
#include <sstream>

#ifdef _DEBUG
#define OPTIONS "-s-d"
#else
#define OPTIONS "-s"
#endif

#pragma comment(lib, "sfml-graphics" OPTIONS ".lib")
#pragma comment(lib, "sfml-system" OPTIONS ".lib")
#pragma comment(lib, "sfml-window" OPTIONS ".lib")

// -------------------
// Tesselation code

// http://www.flipcode.com/articles/article_tesselating.shtml


void CALLBACK  tcbCombine (GLdouble c[3], void *d[4], GLfloat w[4], void **out, void* data);

GLvoid CALLBACK  onError(GLenum err) {
	std::string str = (char *) gluErrorString(err);
}
struct VectorData {
	VectorData(double ax, double ay, double az)
		: x(ax)
		, y(ay)
		, z(az)
	{
	}
	double x;
	double y;
	double z;
};
struct PolygonData {
	PolygonData(const VectorData& a, const VectorData& b, const VectorData& c)
	{
		points.push_back(a);
		points.push_back(b);
		points.push_back(c);
	}
	std::vector<VectorData> points;
};

void CALLBACK  tcbBegin (GLenum prim, void *data);
void CALLBACK  tcbVertex (void *vertex, void *data);
void CALLBACK  tcbEnd (void *data);

bool IsOdd(std::size_t x)
{
	return (x % 2) == 1;
}

class Tesselator {
public:
	Tesselator() {
		mTesselatorObject = gluNewTess();

		gluTessCallback (mTesselatorObject, GLU_TESS_BEGIN_DATA, reinterpret_cast<void (__stdcall *)(void)>(tcbBegin));
		gluTessCallback (mTesselatorObject, GLU_TESS_VERTEX_DATA, reinterpret_cast<void (__stdcall *)(void)>(tcbVertex));
		gluTessCallback (mTesselatorObject, GLU_TESS_END_DATA, reinterpret_cast<void (__stdcall *)(void)>(tcbEnd) );
		gluTessCallback (mTesselatorObject, GLU_TESS_COMBINE_DATA, reinterpret_cast<void (__stdcall *)(void)>(tcbCombine));
		
		//gluTessCallback(mTesselatorObject, GLU_ERROR,			reinterpret_cast<void (__stdcall *)(void)>(&onError) );
	}
	virtual ~Tesselator() {
		gluDeleteTess(mTesselatorObject);
	}

	void setWindingRule(unsigned int pRule) {
		gluTessProperty(mTesselatorObject, GLU_TESS_WINDING_RULE, pRule);
	}
	void setBoundary(bool pBoundary) {
		gluTessProperty(mTesselatorObject, GLU_TESS_BOUNDARY_ONLY, pBoundary);
	}

	void contour_begin() {
		gluTessBeginContour(mTesselatorObject);
	}
	void vertex(double x, double y, double z) {
		double* ptr = newVector(x, y, z);
		gluTessVertex (mTesselatorObject, ptr, ptr);
	}
	void contour_end() {
		gluTessEndContour(mTesselatorObject);
	}

	void polygon_begin() {
		gluTessBeginPolygon(mTesselatorObject, this);
	}
	void polygon_end() {
		gluTessEndPolygon(mTesselatorObject);
	}

	double* newVector(double x, double y, double z) {
		VectorData vec(x,y,z);
		data.push_back( vec );
		return & (*(--data.end())).x;
	}

	// internal
	void onBegin(GLenum prim)
	{
		currentState = prim;
	}
	void onVertex(double* vertex)
	{
		vectors.push_back(VectorData(vertex[0], vertex[1], vertex[2]) );
	}
	void onEnd()
	{
		const std::size_t size = vectors.size();
		std::vector<PolygonData> polygons;

		switch(currentState)
		{
		case GL_TRIANGLES:
			if( (size % 3) != 0 ) throw "wtf";
			for(std::size_t i=0; i<size; i+=3)
			{
				polygons.push_back(PolygonData(vectors[i], vectors[i+1], vectors[i+2]));
			}
			break;
		case GL_TRIANGLE_STRIP:
			for(std::size_t i=0;i<size-2; ++i)
			{
				if( IsOdd(i) ) polygons.push_back(PolygonData(vectors[i], vectors[i+1], vectors[i+2]));
				else polygons.push_back(PolygonData(vectors[i+1], vectors[i], vectors[i+2]));
			}
			break;
		case GL_TRIANGLE_FAN:
			for(std::size_t i=0;i<size-2; ++i)
			{
				polygons.push_back(PolygonData(vectors[0], vectors[i+1], vectors[i+2]));
			}
			break;
		default:
			throw "not supported";
		}

		onPolygons(polygons);
		vectors.clear();
	}

protected:
	virtual void onPolygons(const std::vector<PolygonData>& polygons) = 0;
private:
	// tesselation data
	GLUtesselator* mTesselatorObject;
	std::list<VectorData> data;
	
	// polygon compilation data
	std::vector<VectorData> vectors;
	GLenum currentState;
};

void CALLBACK  tcbBegin (GLenum prim, void *data){
	Tesselator* owner = (Tesselator*) data;
	owner->onBegin(prim);
}

void CALLBACK  tcbVertex (void *vertex, void *data) {
	Tesselator* owner = (Tesselator*) data;
	owner->onVertex((GLdouble *)vertex);
}
void CALLBACK  tcbEnd (void *data) {
	Tesselator* owner = (Tesselator*) data;
	owner->onEnd();
}
void CALLBACK  tcbCombine (GLdouble c[3], void *d[4], GLfloat w[4], void **out, void* data){
	Tesselator* owner = (Tesselator*) data;
	*out = owner->newVector(c[0], c[1], c[2]);
}

void DrawOutline(sf::RenderTarget* target, double thickness, const sf::Color& color, const std::vector<sf::Vector2f>& positions, sf::Vector2f* last)
{
	const std::size_t size = positions.size();
	if( size < 1 ) return;

	sf::Vector2f first = positions[0];
	sf::Vector2f second = first;

	for(std::size_t index=1; index < size; ++index)
	{
		const sf::Vector2f second = positions[index];
		target->Draw(sf::Shape::Line(first.x, first.y, second.x, second.y, thickness, color));
		first = second;
	}

	second = last ? *last : positions[0];
	target->Draw(sf::Shape::Line(first.x, first.y, second.x, second.y, thickness, color));
}

struct TesselatePolygonRaii
{
	Tesselator* me;

	TesselatePolygonRaii(Tesselator* t)
		: me(t)
	{
		me->polygon_begin();
	}

	~TesselatePolygonRaii()
	{
		me->polygon_end();
	}
};

struct TesselateContourRaii
{
	Tesselator* me;

	TesselateContourRaii(Tesselator* t)
		: me(t)
	{
		me->contour_begin();
	}

	~TesselateContourRaii()
	{
		me->contour_end();
	}
};

//--------------------

class Tri
{
public:
	std::vector<sf::Vector2f> points;
	sf::Shape shape;

	void compile()
	{
		std::reverse(points.begin(), points.end());
		shape = sf::Shape();
		BOOST_FOREACH(const sf::Vector2f& p, points)
		{
			shape.AddPoint(p, sf::Color(0, 255, 0), sf::Color(0,0,0));
		}
		//shape.EnableOutline(true);
		//shape.SetOutlineWidth(1);
	}
};

class TriList
{
public:
	std::vector<Tri> tris;

	void compile()
	{
		BOOST_FOREACH(Tri& t, tris)
		{
			t.compile();
		}
	}

	void draw(sf::RenderTarget* target)
	{
		BOOST_FOREACH(const Tri& t, tris)
		{
			target->Draw(t.shape);
		}
	}

	void debug(sf::RenderTarget* target)
	{
		BOOST_FOREACH(const Tri& t, tris)
		{
			DrawOutline(target, 1, sf::Color(255, 0,0), t.points, 0);
		}
	}
};

class MyTesselator : public Tesselator
{
public:
	TriList* tris;
	MyTesselator()
		: tris(0)
	{
	}
protected:
	virtual void onPolygons(const std::vector<PolygonData>& polygons)
	{
		BOOST_FOREACH(const PolygonData& p, polygons)
		{
			Tri t;
			BOOST_FOREACH(const VectorData& data, p.points)
			{
				t.points.push_back(sf::Vector2f(data.x, data.y));
			}
			tris->tris.push_back(t);
		}
	}
};

class MyPolygon
{
public:
	void draw(sf::RenderTarget* target, sf::Vector2f* last)
	{
		if( tris ) tris->draw(target);
		DrawOutline(target, 3, sf::Color(0,0,0), positions, last);
		if( tris ) tris->debug(target);
	}

	bool isValid() const
	{
		return positions.size() > 2;
	}

	void compile()
	{
		if( tris ) tris->tris.resize(0);
		else tris.reset( new TriList() );

		MyTesselator tesselator;
		tesselator.tris = tris.get();

		{
			TesselatePolygonRaii polygon(&tesselator);
			TesselateContourRaii contour(&tesselator);

			BOOST_FOREACH(const sf::Vector2f& pos, positions)
			{
				tesselator.vertex(pos.x, pos.y, 0);
			}
		}
		
		tris->compile();
	}

	std::vector<sf::Vector2f> positions;
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
				current.compile();
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
