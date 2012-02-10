Improved stats
========

 * Fork of https://github.com/mrdoob/Hi-ReS-Stats
 * Merged with : https://github.com/rafaelrinaldi/Hi-ReS-Stats AND https://github.com/shamruk/Hi-ReS-Stats

Features
--------

`Stats` with:
	
 - fps counter.
 - current nad max memory counter.
 - frame 'work' time in ms counter.
 - Graph of fps,frame time,memory counters.
 - increase/decrease width of Stats graph with mouse wheel.
 - Monitoring feature. (shows frame code execution time and frame render time.)
 - Minimize stats to compact mode. (graph is still drawn in background.)
 - buttons to change fps count and toggle monitoring feature, and minimize.
 - Context menu.



Screenshot
----------

### Advanced Stats ###

![AdvancedStats.jpg](https://github.com/MindScriptAct/Hi-ReS-Stats/blob/master/assets/AdvancedStats.jpg?raw=true "Screenshot")
### Minimized Stats ###
![MinimizedStats.jpg](https://github.com/MindScriptAct/Hi-ReS-Stats/blob/master/assets/MinimizedStats.jpg?raw=true "Screenshot")
### Stats Context menu ###
![StatsContextMenu.jpg](https://github.com/MindScriptAct/Hi-ReS-Stats/blob/master/assets/StatsContextMenu.jpg?raw=true "Screenshot")

Usage
-----

Simplest:

	addChild(new Stats());
	
Make it bigger, smallest possible value is 70.(width):

	addChild(new Stats(150));	
	
Change initial position (x, y):

	addChild(new Stats(150, 10, 10));
	
Make it minimized(isMinimized):

	addChild(new Stats(150, 10, 10, true));	
	
Make it not draggable(isDraggable):

	addChild(new Stats(150, 10, 10, false, false));		
	
Enable monitoring feature(isMonitoring):

	addChild(new Stats(150, 10, 10, false, false, true));
	
Scale it easealy(scale):

	addChild(new Stats(150, 10, 10, false, false, true, 2));	
	
(You can send all parameters to constructor or set to Stats object.)
	

Controls
--------

* **BUTTONS plus/minus**  - changes frame per seccond speed application is runing.
* **BUTTON togle monitoring**. - taggle execution and rendering monitoring feature.
* **Mouse wheel**. - increase/decrease width of Stats graph.
* **Drag** - drags if dragging is enabled.
* **RIGHT CLICK** opens context menu.