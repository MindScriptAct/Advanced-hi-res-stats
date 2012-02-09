package utils.debug {
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
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
	private const WIDTH:uint = 70;
	private const HEIGHT:uint = 100;
	
	// stats data in XML format.
	private var statData:XML;
	
	// textField for stats information
	private var text:TextField;
	private var style:StyleSheet;
	
	// reacent getTimer value.
	private var timer:uint;
	
	// current stat data
	private var fps:uint;
	private var ms:uint;
	private var msPrev:uint;
	private var mem:Number;
	private var memMax:Number;
	
	//  graph draw object
	private var graph:BitmapData;
	private var clearRect:Rectangle;
	
	// current graph draw value.
	private var fpsGraph:uint;
	private var memGraph:uint;
	private var memMaxGraph:uint;
	
	// object for collor values. (it performs tini bit faster then constants.)
	private var colors:StatColors = new StatColors();
	
	// flag for stats beeing dragable or not.
	private var isDraggable:Boolean;
	
	/**
	 * <b>Stats</b> FPS, MS and MEM, all in one.
	 * @param isDraggable enables draging functionality.
	 */
	
	public function Stats(isDraggable:Boolean = true):void {
		this.isDraggable = isDraggable;
		
		memMax = 0;
		
		// stat data stored in XML formated text.
		statData =  <xmlData>
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
		clearRect = new Rectangle(WIDTH - 1, 0, 1, HEIGHT - 50);
		
		//
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
	
	}
	
	private function init(event:Event):void {
		
		// draw bg.
		graphics.beginFill(colors.bg);
		graphics.drawRect(0, 0, WIDTH, HEIGHT);
		graphics.endFill();
		
		graph = new BitmapData(WIDTH, HEIGHT - 50, false, colors.bg);
		graphics.beginBitmapFill(graph, new Matrix(1, 0, 0, 1, 0, 50));
		graphics.drawRect(0, 50, WIDTH, HEIGHT - 50);
		
		// add text nad graph.
		addChild(text);		
		//
		addEventListener(MouseEvent.CLICK, handleClick);
		addEventListener(Event.ENTER_FRAME, handleFrameTick);
	
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
	}
	
	private function handleFrameTick(event:Event):void {
		
		timer = getTimer();
		
		// calculate time change from last tick in ms.
		var timeDif:uint = timer - msPrev;
		
		// check if more then 1 second passed.
		if (timeDif >= 1000) {
			
			// calculate ammount of missed seconds. (this can happen then player hangs more then 2 seccond on a job.)
			var missedSeconds:uint = (timeDif - 1000) / 1000;
			
			// TODO : is this line here needed?
			fps = fps % 1000;
			
			msPrev = timer;
			
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
			graph.scroll(- 1 - missedSeconds, 0);
			
			// clear rectangle area for new graph data.
			if (missedSeconds) {
				graph.fillRect(new Rectangle(WIDTH - 1 - missedSeconds, 0, 1 + missedSeconds, HEIGHT - 50), colors.bg);
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
	}
	
	// handle click over stat object.
	private function handleClick(event:MouseEvent):void {
		mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
		statData.fps = "FPS: " + fps + " / " + stage.frameRate;
		text.htmlText = statData;
	}
	
	// .. Utils
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
















// for removal..

import utils.debug.Stats;

import flash.display.StageAlign;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
/**
 *
 * <code>Stats</code> with drag control and easy align management via <code>ContextMenu</code>.
 *
 * @author Rafael Rinaldi (rafaelrinaldi.com)
 * @since Ago 8, 2010
 *
 */
class DraggableStats {
	public var target:Stats;
	
	/**
	 * @param p_target <code>Stats</code> instance.
	 */
	public function DraggableStats(p_target:Stats) {
		target = p_target;
		target.buttonMode = true;
		target.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	protected function addedToStageHandler(event:Event):void {
		/** Creating <code>Stage</code> listeners. **/
		target.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		target.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
		
		/** Creating target listener. **/
		target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		
		/** Watching for events. **/
		target.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	protected function mouseUpHandler(event:MouseEvent):void {
		target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	protected function mouseDownHandler(event:MouseEvent):void {
		target.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	protected function mouseMoveHandler(event:MouseEvent):void {
		target.x = target.stage.mouseX - target.width * .5;
		target.y = target.stage.mouseY - target.height * .5;
		
		if (target.x > target.stage.stageWidth - target.width) {
			target.x = target.stage.stageWidth - target.width;
		} else if (target.x < 0) {
			target.x = 0;
		}
		
		if (target.y > target.stage.stageHeight - target.height) {
			target.y = target.stage.stageHeight - target.height;
		} else if (target.y < 0) {
			target.y = 0;
		}
		
		event.updateAfterEvent();
	}
	
	protected function mouseLeaveHandler(event:Event):void {
		target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}

}