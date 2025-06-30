package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import sys.io.File;
import haxe.Json;
import flixel.group.FlxSpriteGroup;

class GalleryState extends MusicBeatState
{
	var itemGroup:FlxTypedGroup<GalleryImage>;
	
	var imagePaths:Array<String>;
	var imageDescriptions:Array<String>;
	var imageTitle:Array<String>;
	var linkOpen:Array<String>;
	var descriptionText:FlxText;
	
	var currentIndex:Int = 0;
	var allowInputs:Bool = true;
	
	var uiGroup:FlxSpriteGroup;
	var hideUI:Bool = false;
	
	var imageSprite:FlxSprite;
	var bg:FlxSprite;
	var titleText:FlxText;
	var bars:FlxSprite;
	
	var imagePath:String = "gallery/";
	
	override public function create():Void {
		imagePaths = [
			"spriteSheets",
			"mShaban",
			"ahmedZezo",
			"ahmedHamedo",
			"ahmedAlafandy",
			"aliOX"
		];
		imageDescriptions = [
			"Drawn by Ali Alafandy, Learning Animation (Sad Moment).",
			"Just a Cool Guy with Green Hair.",
			"Just a Cool Guy with Mix Hair.",
			"Just a Cool Guy with Light Blue Hair.",
			"Just a Cool Guy with Black Hair.",
			"Blue Fox from Smiling Critters."
		];
		imageTitle = [
			"Sprite Sheet",
			"M.Shaban",
			"Ahmed Zezo",
			"Ahmed Hamedo",
			"Ahmed Alafandy",
			"AliOX"
		];
		linkOpen = [
			"https://www.youtube.com/@alialafandy",
			"https://www.youtube.com/@2025_توكلت_علي_لله",
			"https://www.youtube.com/@ahmedzezopro",
			"https://www.roblox.com/users/5515913481/profile",
			"https://www.youtube.com/@ahmedalafandy3060",
			"https://www.youtube.com/@alialafandy"
		];

		itemGroup = new FlxTypedGroup<GalleryImage>();
		uiGroup = new FlxSpriteGroup();
		
		for (id => i in imagePaths) {
			var newItem = new GalleryImage();
			newItem.loadGraphic(Paths.image(imagePath + i));
			newItem.ID = id;
			itemGroup.add(newItem);
		}
		
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
		
		bars = new FlxSprite().loadGraphic(Paths.image("gallery/ui/bars"));
		uiGroup.add(bars);
		
		add(itemGroup);
		
		descriptionText = new FlxText(50, -100, FlxG.width - 100, imageDescriptions[currentIndex]);
		descriptionText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLUE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionText.screenCenter();
		descriptionText.y += 275;
		uiGroup.add(descriptionText);
		
		titleText = new FlxText(50, -100, FlxG.width - 100, imageTitle[currentIndex]);
		titleText.screenCenter();
		titleText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLUE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.y -= 275;
		uiGroup.add(titleText);
		
		add(uiGroup);
		
		persistentUpdate = true;
		changeSelection();

		#if mobile
		addTouchPad("LEFT_RIGHT", "A_B");
		#end
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && allowInputs) {
			changeSelection(controls.UI_LEFT_P ? -1 : 1);
			FlxG.sound.play(Paths.sound("scrollMenu"));
		}
		
		if (controls.BACK && allowInputs) {
			allowInputs = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
			
		if (controls.ACCEPT && allowInputs) {
			CoolUtil.browserLoad(linkOpen[currentIndex]);
		}
	}
	
	private function changeSelection(i:Int = 0) {
		currentIndex = FlxMath.wrap(currentIndex + i, 0, imageTitle.length - 1);
		
		descriptionText.text = imageDescriptions[currentIndex];
		titleText.text = imageTitle[currentIndex];
		
		var change = 0;
		for (item in itemGroup) {
			item.posX = change++ - currentIndex;
			item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
		}
	}
}

class GalleryImage extends FlxSprite {
	public var lerpSpeed:Float = 6;
	public var posX:Float = 0;
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, boundTo(elapsed * lerpSpeed, 0, 1));
	}
}

function boundTo(value:Float, min:Float, max:Float):Float {
	var newValue:Float = value;
	if(newValue < min) newValue = min;
	else if(newValue > max) newValue = max;
	return newValue;
}
