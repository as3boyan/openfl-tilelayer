package aze.display;

import flash.display3D.Context3DRenderMode;
import flash.events.ErrorEvent;
import flash.geom.Point;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.Lib;
import flash.system.Capabilities;
import haxe.Timer;

#if flash
import starling.core.Starling;
import starling.events.Event;
#end

/**
 * A little wrapper of NME's Tilesheet rendering (for native platform)
 * and using Bitmaps for Flash platform.
 * Features basic containers (TileGroup) and spritesheets animations.
 * @author Philippe / http://philippe.elsass.me
 */
class TileLayer extends TileGroup
{
	static var synchronizedElapsed:Float;

	public var view:Sprite;
	
	#if flash
	public var view2:starling.display.Sprite;
	#end
	
	public var useSmoothing:Bool;
	public var useAdditive:Bool;
	public var useAlpha:Bool;
	public var useTransforms:Bool;
	public var useTint:Bool;

	public var tilesheet:TilesheetEx;
	var drawList:DrawList;
	
	public static var starling_init:Bool;

	public function new(tilesheet:TilesheetEx, smooth:Bool=true, additive:Bool=false)
	{
		super(this);
		
		#if flash
		if (TileLayer.starling_init)
		{
			view2 = new starling.display.Sprite();
			var sprite:starling.display.Sprite = cast(Starling.current.stage.getChildAt(0), starling.display.Sprite);
			sprite.addChild(view2);
			
			view2.addChild(container2);
		}
		#end
		
		view = new Sprite();
		view.mouseEnabled = false;
		view.mouseChildren = false;

		this.tilesheet = tilesheet;
		useSmoothing = smooth;
		useAdditive = additive;
		useAlpha = true;
		useTransforms = true;

		drawList = new DrawList();
	}
	
	public static function initStarling(init:Void->Void):Void 
	{
		#if flash11
		
		var version:String = Capabilities.version;
		
		var major_version:Int = 0;
		
		var ereg:EReg = ~/ ([0-9+]+),/;
		if (ereg.match(version))
		{
			major_version = Std.parseInt(ereg.matched(1));
		}
		
		var stage = Lib.current.stage;
		
		if (major_version == 11 && Reflect.hasField(stage, "stage3Ds"))
		{
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE,	onContextCreated.bind(init) );
			stage.stage3Ds[0].requestContext3D();
			
			stage.stage3Ds[0].addEventListener(ErrorEvent.ERROR, onStage3DError.bind(init) );
		}
		else
		{
			init();
		}
		
		#else
		init();
		#end
	}
	
	#if flash
	
	static private function onStage3DError(init:Void->Void, e:ErrorEvent):Void 
	{
		var stage = Lib.current.stage;
		stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE,	onContextCreated.bind(init) );
		stage.stage3Ds[0].removeEventListener(ErrorEvent.ERROR, onStage3DError.bind(init) );
		
		init();
	}
	
		
	static private function onContextCreated(init:Void->Void, e:flash.events.Event):Void 
	{
		var stage = Lib.current.stage;
		stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE,	onContextCreated.bind(init) );
		stage.stage3Ds[0].removeEventListener(ErrorEvent.ERROR, onStage3DError.bind(init) );
		
		
		if (Starling.current == null)
		{
			Starling.handleLostContext = true;
			var mStarling:Starling = new Starling(StarlingSprite, Lib.current.stage, null, stage.stage3Ds[0]);
			mStarling.shareContext = false;
			mStarling.start();
		}
		
		var timer:Timer = new Timer(100);
		timer.run = function ():Void
		{
			if (starling_init)
			{
				timer.stop();
				
				init();
			}
		}
	}
	
	#end

	public function render(?elapsed:Int)
	{
		#if flash
		if (starling_init) return;
		#end
		
		drawList.begin(elapsed == null ? 0 : elapsed, useTransforms, useAlpha, useTint, useAdditive);
		renderGroup(this, 0, 0, 0);
		drawList.end();
		#if flash
		view.addChild(container);
		#else
		view.graphics.clear();
		tilesheet.drawTiles(view.graphics, drawList.list, useSmoothing, drawList.flags);
		#end
		
		#if !flash
		return drawList.elapsed;
		#else
		return;
		#end
	}

	function renderGroup(group:TileGroup, index:Int, gx:Float, gy:Float)
	{
		var list = drawList.list;
		var fields = drawList.fields;
		var offsetTransform = drawList.offsetTransform;
		var offsetRGB = drawList.offsetRGB;
		var offsetAlpha = drawList.offsetAlpha;
		var elapsed = drawList.elapsed;

		#if flash
		group.container.x = gx + group.x;
		group.container.y = gy + group.y;
		var blend = useAdditive ? BlendMode.ADD : BlendMode.NORMAL;
		#else
		gx += group.x;
		gy += group.y;
		#end

		var n = group.numChildren;
		for(i in 0...n)
		{
			var child = group.children[i];
			if (child.animated) child.step(elapsed);

			#if (flash||js)
			var group:TileGroup = Std.is(child, TileGroup) ? cast child : null;
			#else
			if (!child.visible) 
				continue;
			var group:TileGroup = cast child;
			#end

			if (group != null) 
			{
				index = renderGroup(group, index, gx, gy);
			}
			else 
			{
				var sprite:TileSprite = cast child;

				#if flash
				if (sprite.visible && sprite.alpha > 0.0)
				{
					var m = sprite.bmp.transform.matrix;
					m.identity();
					m.concat(sprite.matrix);
					m.translate(sprite.x, sprite.y);
					sprite.bmp.transform.matrix = m;
					sprite.bmp.blendMode = blend;
					sprite.bmp.alpha = sprite.alpha;
					sprite.bmp.visible = true;
					// TODO apply tint
				}
				else sprite.bmp.visible = false;

				#else
				if (sprite.alpha <= 0.0) continue;
				list[index+2] = sprite.indice;

				if (sprite.offset != null) 
				{
					var off:Point = sprite.offset;					
					if (offsetTransform > 0) {
						var t = sprite.transform;
						list[index] = sprite.x - off.x * t[0] - off.y * t[1] + gx;
						list[index+1] = sprite.y - off.x * t[2] - off.y * t[3] + gy;
						list[index+offsetTransform] = t[0];
						list[index+offsetTransform+1] = t[1];
						list[index+offsetTransform+2] = t[2];
						list[index+offsetTransform+3] = t[3];
					}
					else {
						list[index] = sprite.x - off.x + gx;
						list[index+1] = sprite.y - off.y + gy;
					}
				}
				else {
					list[index] = sprite.x + gx;
					list[index+1] = sprite.y + gy;
					if (offsetTransform > 0) {
						var t = sprite.transform;
						list[index+offsetTransform] = t[0];
						list[index+offsetTransform+1] = t[1];
						list[index+offsetTransform+2] = t[2];
						list[index+offsetTransform+3] = t[3];
					}
				}

				if (offsetRGB > 0) {
					list[index+offsetRGB] = sprite.r;
					list[index+offsetRGB+1] = sprite.g;
					list[index+offsetRGB+2] = sprite.b;
				}
				if (offsetAlpha > 0) list[index+offsetAlpha] = sprite.alpha;
				index += fields;
				#end
			}
		}
		drawList.index = index;
		return index;
	}
}


