package;
import flixel.*;
class WarningState extends MusicBeatState
{

	public function new() 
	{
		super();
	}
	override function create() 
	{
		super.create();
		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image("startup"));
		add(bg);
		bg.screenCenter();

		#if android
		addVirtualPad(NONE, A);
		#end
	}
	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		if (controls.ACCEPT){
			FlxG.switchState(new MainMenuState());
		}
	}
}