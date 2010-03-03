#include <SFML/System/Vector2.hpp>

namespace upgrayedd
{
	const float Square(float f);
	const float GetLengthSquared(const sf::Vector2f& v);
	const float GetLength(const sf::Vector2f& v);
	sf::Vector2f operator*(const sf::Vector2f& v, const float s);
	sf::Vector2f operator/(const sf::Vector2f& v, const float s);
	sf::Vector2f operator*(const float s, const sf::Vector2f& v);
	sf::Vector2f GetNormalized(const sf::Vector2f& v);

	// throw char* if float is invalid, returns float
	float AsValidFloat(float f);
}
