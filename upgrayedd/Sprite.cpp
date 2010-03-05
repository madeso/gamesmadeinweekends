#include "Sprite.hpp"

namespace upgrayedd
{
	Sprite::Sprite(Img img)
		: mImage(img)
		, mSprite(*img)
	{
	}

	Sprite::operator sf::Sprite&()
	{
		return mSprite;
	}

	Sprite::operator const sf::Sprite&() const
	{
		return mSprite;
	}

	sf::Sprite* Sprite::operator->()
	{
		return &mSprite;
	}
	const sf::Sprite* Sprite::operator->() const
	{
		return &mSprite;
	}
}
