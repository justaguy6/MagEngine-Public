package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.input.gamepad.FlxGamepad;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CreditsMenu extends MusicBeatState
{
	var credits:Array<CreditsMetadata> = [];

	static var curSelected:Int = 0;

	private var grpCredits:FlxTypedGroup<Alphabet>;

	var descText:FlxText;
	var bg:FlxSprite;
	var colorTween:FlxTween;

	override function create()
	{
		MemoryManager.freeTrashedAssets();
		MemoryManager.freeAllAssets();

		if (FlxG.save.data.mousescroll)
		{
			FlxG.mouse.visible = true;
		}

		var initCreditlist = CoolUtil.coolTextFile(Paths.txt('data/creditsList'));

		if (FileSystem.exists(Paths.modTxt('data/creditsList')) && FileSystem.exists(Paths.txt('data/creditsList')))
		{
			initCreditlist = File.getContent(Paths.modTxt('data/creditsList')).trim().split('\n');

			for (i in 0...initCreditlist.length)
			{
				initCreditlist[i] = initCreditlist[i].trim();
			}
		}
		else
		{
			initCreditlist = CoolUtil.coolTextFile(Paths.txt('data/creditsList'));
		}

		for (i in 0...initCreditlist.length)
		{
			var data:Array<String> = initCreditlist[i].split(':');
			credits.push(new CreditsMetadata(data[0], data[1]));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = FlxColor.PINK;
		add(bg);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("funkin.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.text = 'what';
		descText.borderSize = 2.4;
		add(descText);

		grpCredits = new FlxTypedGroup<Alphabet>();
		add(grpCredits);

		for (i in 0...credits.length)
		{
			var creditText:Alphabet = new Alphabet(0, (70 * i) + 30, credits[i].modderName, true, false);
			creditText.isMenuItem = true;
			creditText.targetY = i;
			grpCredits.add(creditText);

			// creditText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// creditText.screenCenter(X);
		}

		changeSelection();
		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);

		var descText:FlxText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("funkin.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (upP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-shiftMult);
		}
		if (downP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(shiftMult);
		}

		if (FlxG.mouse.wheel != 0 && FlxG.save.data.mousescroll)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			changeSelection(-FlxG.mouse.wheel);
		}

		if (controls.BACK)
			MusicBeatState.switchState(new MainMenuState());
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = credits.length - 1;
		if (curSelected >= credits.length)
			curSelected = 0;

		descText.text = credits[curSelected].desc;

		// selector.y = (70 * curSelected) + 30;
		var bullShit:Int = 0;

		for (item in grpCredits.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class CreditsMetadata
{
	public var modderName:String = "";
	public var desc:String = "";

	public function new(name:String, desc:String)
	{
		this.modderName = name;
		this.desc = desc;
	}
}
