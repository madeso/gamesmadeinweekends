#ifndef UPGRAYEDD_IMG_POOL_HPP
#define UPGRAYEDD_IMG_POOL_HPP

#include <SFML/Graphics/Image.hpp>
#include <boost/shared_ptr.hpp>
#include <string>

namespace upgrayedd
{
	typedef boost::shared_ptr<sf::Image> Img;

	// todo: replace with an actual pool..
	Img Load(const std::string& path);
}

#endif
