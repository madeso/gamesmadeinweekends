#include "ImgPool.hpp"
#include "sfml-image.hpp"

namespace upgrayedd
{
	Img Load(const std::string& path)
	{
		Img img(new sf::Image());
		LoadImageFromFile(path, *img);
		return img;
	}
}
