#ifndef UPGRAYEDD_SPRITE_HPP
#define UPGRAYEDD_SPRITE_HPP

#include <SFML/Graphics/Sprite.hpp>
#include "Img.hpp"

namespace upgrayedd
{
	class Sprite
	{
	public:
		explicit Sprite(Img img);

		operator sf::Sprite&();
		operator const sf::Sprite&() const;

		sf::Sprite* operator->();
		const sf::Sprite* operator->() const;
	private:
		Img mImage;
		sf::Sprite mSprite;
	};
}

#endif