#ifndef UPGRAYEDD_IMG_HPP
#define UPGRAYEDD_IMG_HPP

#include <SFML/Graphics/Image.hpp>
#include <boost/shared_ptr.hpp>

namespace upgrayedd
{
	typedef boost::shared_ptr<sf::Image> Img;
}

#endif