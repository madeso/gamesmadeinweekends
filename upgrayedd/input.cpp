#include "input.hpp"

namespace upgrayedd
{
	float KeyFloat(sf::Window& App, sf::Key::Code key)
	{
		return App.GetInput().IsKeyDown(key) ? 1.0f : 0.0f;
	}

	float KeyFloat(sf::Window& App, sf::Key::Code pos, sf::Key::Code neg)
	{
		return KeyFloat(App, pos) - KeyFloat(App, neg);
	}
}
