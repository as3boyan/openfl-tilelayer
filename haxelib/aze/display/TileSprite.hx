package aze.display;

import aze.display.TileGroup;
import aze.display.TileLayer;
import flash.geom.Matrix;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

#if flash
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
#end

/**
 * Static tile for TileLayer
 * @author Philippe / http://philippe.elsass.me
 */
class TileSprite extends TileBase
{
	var _tile:String;
	var _indice:Int;
	var size:Rectangle;

	var dirty:Bool;
	var _rotation:Float;
	var _scaleX:Float;
	var _scaleY:Float;
	var _mirror:Int;
	var _offset:Point;

	#if !flash
	var _transform:Array<Float>;
	#else
	var _matrix:Matrix;
	public var bmp:Bitmap;
	#end

	#if flash
	private var _alpha:Float;
	#else
	public var alpha:Float;
	#end
	
	public var r:Float;
	public var g:Float;
	public var b:Float;
	
	#if flash
	var img:Image;
	var container:Sprite;
	#end

	public function new(layer:TileLayer, tile:String) 
	{
		super(layer);
		_rotation = 0;
		
		#if flash
		if (!TileLayer.starling_init)
		{
			alpha = _scaleX = _scaleY = 1;
		}
		else
		{
			_alpha = _scaleX = _scaleY = 1;
		}
		#else
		alpha = _scaleX = _scaleY = 1;
		#end
		
		_mirror = 0;
		_indice = -1;
		#if flash
		if (TileLayer.starling_init)
		{
			container = new Sprite();
		}
		else
		{
			bmp = new Bitmap();
		}
		_matrix = new Matrix();
		#else
		_transform = new Array<Float>();
		#end
		dirty = true;
		
		this.tile = tile;
	}
	
	#if flash
	
