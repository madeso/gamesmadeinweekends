#ifndef UPGRAYEDD_STRINGBUILDER_HPP
#define UPGRAYEDD_STRINGBUILDER_HPP

#include <sstream>
#include <boost/noncopyable.hpp>

namespace upgrayedd
{
	class StringBuilder : boost::noncopyable
	{
	public:
		StringBuilder()
		{
		}

		template<typename T>
		StringBuilder& operator<<(const T& t)
		{
			ss << t;
			return *this;
		}

		std::string str() const
		{
			return ss.str();
		}

		operator std::string() const
		{
			return str();
		}
	private:
		std::ostringstream ss;
	};
}

#endif