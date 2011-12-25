#ifndef UPGRAYEDD_SFML_IMAGE_HPP
#define UPGRAYEDD_SFML_IMAGE_HPP

#include <SFML/Graphics/Image.hpp>
#include <string>

namespace upgrayedd
{
	void LoadImageFromFile(const std::string& filename, sf::Image& img);
}

#endif
