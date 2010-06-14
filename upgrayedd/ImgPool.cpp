#include "ImgPool.hpp"
#include "sfml-image.hpp"
#include "debug.hpp"

namespace upgrayedd
{
	class ImgPool::ImageRemover
	{
	public:
		ImageRemover(ImgPool* p, const std::string& n)
			: pool(p)
			, name(n)
		{
		}

		void operator()(sf::Image* img)
		{
			pool->map.erase(name);
			delete img;
		}
	private:
		ImgPool* pool;
		std::string name;
	};

	namespace // local
	{
		Img Load(const std::string& path, const ImgPool::ImageRemover& ir)
		{
			Img img(new sf::Image(), ir);
			LoadImageFromFile(path, *img);
			return img;
		}
	}

	Img ImgPool::load(const std::string& path)
	{
		ImgwMap::iterator res = map.find(path);
		if( res != map.end() )
		{
			if( Img img = res->second.lock() )
			{
				return img;
			}
			else
			{
				if( IsDebug() ) throw "epic fail"; // image should have been removed by the ImageRemover
			}
		}
		Img img = Load(path, ImageRemover(this, path));
		map[path] = img;
		return img;
	}
}

