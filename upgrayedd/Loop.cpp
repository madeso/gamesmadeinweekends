#include "Loop.hpp"
#include <SFML/System/Clock.hpp>

namespace upgrayedd
{
	namespace
	{
		class Timer
		{
		public:
			Timer()
			{
			}

			void begin()
			{
				time = 0;
				clock.Reset();
			}

			float end()
			{
				return time + clock.GetElapsedTime();
			}

			void pause()
			{
				time += clock.GetElapsedTime();
				clock.Reset();
			}
			void resume()
			{
				clock.Reset();
			}

			sf::Clock clock;
			float time;
		};

		Timer*& gTimer()
		{
			static Timer* timer = 0;
			return timer;
		}

		class TimerSwitcherRaii
		{
		public:
			TimerSwitcherRaii(Timer* timer)
				: old(gTimer())
			{
				gTimer() = timer;
				if( old ) old->pause();
			}

			~TimerSwitcherRaii()
			{
				gTimer() = old;
				if( old ) old->resume();
			}
		private:
			Timer* old;
		};
	}

	void Loop::abort()
	{
		mIsRunning = false;
	}

	bool Loop::isRunning() const
	{
		return mIsRunning;
	}

	Loop::Loop()
		: mIsRunning(false)
	{
	}

	void Loop::run()
	{
		Timer timer;
		TimerSwitcherRaii timerswitcher(&timer);

		mIsRunning = true;
		float delta = 0;
		while(isRunning())
		{
			timer.begin();
			onUpdate(delta);
			onRender(delta);
			delta = timer.end();
		}
	}
}