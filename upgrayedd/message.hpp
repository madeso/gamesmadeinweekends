#ifndef UPGRAYEDD_MESSAGE_HPP
#define UPGRAYEDD_MESSAGE_HPP

#include <string>

namespace upgrayedd
{
	void Throw(const std::string& message);
	void Message(const std::string& title, const std::string& contents);
}

#endif