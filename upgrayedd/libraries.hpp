#ifdef _DEBUG
#define SFML_DEBUG_POSTFIX "-d"
#else
#define SFML_DEBUG_POSTFIX ""
#endif

#pragma comment(lib, "sfml-system-s" SFML_DEBUG_POSTFIX ".lib")
#pragma comment(lib, "sfml-graphics-s" SFML_DEBUG_POSTFIX ".lib")
#pragma comment(lib, "sfml-window-s" SFML_DEBUG_POSTFIX ".lib")
#pragma comment(lib, "sfml-main" SFML_DEBUG_POSTFIX ".lib")

#undef SFML_DEBUG_POSTFIX