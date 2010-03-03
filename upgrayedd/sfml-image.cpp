#include "sfml-image.hpp"
#include <SOIL.h>
#include "stringbuilder.hpp"

namespace upgrayedd
{
	// copied from sfml/src/SFML/Graphics/ImageLoader.cpp, modified to throw exception instead of printing to cerr, and loading to sf::Image instead of a color vector
	void LoadImageFromFile(const std::string& filename, sf::Image& img)
	{
		int width, height, channels;
		unsigned char* ptr = SOIL_load_image(filename.c_str(), &width, &height, &channels, SOIL_LOAD_RGBA);

		if (ptr)
		{
			bool result = img.LoadFromPixels(width, height, ptr);
			SOIL_free_image_data(ptr);

			if( result == false ) throw (StringBuilder() << "Failed to load pixels from loaded \"" << filename << "\"").str();
		}
		else
		{
			throw (StringBuilder() << "Failed to load image \"" << filename << "\", reason : " << SOIL_last_result()).str();
		}
	}
}