	override private function set_x(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_x != value) container.x = value;
		}

		super.set_x(value);
		return value;
	}
	
	override private function set_y(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_y != value) container.y = value;
		}
		super.set_y(value);
		return value;
	}
	
	#end
	
	override public function init(layer:TileLayer):Void
	{
		this.layer = layer;
		
		#if flash
		if (!TileLayer.starling_init)
		{
			var indices = layer.tilesheet.getAnim(tile);
			indice = indices[0];
			size = layer.tilesheet.getSize(indice);
		}
		else if (container.numChildren == 0)
		{			
			
			img = new Image(layer.tilesheet.texture_atlas.getTextures(tile)[0]);
			img.alignPivot();
			size = new Rectangle(0, 0, img.width, img.height);
			container.addChild(img);
				
			if (layer.useAdditive) img.blendMode = BlendMode.ADD;
		}
		#else
			var indices = layer.tilesheet.getAnim(tile);
			indice = indices[0];
			size = layer.tilesheet.getSize(indice);
		#end
	}
	
	#if flash
	override public function getView():DisplayObject { return bmp; }
	override public function getView2():starling.display.DisplayObject { return container; }
	#end

	public var tile(get_tile, set_tile):String;
	inline function get_tile():String { return _tile; }
	function set_tile(value:String):String
	{
		if (_tile != value) {
			_tile = value;
			
				if (layer != null) init(layer); // update visual
		}
		return value;
	}

	public var indice(get_indice, set_indice):Int;
	inline function get_indice():Int { return _indice; }
	function set_indice(value:Int)
	{
		if (_indice != value)
		{
			_indice = value;
			#if flash
			bmp.bitmapData = layer.tilesheet.getBitmap(value);
			bmp.smoothing = layer.useSmoothing;
			#end
		}
		return value;
	}

	public var mirror(get_mirror, set_mirror):Int;
	inline function get_mirror():Int { return _mirror; }
	function set_mirror(value:Int):Int 
	{
		if (_mirror != value) {
			_mirror = value;
			dirty = true;
		}
		return value;
	}

	public var rotation(get_rotation, set_rotation):Float;	
	inline function get_rotation():Float 
	{ 
		return _rotation; 
	}
	function set_rotation(value:Float):Float 
	{
		
		#if flash	
		if (TileLayer.starling_init)
		{
			container.rotation = value;
			
			if (_rotation != value) 
			{
				_rotation = value;
			}
		}
		else
		{
			if (_rotation != value) 
			{
				_rotation = value;
				dirty = true;
			}
		}
		#else
			if (_rotation != value) 
			{
				_rotation = value;
				dirty = true;
			}
		#end
		return value;
	}

	public var scale(get_scale, set_scale):Float;
	inline function get_scale():Float
	{ 
		return _scaleX; 
	}
	function set_scale(value:Float):Float 
	{
		#if flash
		if (TileLayer.starling_init)
		{
			if (_scaleX != value || _scaleY != value)
			{
			_scaleX = value;
			_scaleY = value;
			container.scaleX = container.scaleY = value;
			}
		}
		else
		{
			if (_scaleX != value) {
			_scaleX = value;
			_scaleY = value;
			dirty = true;
			}
		}
		#else
			if (_scaleX != value) {
			_scaleX = value;
			_scaleY = value;
			dirty = true;
			}
		#end
		
		return value;
	}

	public var scaleX(get_scaleX, set_scaleX):Float;
	inline function get_scaleX():Float 
	{ 
		return _scaleX; 
	}
	
	function set_scaleX(value:Float):Float 
	{
		#if flash
		if (TileLayer.starling_init)
		{
			container.scaleX = value;
			_scaleX = value;
		}
		else
		{
			if (_scaleX != value) {
				_scaleX = value;
				dirty = true;
			}
		}
		#else
			if (_scaleX != value) {
				_scaleX = value;
				dirty = true;
			}
		#end
		return value;
	}

	public var scaleY(get_scaleY, set_scaleY):Float;
	inline function get_scaleY():Float
	{
		return _scaleY; 
	}
	function set_scaleY(value:Float):Float 
	{
		#if flash
		if (TileLayer.starling_init)
		{
			container.scaleY = value;
			_scaleY = value;
		}
		else
		{			
			if (_scaleY != value) {
				_scaleY = value;
				dirty = true;
			}
		}
		#else
			if (_scaleY != value) {
				_scaleY = value;
				dirty = true;
			}
		#end
		return value;
	}

	public var color(get_color, set_color):Int;
	function get_color():Int 
	{ 
		return Std.int(r * 256.0) << 16
			+ Std.int(g * 256.0) << 8
			+ Std.int(b * 256.0);
	}
	function set_color(value:Int):Int 
	{
		#if flash
		if (TileLayer.starling_init)
		{
			img.color = value;
		}
		#end
		
		r = (value >> 16) / 255.0;
		g = ((value >> 8) & 0xff) / 255.0;
		b = (value & 0xff) / 255.0;
		return value;
	}
	
	#if flash
	
	override private function set_visible(value:Bool):Bool 
	{
		if (TileLayer.starling_init)
		{
			if ( _visible != value) container.visible = value;
		}
		return super.set_visible(value);
	}
	
	#end
	
	#if !flash
	public var transform(get_transform, null):Array<Float>;
	function get_transform():Array<Float>
	{
		if (dirty == true) 
		{
			dirty = false;
			var dirX:Int = mirror == 1 ? -1 : 1;
			var dirY:Int = mirror == 2 ? -1 : 1;
			var sx:Float = scaleX * layer.tilesheet.scale;
			var sy:Float = scaleY * layer.tilesheet.scale;
			if (rotation != 0) {
				var cos = Math.cos(rotation);
				var sin = Math.sin(rotation);
				_transform[0] = dirX * cos * sx;
				_transform[1] = dirY * sin * sy;
				_transform[2] = -dirX * sin * sx;
				_transform[3] = dirY * cos * sy;
			}
			else {
				_transform[0] = dirX * sx;
				_transform[1] = 0;
				_transform[2] = 0;
				_transform[3] = dirY * sy;
			}
		}
		return _transform;
	}

	#else
	public var matrix(get_matrix, null):Matrix;
	function get_matrix():Matrix 
	{ 
		if (dirty == true)
		{
			dirty = false;
			var tileWidth = width / 2;
			var tileHeight = height / 2;
			var m = _matrix;
			m.identity();
			if (layer.useTransforms) {
				m.scale(scaleX * layer.tilesheet.scale, scaleY * layer.tilesheet.scale);
				if (mirror != 0) {
					if (mirror == 1) { m.scale(-1, 1); m.translate(tileWidth * 2, 0); }
					else if (mirror == 2) { m.scale(1, -1); m.translate(0, tileHeight * 2); }
				}
				if (rotation != 0) {
					m.translate(-tileWidth, -tileHeight);
					m.rotate(rotation);
					m.translate(tileWidth, tileHeight);
				}
			}
			m.translate(-tileWidth, -tileHeight);
		}
		return _matrix;
	}
	#end

	public var height(get_height, null):Float;
	inline function get_height():Float 
	{
		return size.height * _scaleY;
	}

	public var width(get_width, null):Float;
	inline function get_width():Float 
	{
		return size.width * _scaleX;
	}

	public var offset(get_offset, set_offset):Point;
	
	#if flash
	
	function get_alpha():Float 
	{
		return _alpha;
	}
	
	function set_alpha(value:Float):Float 
	{
		if (TileLayer.starling_init)
		{
			if (_alpha != value) container.alpha = value;
		}
		return _alpha = value;
	}
	
	public var alpha(get_alpha, set_alpha):Float;
	
	#end
	
	inline function get_offset():Point { return _offset; }
	function set_offset(value:Point):Point
	{
		#if flash
		if (TileLayer.starling_init)
		{
			getView2().pivotX = value.x;
			getView2().pivotY = value.y;
		}
		else
		{
			_offset = new Point(value.x / layer.tilesheet.scale, value.y / layer.tilesheet.scale);
		}
		#else
		_offset = new Point(value.x / layer.tilesheet.scale, value.y / layer.tilesheet.scale);
		#end
		return _offset;
	}
}
