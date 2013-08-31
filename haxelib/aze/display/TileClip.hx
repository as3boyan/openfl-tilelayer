package aze.display;

import aze.display.TileLayer;
import aze.display.TileSprite;
import flash.geom.Rectangle;

#if flash
import starling.core.Starling;
import starling.display.MovieClip;
import starling.display.BlendMode;
#end

/**
 * Animated tile for TileLayer
 * @author Philippe / http://philippe.elsass.me
 */
class TileClip extends TileSprite
{
	public var onComplete:TileClip->Void;

	public var frames:Array<Int>;
	public var fps:Int;
	public var loop:Bool;
	var time:Int;
	var prevFrame:Int;
	
	#if flash
	var mc:MovieClip;
	#end

	public function new(layer:TileLayer, tile:String, fps = 18)
	{
		super(layer, tile);
		this.fps = fps;
		animated = loop = true;
		
		#if flash
		if (TileLayer.starling_init)
		{
			//mc = new MovieClip(layer.tilesheet.texture_atlas.getTextures(tile), fps);
			mc = new MovieClip(StarlingAssets.texture_atlas.getTextures(tile), fps);
			mc.alignPivot();
			size = new Rectangle(0, 0, mc.width, mc.height);
			
			if (layer != null)
			{
				if (layer.useAdditive) mc.blendMode = BlendMode.ADD;
			}
		}
		#end
	}
	
	#if flash
	
	override public function getView2():starling.display.DisplayObject { return mc; }
	
	override private function set_x(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if(_x != value) mc.x = value;
		}
		return _x = value;
	}
	
	override private function set_y(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if(_y != value) mc.y = value;
		}
		return _y = value;
	}
	
	override private function set_rotation(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_rotation != value) mc.rotation = value;
		}
		
		dirty = true;
		return _rotation = value;
	}
	
	override private function set_scaleY(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_scaleY != value) mc.scaleY = value;
		}
		return _scaleY = value;
	}
	
	override private function set_scale(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_scaleX != value || _scaleY != value) mc.scaleX = mc.scaleY = value;
		}
		
		_scaleX = value;
		_scaleY = value;
		return value;
	}
	
	override private function set_scaleX(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_scaleX != value) mc.scaleX = value;
		}
		return _scaleX = value;
	}
	
	override private function set_visible(value:Bool):Bool 
	{
		if (TileLayer.starling_init)
		{
			if (_visible != value) mc.visible = value;
		}
		return _visible = value;
	}
	
	override private function set_color(value:Int):Int 
	{
		#if flash
		if (TileLayer.starling_init)
		{
			mc.color = value;
		}
		#end
		
		r = (value >> 16) / 255.0;
		g = ((value >> 8) & 0xff) / 255.0;
		b = (value & 0xff) / 255.0;
		return value;
	}
	
	#end
	
	override function init(layer:TileLayer):Void
	{
		#if flash
		if (!TileLayer.starling_init)
		{
			this.layer = layer;
			frames = layer.tilesheet.getAnim(tile);
			indice = frames[0];
			size = layer.tilesheet.getSize(indice);
			time = 0;
			prevFrame = -1;
		}
		else
		{
			if (layer != null)
			{
				if (layer.useAdditive) mc.blendMode = BlendMode.ADD;
			}
		}
		#else
			this.layer = layer;
			frames = layer.tilesheet.getAnim(tile);
			indice = frames[0];
			size = layer.tilesheet.getSize(indice);
			time = 0;
			prevFrame = -1;
		#end
	}

	override function step(elapsed:Int)
	{
		if (!TileLayer.starling_init)
		{
			time += elapsed;
			var newFrame = currentFrame;
			if (newFrame == prevFrame) return;
			var looping = newFrame < prevFrame;
			prevFrame = newFrame;
			if (looping)
			{
				if (!loop) 
				{
					animated = false;
					currentFrame = totalFrames - 1;
				}
				else indice = frames[newFrame];
				if (onComplete != null) onComplete(this);
			}
			else indice = frames[newFrame];
		}
	}
	
	public function play() 
	{ 
		if (!animated) 
		{
			animated = true;
			if (currentFrame == totalFrames - 1)
			{
				currentFrame = 0;
				prevFrame = -1;
			}
		}
		
		#if flash
		if (mc != null)
		{
			mc.play();
		}
		#end
	}
	public function stop() 
	{ 
		animated = false; 
		#if flash
		if (mc != null)
		{
			mc.stop();
		}
		#end
	}

	public var currentFrame(get_currentFrame, set_currentFrame):Int;

	function get_currentFrame():Int 
	{
		var frame:Int = Math.floor((time / 1000) * fps);
		return frame % frames.length;
	}
	function set_currentFrame(value:Int):Int 
	{
		if (value >= totalFrames) value = totalFrames - 1;
		time = Math.floor(1000 * value / fps) + 1;
		indice = frames[value];
		return value;
	}

	public var totalFrames(get_totalFrames, null):Int;

	inline function get_totalFrames():Int
	{
		return frames.length;
	}
}
