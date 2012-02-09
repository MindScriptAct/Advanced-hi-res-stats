package utils.debug {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.utils.getTimer;

/**
 * Improved Stats
 * https://github.com/MindScriptAct/Hi-ReS-Stats(fork of https://github.com/mrdoob/Hi-ReS-Stats)
 * Merged with : https://github.com/rafaelrinaldi/Hi-ReS-Stats AND https://github.com/shamruk/Hi-ReS-Stats
 *
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 *
 *	addChild( new Stats() );
 *
 **/

public class Stats extends Sprite {
	
	// stats default size.
	private const WIDTH:int = 70;
	private const HEIGHT:int = 100;
	// fps button consts
	static private const FPS_BUTTON_XPOS:int = 62;
	static private const FPS_BUTTON_YPOS:int = 2;
	static private const FPS_BUTTON_SIZE:Number = 6;
	static private const FPS_BUTTON_GAP:int = 9;
	// scroll size
	static private const SCROLL_SIZE:Number = 10;
	
	// bonus width addet to default WIDTH.
	private var bonusWidth:int = 0;
	
	// stats data in XML format.
	private var statData:XML;
	
	// textField for stats information
	private var text:TextField;
	private var style:StyleSheet;
	
	// reacent getTimer value.
	private var timer:uint = 0;
	
	// current stat data
	private var fps:int = 0;
	private var ms:int = 0;
	private var msPrev:int = 0;
	private var mem:Number = 0;
	private var memMax:Number = 0;
	
	//  graph draw object
	private var graph:BitmapData;
	private var clearRect:Rectangle;
	
	// current graph draw value.
	private var fpsGraph:int = 0;
	private var memGraph:int = 0;
	private var memMaxGraph:int = 0;
	
	// object for collor values. (it performs tini bit faster then constants.)
	private var colors:StatColors = new StatColors();
	
	// flag for stats beeing dragable or not.
	private var isDraggable:Boolean = false;
	
	// flag to show application execution and render monitoring.
	// TODO : rename...
	private var isMonitoring:Boolean = false;
	
	private var keepGraph:Boolean = false;
	
	// for monitoring..
	static private const MONITOR_WIDTH:int = 500;
	private var codeTime:uint;
	private var lastTimeStamp:uint;
	private var frameRateTime:int;
	private var frameTime:uint;
	private var monitorView_BD:BitmapData;
	private var monitorView:Bitmap;
	
	/**
	 * <b>Stats</b> FPS, MS and MEM, all in one.
	 * @param isDraggable enables draging functionality.
	 */
	
	public function Stats(width:int = 70, x:int = 0, y:int = 0, isDraggable:Boolean = true, isMonitoring:Boolean = false):void {
		
		// calculate increased width.
		bonusWidth = width - WIDTH;
		if (bonusWidth < 0) {
			bonusWidth = 0;
		}
		
		// initial positioning
		this.x = x;
		this.y = y;
		
		//
		this.isDraggable = isDraggable;
		this.isMonitoring = isMonitoring;
		
		//
		memMax = 0;
		
		// stat data stored in XML formated text.
		statData =     <xmlData>
				<fps>FPS:</fps>
				<ms>MS:</ms>
				<mem>MEM:</mem>
				<memMax>MAX:</memMax>
			</xmlData>;
		
		// style for stats.
		style = new StyleSheet();
		style.setStyle('xmlData', {fontSize: '9px', fontFamily: '_sans', leading: '-2px'});
		style.setStyle('fps', {color: hex2css(colors.fps)});
		style.setStyle('ms', {color: hex2css(colors.ms)});
		style.setStyle('mem', {color: hex2css(colors.mem)});
		style.setStyle('memMax', {color: hex2css(colors.memmax)});
		
		// text fild to show all stats.
		// TODO : test if it's not more simple just to have 4 text fields without xml and css...
		text = new TextField();
		text.width = WIDTH;
		text.height = 50;
		text.styleSheet = style;
		text.condenseWhite = true;
		text.selectable = false;
		text.mouseEnabled = false;
		
		//
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
	
	}
	
	private function init(event:Event):void {
		
		// draw bg and graph
		initDrawArea();
		
		// add text
		addChild(text);
		
		//
		clearRect = new Rectangle(WIDTH + bonusWidth - 1, 0, 1, HEIGHT - 50);
		
		//
		addEventListener(MouseEvent.CLICK, handleClick);
		addEventListener(Event.ENTER_FRAME, handleFrameTick);
		addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		
		// add dragging feature listeners if needed.
		if (isDraggable) {
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		if (isMonitoring) {
			this.stage.addEventListener(Event.RENDER, handleFrameRender);
			frameRateTime = Math.round(1000 / this.stage.frameRate);
		}
	
	}
	
	private function initDrawArea():void {
		// draw bg.
		graphics.beginFill(colors.bg);
		graphics.drawRect(0, 0, WIDTH + bonusWidth, HEIGHT);
		graphics.endFill();
		
		// draw fps UP/DOWN buttons
		graphics.lineStyle(1, colors.fps, 1);
		graphics.drawRect(FPS_BUTTON_XPOS, FPS_BUTTON_YPOS, FPS_BUTTON_SIZE, FPS_BUTTON_SIZE);
		graphics.drawRect(FPS_BUTTON_XPOS, FPS_BUTTON_YPOS + FPS_BUTTON_GAP, FPS_BUTTON_SIZE, FPS_BUTTON_SIZE);
		graphics.moveTo(FPS_BUTTON_XPOS + FPS_BUTTON_SIZE / 2, FPS_BUTTON_YPOS);
		graphics.lineTo(FPS_BUTTON_XPOS + FPS_BUTTON_SIZE / 2, FPS_BUTTON_YPOS + FPS_BUTTON_SIZE);
		graphics.moveTo(FPS_BUTTON_XPOS, FPS_BUTTON_YPOS + FPS_BUTTON_SIZE / 2);
		graphics.lineTo(FPS_BUTTON_XPOS + FPS_BUTTON_SIZE, FPS_BUTTON_YPOS + FPS_BUTTON_SIZE / 2);
		graphics.moveTo(FPS_BUTTON_XPOS, FPS_BUTTON_YPOS + FPS_BUTTON_SIZE / 2 + FPS_BUTTON_GAP);
		graphics.lineTo(FPS_BUTTON_XPOS + FPS_BUTTON_SIZE, FPS_BUTTON_YPOS + FPS_BUTTON_SIZE / 2 + FPS_BUTTON_GAP);
		graphics.lineStyle();
		
		// draw graph
		if (keepGraph) {
			var oldGraph:BitmapData = graph;
		}
		graph = new BitmapData(WIDTH + bonusWidth, HEIGHT - 50, false, colors.bg);
		graphics.beginBitmapFill(graph, new Matrix(1, 0, 0, 1, 0, 50));
		graphics.drawRect(0, 50, WIDTH + bonusWidth, HEIGHT - 50);
		// if oldGraph is set - drow its content into new graph.
		if (keepGraph) {
			graph.draw(oldGraph, new Matrix(1, 0, 0, 1, graph.width - oldGraph.width, 0));
			oldGraph.dispose();
			keepGraph = false;
		}
		
		if (isMonitoring) {
			if (!monitorView) {
				monitorView_BD = new BitmapData(MONITOR_WIDTH, 40, false, 0x000000);
				monitorView = new Bitmap(monitorView_BD);
				this.addChild(monitorView);
			}
			monitorView.x = WIDTH + bonusWidth + 10;
		}
	}
	
	private function destroy(event:Event):void {
		// clear bg
		graphics.clear();
		
		// remove all childs.
		while (numChildren > 0) {
			removeChildAt(0);
		}
		
		// dispose graph bitmap.
		graph.dispose();
		
		// remove listeners.
		removeEventListener(MouseEvent.CLICK, handleClick);
		removeEventListener(Event.ENTER_FRAME, handleFrameTick);
		
		if (isDraggable) {
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
	}
	
	// every frame calculate frame stats.
	private function handleFrameTick(event:Event):void {
		
		//------
		frameTime = getTimer() - lastTimeStamp;
		lastTimeStamp = getTimer();
		//------
		
		timer = getTimer();
		
		// calculate time change from last tick in ms.
		var timeDif:uint = timer - msPrev;
		
		// check if more then 1 second passed.
		if (timeDif >= 1000) {
			
			//
			msPrev = timer;
			
			// calculate ammount of missed seconds. (this can happen then player hangs more then 2 seccond on a job.)
			var missedSeconds:uint = (timeDif - 1000) / 1000;
			
			// get current memory.
			mem = Number((System.totalMemory * 0.000000954).toFixed(3));
			
			// update max memory.
			if (memMax < mem) {
				memMax = mem;
			}
			
			// calculate graph point positios.
			fpsGraph = Math.min(graph.height, (fps / stage.frameRate) * graph.height);
			memGraph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
			memMaxGraph = Math.min(graph.height, Math.sqrt(Math.sqrt(memMax * 5000))) - 2;
			
			// move graph by 1 pixels for every second passed.
			graph.scroll(-1 - missedSeconds, 0);
			
			// clear rectangle area for new graph data.
			if (missedSeconds) {
				graph.fillRect(new Rectangle(graph.width - 1 - missedSeconds, 0, 1 + missedSeconds, HEIGHT - 50), colors.bg);
			} else {
				graph.fillRect(clearRect, colors.bg);
			}
			
			// draw missed seconds. (if player failed to respond for more then 1 second that means it was hanging, and FPS was < 1 for that time.)
			while (missedSeconds) {
				graph.setPixel(graph.width - 1 - missedSeconds, graph.height - 1, colors.fps);
				missedSeconds--;
			}
			
			// draw current graph data. 
			graph.setPixel(graph.width - 1, graph.height - ((timer - ms) >> 1), colors.ms);
			graph.setPixel(graph.width - 1, graph.height - memGraph, colors.mem);
			graph.setPixel(graph.width - 1, graph.height - memMaxGraph, colors.memmax);
			graph.setPixel(graph.width - 1, graph.height - fpsGraph, colors.fps);
			
			// update data for new frame stats.
			statData.fps = "FPS: " + fps + " / " + stage.frameRate;
			statData.mem = "MEM: " + mem;
			statData.memMax = "MAX: " + memMax;
			
			// frame count for 1 second handled - reset it.
			fps = 0;
		}
		
		// increse frame tick count by 1.
		fps++;
		
		// calculate time in ms for one frame tick.
		statData.ms = "MS: " + (timer - ms);
		ms = timer;
		
		// update data text.
		text.htmlText = statData;
		
		if (isMonitoring) {
			this.stage.invalidate();
			
			// drawCodeTime
			monitorView_BD.fillRect(new Rectangle(0, 0, codeTime, 10), 0x00FF00);
			// draw frameTime
			monitorView_BD.fillRect(new Rectangle(codeTime, 0, frameTime - codeTime, 10), 0xFFFF00);
			// clean rest of the line
			monitorView_BD.fillRect(new Rectangle(frameTime, 0, MONITOR_WIDTH, 10), 0x000000);
			// frame time delimeter
			monitorView_BD.fillRect(new Rectangle(frameRateTime, 0, 1, 10), 0xFF0000);
			//
			// copy one line down
			monitorView_BD.copyPixels(monitorView_BD, new Rectangle(0, 9, MONITOR_WIDTH, 40), new Point(0, 10));
			// separator for main graph and log.
			monitorView_BD.fillRect(new Rectangle(0, 9, MONITOR_WIDTH, 1), 0xD8D8D8);
			
		}
	}
	
	// handle click over stat object.
	private function handleClick(event:MouseEvent):void {
		// check if click is in button area.
		if (this.mouseX > FPS_BUTTON_XPOS) {
			if (this.mouseX < FPS_BUTTON_XPOS + FPS_BUTTON_SIZE) {
				if (this.mouseY > FPS_BUTTON_YPOS) {
					if (this.mouseY < FPS_BUTTON_YPOS + FPS_BUTTON_SIZE) {
						stage.frameRate = Math.round(stage.frameRate + 1);
						statData.fps = "FPS: " + fps + " / " + stage.frameRate;
						text.htmlText = statData;
					}
				}
				if (this.mouseY > FPS_BUTTON_YPOS + FPS_BUTTON_GAP) {
					if (this.mouseY < FPS_BUTTON_YPOS + FPS_BUTTON_SIZE + FPS_BUTTON_GAP) {
						stage.frameRate = Math.round(stage.frameRate - 1);
						statData.fps = "FPS: " + fps + " / " + stage.frameRate;
						text.htmlText = statData;
					}
				}
			}
		}
	}
	
	// handle mouseWheel
	private function handleMouseWheel(event:MouseEvent):void {
		if (event.delta > 0) {
			bonusWidth += SCROLL_SIZE;
		} else {
			bonusWidth -= SCROLL_SIZE;
			if (bonusWidth < 0) {
				bonusWidth = 0;
			}
		}
		// clear bg
		graphics.clear();
		// flag graph to be preserved.
		keepGraph = true;
		// redraw bg
		initDrawArea();
	}
	
	// 
	private function handleFrameRender(event:Event):void {
		codeTime = getTimer() - lastTimeStamp;
	}
	
	//----------------------------------
	//     Dragging functions
	//----------------------------------
	
	// start dragging
	private function handleMouseDown(event:MouseEvent):void {
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	// stop dragging
	private function handleMouseUp(event:MouseEvent):void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	// handle dragging
	private function mouseMoveHandler(event:MouseEvent):void {
		// calculete new possitions.
		this.x = this.stage.mouseX - this.width * .5;
		this.y = this.stage.mouseY - this.height * .5;
		
		// handle x bounds
		if (this.x > this.stage.stageWidth - this.width) {
			this.x = this.stage.stageWidth - this.width;
		} else if (this.x < 0) {
			this.x = 0;
		}
		
		// handle y bounds.
		if (this.y > this.stage.stageHeight - this.height) {
			this.y = this.stage.stageHeight - this.height;
		} else if (this.y < 0) {
			this.y = 0;
		}
	}
	
	// handle mous leaving the screen.
	private function mouseLeaveHandler(event:Event):void {
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	//----------------------------------
	//     Utils
	//----------------------------------
	
	// converts color number to hex value.
	private function hex2css(color:int):String {
		return "#" + color.toString(16);
	}

}
}

// helper class to store graph corols.
class StatColors {
	public var bg:uint = 0x000033;
	public var fps:uint = 0xffff00;
	public var ms:uint = 0x00ff00;
	public var mem:uint = 0x00ffff;
	public var memmax:uint = 0xff0070;

}