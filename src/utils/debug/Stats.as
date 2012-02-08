package utils.debug  {
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
	
	protected const WIDTH:uint = 70;
	protected const HEIGHT:uint = 100;
	
	protected var xml:XML;
	
	protected var text:TextField;
	protected var style:StyleSheet;
	
	protected var timer:uint;
	protected var fps:uint;
	protected var ms:uint;
	protected var ms_prev:uint;
	protected var mem:Number;
	protected var mem_max:Number;
	
	protected var graph:BitmapData;
	protected var rectangle:Rectangle;
	
	protected var fps_graph:uint;
	protected var mem_graph:uint;
	protected var mem_max_graph:uint;
	
	protected var colors:Colors = new Colors();
	
	/**
	 * <b>Stats</b> FPS, MS and MEM, all in one.
	 * @param p_draggable Can be draggable?
	 */
	
	public function Stats(p_draggable:Boolean = true):void {
		
		draggable = p_draggable;
		
		mem_max = 0;
		
		xml =  <xml>
				<fps>FPS:</fps>
				<ms>MS:</ms>
				<mem>MEM:</mem>
				<memMax>MAX:</memMax>
			</xml>;
		
		style = new StyleSheet();
		style.setStyle('xml', {fontSize: '9px', fontFamily: '_sans', leading: '-2px'});
		style.setStyle('fps', {color: hex2css(colors.fps)});
		style.setStyle('ms', {color: hex2css(colors.ms)});
		style.setStyle('mem', {color: hex2css(colors.mem)});
		style.setStyle('memMax', {color: hex2css(colors.memmax)});
		
		text = new TextField();
		text.width = WIDTH;
		text.height = 50;
		text.styleSheet = style;
		text.condenseWhite = true;
		text.selectable = false;
		text.mouseEnabled = false;
		
		rectangle = new Rectangle(WIDTH - 1, 0, 1, HEIGHT - 50);
		
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
	
	}
	
	private function init(e:Event):void {
		
		graphics.beginFill(colors.bg);
		graphics.drawRect(0, 0, WIDTH, HEIGHT);
		graphics.endFill();
		
		addChild(text);
		
		graph = new BitmapData(WIDTH, HEIGHT - 50, false, colors.bg);
		graphics.beginBitmapFill(graph, new Matrix(1, 0, 0, 1, 0, 50));
		graphics.drawRect(0, 50, WIDTH, HEIGHT - 50);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(Event.ENTER_FRAME, update);
	
	}
	
	protected function set draggable(value:Boolean):void {
		if (value)
			new DraggableStats(this);
	}
	
	private function destroy(e:Event):void {
		
		graphics.clear();
		
		while (numChildren > 0)
			removeChildAt(0);
		
		graph.dispose();
		
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(Event.ENTER_FRAME, update);
	
	}
	
	private function update(e:Event):void {
		
		timer = getTimer();
		
		var dTime:uint = timer - ms_prev;
		
		if (dTime >= 1000) {
			
			var missedPeriods:uint = (dTime - 1000) / 1000;
			
			fps = fps % 1000;
			
			ms_prev = timer;
			mem = Number((System.totalMemory * 0.000000954).toFixed(3));
			mem_max = mem_max > mem ? mem_max : mem;
			
			fps_graph = Math.min(graph.height, (fps / stage.frameRate) * graph.height);
			mem_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
			mem_max_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem_max * 5000))) - 2;
			
			graph.scroll(-(1 + missedPeriods), 0);
			
			if (missedPeriods) {
				graph.fillRect(new Rectangle(WIDTH - 1 - missedPeriods, 0, 1 + missedPeriods, HEIGHT - 50), colors.bg);
			} else {
				graph.fillRect(rectangle, colors.bg);
			}
			while (missedPeriods) {
				graph.setPixel(graph.width - 1 - missedPeriods, graph.height - 1, colors.fps);
				missedPeriods--;
			}
			graph.setPixel(graph.width - 1, graph.height - fps_graph, colors.fps);
			graph.setPixel(graph.width - 1, graph.height - ((timer - ms) >> 1), colors.ms);
			graph.setPixel(graph.width - 1, graph.height - mem_graph, colors.mem);
			graph.setPixel(graph.width - 1, graph.height - mem_max_graph, colors.memmax);
			
			xml.fps = "FPS: " + fps + " / " + stage.frameRate;
			xml.mem = "MEM: " + mem;
			xml.memMax = "MAX: " + mem_max;
			
			fps = 0;
			
		}
		
		fps++;
		
		xml.ms = "MS: " + (timer - ms);
		ms = timer;
		
		text.htmlText = xml;
	}
	
	private function onClick(e:MouseEvent):void {
		
		mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
		xml.fps = "FPS: " + fps + " / " + stage.frameRate;
		text.htmlText = xml;
	
	}
	
	// .. Utils
	
	private function hex2css(color:int):String {
		
		return "#" + color.toString(16);
	
	}

}

}
import utils.debug.Stats;

import flash.display.StageAlign;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

class Colors {
	
	public var bg:uint = 0x000033;
	public var fps:uint = 0xffff00;
	public var ms:uint = 0x00ff00;
	public var mem:uint = 0x00ffff;
	public var memmax:uint = 0xff0070;

}

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
	
	/**
	 * Align setter.
	 * @see flash.display.StageAlign
	 */
	public function set align(value:String):void {
		switch (value) {
			case StageAlign.TOP_LEFT: 
				target.x = 0;
				target.y = 0;
				break;
			
			case StageAlign.TOP_RIGHT: 
				target.x = target.stage.stageWidth - target.width;
				target.y = 0;
				break;
			
			case StageAlign.BOTTOM_LEFT: 
				target.x = 0;
				target.y = target.stage.stageHeight - target.height;
				break;
			
			case StageAlign.BOTTOM_RIGHT: 
				target.x = target.stage.stageWidth - target.width;
				target.y = target.stage.stageHeight - target.height;
				break;
		}
	}
	
	protected function addedToStageHandler(event:Event):void {
		/** Creating <code>Stage</code> listeners. **/
		target.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		target.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
		
		/** Creating target listener. **/
		target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		
		/** Creating the <code>ContextMenu</code>. **/
		var menu:ContextMenu = new ContextMenu;
		menu.hideBuiltInItems();
		menu.customItems.push(new ContextMenuItem("Align presets:", true, false));
		menu.customItems.push(new ContextMenuItem(StageAlign.TOP_LEFT));
		menu.customItems.push(new ContextMenuItem(StageAlign.TOP_RIGHT));
		menu.customItems.push(new ContextMenuItem(StageAlign.BOTTOM_LEFT));
		menu.customItems.push(new ContextMenuItem(StageAlign.BOTTOM_RIGHT));
		
		/** Watching for events. **/
		menu.customItems.forEach(function(p_item:ContextMenuItem, p_index:int, ... rest):void {
				if (p_index > 0)
					p_item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler);
			});
		
		target.contextMenu = menu;
		
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
	
	protected function menuItemSelectHandler(event:ContextMenuEvent):void {
		align = event.currentTarget["caption"];
	}

}