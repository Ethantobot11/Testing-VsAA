package states;

import flixel.FlxSubState;
import flixel.FlxG;

import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;

class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;
	var warnText:FlxText;
	
	override function create()
	{
		super.create();
		
		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFF000080;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		
		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x330000FF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);
		
		final buttonBack:String = controls.mobileC ? 'B' : 'ESCAPE';
		final buttonAccept:String = controls.mobileC ? 'A' : 'ENTER';
		
		var ramGB:Float = Math.round(getSystemRAM() * 100) / 100;
		
		if (ramGB < 3.49)
		{
			warnText = new FlxText(0, 0, FlxG.width, 
			"Hey, yoo!!\n" +
			"This Mod needs at least 4 GB of RAM to run nicely.\n" +
			"System Detected RAM: " + ramGB + " GB.\n" +
			"Also,\n" +
			"This Mod contains some flashing lights!\n" +
			"Press A/ENTER to continue and disable them now or go to Options Menu.\n" +
			"Press B/ESCAPE to ignore this massage.\n" +
			"You've been warned!",
			32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			warnText.screenCenter(Y);
			add(warnText);
			
			trace('Warning: System has less than 4 GB of RAM. Detected RAM: ' + ramGB + ' GB');
		} else {
			warnText = new FlxText(0, 0, FlxG.width, 
			"Hey, yoo!!\n
			This Mod contains some flashing lights!\n
			Press A/ENTER to continue and disable them now or go to Options Menu.\n
			Press B/ESCAPE to ignore this massage.\n
			You've been warned!",
			32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			warnText.screenCenter(Y);
			add(warnText);
			
			trace('System has sufficient RAM: ' + ramGB + ' GB');
			MusicBeatState.switchState(new TitleState());
		}
		
		#if mobile
		addTouchPad("NONE", "A_B");
		#end
	}
	
	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
	
	function getSystemRAM():Float {
		#if windows
		var process = new Process("wmic", ["OS", "get", "TotalVisibleMemorySize"]);
		var output = process.stdout.readAll().toString();
		process.close();
		
		var lines = output.split("\n");
		for (line in lines) {
		var trimmed = StringTools.trim(line);
		if (~/^\d+$/.match(trimmed)) {
			return Std.parseInt(trimmed) / (1024 * 1024); 
		}
	}
	#elseif linux
	var process = new Process("grep", ["MemTotal", "/proc/meminfo"]);
	var output = process.stdout.readAll().toString();
	process.close();
	
	var parts = output.split(":");
	if (parts.length > 1) {
		var kbRam = Std.parseInt(parts[1].replace("kB", "").trim());
		return kbRam / (1024 * 1024);
	}
	#end
	
	return 0;
	}
}
