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


Screenshot
----------

### Advanced Stats ###
![AdvancedStats.jpg](https://github.com/MindScriptAct/Advanced-hi-res-stats/raw/master/assets/AdvancedStats.jpg "Advanced Stats")
### Minimized Advanced Stats ###
![MinimizedStats.jpg](https://github.com/MindScriptAct/Advanced-hi-res-stats/raw/master/assets/MinimizedStats.jpg "Minimized Advanced Stats")
### Advanced Stats Context menu ###
![StatsContextMenu.jpg](https://github.com/MindScriptAct/Advanced-hi-res-stats/raw/master/assets/StatsContextMenu.jpg "Advanced Stats Context menu")

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
	
Scale it easealy(scale):

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

* **BUTTONS plus/minus**  - changes frame per seccond speed application is runing.
* **BUTTON togle monitoring**. - taggle execution and rendering monitoring feature.
* **Mouse wheel**. - increase/decrease width of Stats graph.
* **Drag** - drags if dragging is enabled.
* **RIGHT CLICK** opens context menu.



History
------
 * Fork of https://github.com/mrdoob/Hi-ReS-Stats
 * Merged with : https://github.com/rafaelrinaldi/Hi-ReS-Stats AND https://github.com/shamruk/Hi-ReS-Stats

