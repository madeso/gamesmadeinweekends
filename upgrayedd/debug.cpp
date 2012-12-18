#include "debug.hpp"

namespace upgrayedd
{
	bool IsDebug()
	{
#ifdef _DEBUG
		return true;
#else
		return false;
#endif
	}
}
