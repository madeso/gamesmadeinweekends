#ifndef UPGRAYEDD_LOOP_HPP
#define UPGRAYEDD_LOOP_HPP

namespace upgrayedd
{
	class Loop
	{
	public:
		Loop();
		virtual void onUpdate(float delta) = 0;
		virtual void onRender(float delta) = 0;

		void abort();
		bool isRunning() const;

		void run();
	private:
		bool mIsRunning;
	};
}

#endif