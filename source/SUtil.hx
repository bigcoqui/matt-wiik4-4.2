package;

#if android
import android.Hardware;
import android.Permissions;
import android.os.Build.VERSION;
import android.os.Environment;
#end
import flash.system.System;
import flixel.FlxG;
import flixel.util.FlxStringUtil;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */
class SUtil
{
	/**
	 * A simple function that checks for storage permissions and game files/folders
	 */
	public static function check()
	{
		#if android
		if (!Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE)
			&& !Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE))
		{
			if (VERSION.SDK_INT > 23 || VERSION.SDK_INT == 23)
			{
				Permissions.requestPermissions([PermissionsList.WRITE_EXTERNAL_STORAGE, PermissionsList.READ_EXTERNAL_STORAGE]);

				/**
				 * Basically for now i can't force the app to stop while its requesting a android permission, so this makes the app to stop while its requesting the specific permission
				 */
				Application.current.window.alert('If you accepted the permissions you are all good!' + "\nIf you didn't then expect a crash"
					+ 'Press Ok to see what happens',
					'Permissions?');
			}
			else
			{
				Application.current.window.alert('Please grant the game storage permissions in app settings' + '\nPress Ok io close the app', 'Permissions?');
				System.exit(1);
			}
		}

		if (Permissions.getGrantedPermissions().contains(PermissionsList.WRITE_EXTERNAL_STORAGE)
			&& Permissions.getGrantedPermissions().contains(PermissionsList.READ_EXTERNAL_STORAGE))
		{
			if (!FileSystem.exists(SUtil.getPath()))
				FileSystem.createDirectory(SUtil.getPath());

			if (!FileSystem.exists(SUtil.getPath() + "assets"))
				FileSystem.createDirectory(SUtil.getPath() + "assets");
		}
		#end
	}

	/**
	 * This returns the external storage path that the game will use
	 */
	public static function getPath():String
	{
		#if android
		return Environment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
		#else
		return '';
		#end
	}

	/**
	 * Uncaught error handler, original made by: sqirra-rng
	 */
	public static function uncaughtErrorHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + ' (line ' + line + ')\n';
					default:
						Sys.println(stackItem);
				}
			}

			errMsg += u.error;

			Sys.println(errMsg);
			Application.current.window.alert(errMsg, 'Error!');

			try
			{
				if (!FileSystem.exists(SUtil.getPath() + 'crash'))
					FileSystem.createDirectory(SUtil.getPath() + 'crash');

				File.saveContent(SUtil.getPath() + 'crash/' + Application.current.meta.get('file') + '_'
					+ FlxStringUtil.formatTime(Date.now().getTime(), true) + '.log',
					errMsg + "\n");
			}
			#if android
			catch (e:Dynamic)
				Hardware.toast("Error!\nClouldn't save the crash dump because:\n" + e, 2);
			#end

			System.exit(1);
		});
	}

	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot to add something in your code')
	{
		try
		{
			if (!FileSystem.exists(SUtil.getPath() + 'saves'))
				FileSystem.createDirectory(SUtil.getPath() + 'saves');

			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
			Hardware.toast("File Saved Successfully!", 2);
		}
		#if android
		catch (e:Dynamic)
			Hardware.toast("Error!\nClouldn't save the file because:\n" + e, 2);
		#end
	}

	public static function copyContent(copyPath:String, savePath:String)
	{
		try
		{
			if (!FileSystem.exists(savePath) && OpenFlAssets.exists(copyPath))
				File.saveBytes(savePath, OpenFlAssets.getBytes(copyPath));
		}
		#if android
		catch (e:Dynamic)
			Hardware.toast("Error!\nClouldn't copy the file because:\n" + e, 2);
		#end
	}

	public static function getDisplayRefreshRate():Int
		return Application.current.window.displayMode.refreshRate;
}