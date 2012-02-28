#ifndef UPGRAYEDD_INPUT_HPP
#define UPGRAYEDD_INPUT_HPP

#include <sfml/Window.hpp>

namespace upgrayedd
{
	float KeyFloat(sf::Window& App, sf::Key::Code key);
	float KeyFloat(sf::Window& App, sf::Key::Code pos, sf::Key::Code neg);
}

#endif