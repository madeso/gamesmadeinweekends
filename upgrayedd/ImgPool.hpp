#ifndef UPGRAYEDD_IMG_POOL_HPP
#define UPGRAYEDD_IMG_POOL_HPP

#include "Img.hpp"
#include <string>

#include <map>
#include <boost/weak_ptr.hpp>

namespace upgrayedd
{
	class ImgPool
	{
	public:
		Img load(const std::string& path);

		class ImageRemover;
	private:
		typedef boost::weak_ptr<sf::Image> Imgw;
		typedef std::map<std::string, Imgw> ImgwMap;
		ImgwMap map;
	};
}

#endif