/**
 * @private base tile type
 */

class TileBase
{
	public var layer:TileLayer;
	public var parent:TileGroup;
	private var _x:Float;
	private var _y:Float;
	public var animated:Bool;
	private var _visible:Bool;

	function new(layer:TileLayer)
	{
		this.layer = layer;
		
		if (!TileLayer.starling_init)
		{
			x = y = 0.0;
			visible = true;
		}
		else
		{
			_x = _y = 0.0;
		}
	}

	function init(layer:TileLayer):Void
	{
		this.layer = layer;
	}

	public function step(elapsed:Int)
	{
	}

	function get_y():Float 
	{
		return _y;
	}
	
	function set_y(value:Float):Float 
	{
		return _y = value;
	}
	
	public var y(get_y, set_y):Float;
	
	function get_x():Float 
	{
		return _x;
	}
	
	function set_x(value:Float):Float 
	{
		return _x = value;
	}
	
	public var x(get_x, set_x):Float;
	
	function get_visible():Bool 
	{
		return _visible;
	}
	
	function set_visible(value:Bool):Bool 
	{
		return _visible = value;
	}
	
	public var visible(get_visible, set_visible):Bool;
	
	#if flash
	function getView():DisplayObject { return null; }
	function getView2():starling.display.DisplayObject { return null; }
	#end
}


/**
 * @private render buffer
 */
#if haxe3
	class DrawList
#else
	class DrawList implements Public
#end
{
	public var list:Array<Float>;
	public var index:Int;
	public var fields:Int;
	public var offsetTransform:Int;
	public var offsetRGB:Int;
	public var offsetAlpha:Int;
	public var flags:Int;
	public var time:Int;
	public var elapsed:Int;
	public var runs:Int;

	#if haxe3
		public function new() 
	#else
		function new() 
	#end
	{
		list = new Array<Float>();
		elapsed = 0;
		runs = 0;
	}

	#if haxe3
		public function begin(elapsed:Int, useTransforms:Bool, useAlpha:Bool, useTint:Bool, useAdditive:Bool) 
	#else
		function begin(elapsed:Int, useTransforms:Bool, useAlpha:Bool, useTint:Bool, useAdditive:Bool) 
	#end
	{
		#if !flash
		flags = 0;
		fields = 3;
		if (useTransforms) {
			offsetTransform = fields;
			fields += 4;
			flags |= Graphics.TILE_TRANS_2x2;
		}
		else offsetTransform = 0;
		if (useTint) {
			offsetRGB = fields; 
			fields+=3; 
			flags |= Graphics.TILE_RGB;
		}
		else offsetRGB = 0;
		if (useAlpha) {
			offsetAlpha = fields; 
			fields++; 
			flags |= Graphics.TILE_ALPHA;
		}
		else offsetAlpha = 0;
		if (useAdditive) flags |= Graphics.TILE_BLEND_ADD;
		#end

		if (elapsed > 0) this.elapsed = elapsed;
		else
		{
			index = 0;
			if (time > 0) {
				var t = Lib.getTimer();
				this.elapsed = cast Math.min(67, t - time);
				time = t;
			}
			else time = Lib.getTimer();
		}
	}

	public function end()
	{
		if (list.length > index) 
		{
			if (++runs > 60) 
			{
				list.splice(index, list.length - index); // compact buffer
				runs = 0;
			}
			else
			{
				while (index < list.length)
				{
					list[index + 2] = -2.0; // set invalid ID
					index += fields;
				}
			}
		}
	}
}
