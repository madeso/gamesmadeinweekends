#include "ExceptionInformation.hpp"

namespace upgrayedd
{
	ExceptionInformation::ExceptionInformation()
	{
		try
		{
			throw;
		}
		catch(const std::string& str)
		{
			mMessage = str;
		}
		catch(char* str)
		{
			mMessage = str;
		}
		catch(...)
		{
			mMessage = "unknown";
		}
	}

	const std::string& ExceptionInformation::message() const
	{
		return mMessage;
	}
}

