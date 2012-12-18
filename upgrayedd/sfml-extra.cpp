#include "sfml-math.hpp"
#include <cmath>

namespace upgrayedd
{
	const float Square(float f)
	{
		return f*f;
	}

	const float GetLengthSquared(const sf::Vector2f& v)
	{
		return Square(v.x) + Square(v.y);
	}

	const float GetLength(const sf::Vector2f& v)
	{
		return std::sqrt(GetLengthSquared(v));
	}

	sf::Vector2f operator*(const sf::Vector2f& v, const float s)
	{
		return sf::Vector2f(v.x*s, v.y*s);
	}
	sf::Vector2f operator/(const sf::Vector2f& v, const float s)
	{
		const float f = AsValidFloat(1/s);
		return v * f;
	}
	sf::Vector2f operator*(const float s, const sf::Vector2f& v)
	{
		return v*s;
	}

	sf::Vector2f GetNormalized(const sf::Vector2f& v)
	{
		const float length = GetLength(v);
		if( length == 0) return sf::Vector2f(0,0);
		return v / length;
	}

	float AsValidFloat(float f)
	{
		// todo: more checks?
		if( 2*f == f && f!=0) throw "invalid float";
		return f;
	}
}