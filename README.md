Advanced Hi-Res-Stats
========

Features
--------
	
 - fps counter.
 - current and max memory counters.
 - frame 'work' time (in ms) counter.
 - Graph of fps,frame time,memory counters.
 - increase/decrease width of Stats graph with mouse wheel.
 - Monitoring feature. (shows frame code execution time and frame render time.)
 - Minimize stats to compact mode. (graph is still drawn in background.)
 - can be dragged.
 - buttons to change fps count and toggle monitoring feature, and minimize.
 - Context menu


Screen-shots
----------

### Advanced Stats ###
![AdvancedStats.png](https://github.com/MindScriptAct/Advanced-hi-res-stats/raw/master/assets/AdvancedStats.png "Advanced Stats")
### Advanced Stats Context menu ###
![StatsContextMenu.jpg](https://github.com/MindScriptAct/Advanced-hi-res-stats/raw/master/assets/StatsContextMenu.jpg "Advanced Stats Context menu")

	
Monitoring feature
------------------

Monitoring feture is added to better understand how your application performes.

 * Yellow vertical line shows how much total time your frame has for code execution and rendering. If you go over this line your frame rate will drop.
 * Red graph will show how much time your running code takes.
 * Green graph will show how much time your application takes to render stage view, **AND** idle time if any.
 * If you have performance problems - check this graph. It will show how much and then your application is stessed out on executing code or rendering your view.
	
Usage
-----

Simplest:

	this.addChild(new Stats());

	
Make it bigger, smallest possible value is 70.(width):

	addChild(new Stats(150));
	
Change initial position (x, y):

	addChild(new Stats(150, 10, 20));
	
Make it minimized(isMinimized):

	addChild(new Stats(150, 10, 20, true));	
	
Make it not draggable(isDraggable):

	addChild(new Stats(150, 10, 20, false, false));		
	
Enable monitoring feature(isMonitoring):

	addChild(new Stats(150, 10, 20, false, true, true));
	
Scale it easily(scale):

	addChild(new Stats(150, 10, 20, false, true, true, 2));	
	
OR : 
	
	var stats:Stats = new Stats();
	this.addChild(stats);
	stats.width = 150;
	stats.x = 10;
	stats.y = 20;
	//stats.isMinimized = true;
	//stats.isDraggable = false;
	stats.isMonitoring = true;
	//stats.scale = 2;
	
	
Controls
--------

* **BUTTONS plus/minus**  - changes frame per second speed application is running.
* **BUTTON toggle monitoring**. - toggle monitoring feature(tracks execution and rendering time in ms)
* **BUTTON toggle mode** - switch between minimized and maximized modes.
* **Mouse wheel**. - increase/decrease width of Stats graph.
* **Drag** - drags if dragging is enabled.
* **RIGHT CLICK** opens context menu.



History
------
 * Fork of https://github.com/mrdoob/Hi-ReS-Stats
 * Merged with : https://github.com/rafaelrinaldi/Hi-ReS-Stats AND https://github.com/shamruk/Hi-ReS-Stats
