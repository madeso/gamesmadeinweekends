#include "message.hpp"

#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
		#include "windows.h"
	#undef WIN32_LEAN_AND_MEAN
#else
	#include <iostream>
#endif

namespace upgrayedd
{
	void Throw(const std::string& message)
	{
#ifdef _DEBUG
#if _WIN32
		OutputDebugStringA("Throwing: ");
		OutputDebugStringA(message.c_str());
		OutputDebugStringA("\n");
#else
		std::cerr << "throwing : " << message << std::endl;
#endif
#endif
		throw message;
	}

	void Message(const std::string& title, const std::string& contents)
	{
		#if _WIN32
			MessageBoxA(0, contents.c_str(), title.c_str(), MB_OK | MB_ICONERROR);
#else
		std::cerr << title << ": " << contents << std::endl;
#endif
	}
}

