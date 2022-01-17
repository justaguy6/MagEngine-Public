package;

import flixel.FlxG;
import flixel.FlxState;

class StartState extends FlxState
{
	override public function create()
	{
		PlayerSettings.init();
		MagDefaults.init();

		#if (CACHE && !debug)
		if (FlxG.save.data.cache)
			FlxG.switchState(new CachingState());
		else
			FlxG.switchState(new TitleState());
		#else
		FlxG.switchState(new TitleState());
		#end

		super.create();
	}
}
