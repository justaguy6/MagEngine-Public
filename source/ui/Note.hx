package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if MODS
import polymod.format.ParseRules.TargetSignatureElement;
#end
import haxe.Json;
#if SCRIPTS
import scripting.HScriptHandler.HScriptType;
import scripting.HScriptHandler;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var noteType:Int = 0;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var isDangerousNote:Bool = false;

	public var hscriptArray:Array<HScriptHandler> = [];

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public var customNote:String = "";

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?pixelNote:Bool = false, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:Int = 0,
			?customNote:String = "")
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += (FlxG.save.data.middlescroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (isSustainNote && prevNote.noteType == 1)
			noteType == 1;
		else if (isSustainNote && prevNote.noteType == 2)
			noteType == 2;

		this.noteData = noteData;

		this.noteType = noteType;

		this.customNote = customNote;

		this.isDangerousNote = (this.noteType == 1 || this.noteType == 2);

		if (pixelNote)
		{
			loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

			animation.add('greenScroll', [6]);
			animation.add('redScroll', [7]);
			animation.add('blueScroll', [5]);
			animation.add('purpleScroll', [4]);

			if (isSustainNote)
			{
				loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

				animation.add('purpleholdend', [4]);
				animation.add('greenholdend', [6]);
				animation.add('redholdend', [7]);
				animation.add('blueholdend', [5]);

				animation.add('purplehold', [0]);
				animation.add('greenhold', [2]);
				animation.add('redhold', [3]);
				animation.add('bluehold', [1]);
			}

			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		}
		else
		{
			antialiasing = true;
			switch (noteType)
			{
				case 1:
					{
						frames = Paths.getSparrowAtlas('HURT_NOTE_assets');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						setGraphicSize(Std.int(width * 0.7));
					}
				case 2:
					{
						frames = Paths.getSparrowAtlas('KILL_NOTE_assets');

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						setGraphicSize(Std.int(width * 0.7));
					}
				case 3:
					{
						frames = Paths.getSparrowAtlas('UGH_NOTE_assets');

						animation.addByPrefix('greenScroll', 'greenugh');
						animation.addByPrefix('redScroll', 'redugh');
						animation.addByPrefix('blueScroll', 'blueugh');
						animation.addByPrefix('purpleScroll', 'purpleugh');

						setGraphicSize(Std.int(width * 0.7));
					}
				default:
					{
						if (FileSystem.exists(SUtil.getStorageDirectory() + Paths.skinFolder('notes/NOTE_assets.png')))
						{
							frames = Paths.getSparrowAtlas('notes/NOTE_assets');
						}
						else
						{
							frames = Paths.getSparrowAtlas('NOTE_assets');
						}
						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');

						setGraphicSize(Std.int(width * 0.7));
					}
			}
			#if SCRIPTS
			if (customNote != null && customNote != "" && Math.isNaN(Std.parseFloat(customNote)))
			{
				var expr = File.getContent(SUtil.getStorageDirectory() + Paths.note(customNote + ".hx"));
				var ext = ".hx";
				if (!FileSystem.exists(SUtil.getStorageDirectory() + Paths.note(customNote + ".hx")) && FileSystem.exists(Paths.note(customNote + ".hscript")))
				{
					expr = File.getContent(SUtil.getStorageDirectory() + Paths.note(customNote + ".hscript"));
					ext = ".hscript";
				}
				if (FileSystem.exists(SUtil.getStorageDirectory() + Paths.note(customNote + ".hscript")) || FileSystem.exists(Paths.note(customNote + ".hx")))
				{
					var hscriptInst = new HScriptHandler(expr, HScriptType.SCRIPT_NOTETYPE, customNote + ext);

					hscriptInst.getInterp().variables.set("note", this);
					hscriptInst.interpExecute();

					hscriptArray.push(hscriptInst);

					setGraphicSize(Std.int(width * 0.7));
				}
			}
			#end
		}
		callOnHScript("create");

		updateHitbox();

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;
			if (FlxG.save.data.downscroll)
				flipY = true;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.isPixelStage)
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
		callOnHScript("createPost");
	}

	override function update(elapsed:Float)
	{
		callOnHScript("update");

		super.update(elapsed);

		if (isSustainNote && prevNote.noteType == 1)
		{
			this.kill();
		}

		if (isSustainNote && prevNote.noteType == 2)
		{
			this.kill();
		}

		if (isSustainNote && prevNote.noteType == 3)
		{
			this.kill();
		}

		if (mustPress)
		{
			if (noteType != 1 && noteType != 2)
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.6)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.4))
					canBeHit = true;
				else
					canBeHit = false;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}

		callOnHScript("updatePost");
	}

	public function callOnHScript(functionToCall:String, ?params:Array<Any>):Dynamic
	{
		#if (MODS && SCRIPTS)
		for (hscript in hscriptArray)
		{
			var interp = hscript.getInterp();
			if (interp == null)
			{
				return null;
			}
			if (interp.variables.exists(functionToCall))
			{
				var functionH = interp.variables.get(functionToCall);
				if (params == null)
				{
					var result = null;
					result = functionH();
					return result;
				}
				else
				{
					var result = null;
					result = Reflect.callMethod(null, functionH, params);
					return result;
				}
			}
		}
		return null;
		#else
		return null;
		#end
	}
}
