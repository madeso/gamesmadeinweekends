#ifndef UPGRAYEDD_EXCEPTION_INFORMATION_HPP
#define UPGRAYEDD_EXCEPTION_INFORMATION_HPP

#include <string>

namespace upgrayedd
{
	class ExceptionInformation
	{
	public:
		ExceptionInformation();

		const std::string& message() const;
	private:
		std::string mMessage;
	};
}

#endif
