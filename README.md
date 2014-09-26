[![Stories in Ready](https://badge.waffle.io/Rad-Star/RadEngine.png?label=ready&title=Ready)](https://waffle.io/Rad-Star/RadEngine)
RadEngine
=========

A Haxe game engine based on ash entity system.

##Purpose
Using the power of Entity System to make game rapidly with the editor.
More tweaking, less compilation time.

##Install
```
git clone git@github.com:Rad-Star/RadEngine.git
cd RadEngine 
haxelib dev radengine .
```

##Use
RadEngine use OpenFL, so you first need to create an OpenFL project.
Then, in your project.xml, remove every haxelib and add 
```
<haxelib name="radengine" />
```

Then you'll need System and Components for your entitys.
You can create your own, but I recommand you to first use the SimpleBundle.
A Bundle is a set of System and Components specialised in a particular task, such as Rendering or Physics. 
Bundles can be considered as sub engine.

#How to use a bundle
You can use a bundle just as you would use a haxelib. Actually they are haxelib so all you need to do is cloning the bundle and set it as a dev haxelib with command line like so :
```
git clone git@github.com:Rad-Star/SimpleBundle.git 
cd SimpleBundle
haxelib dev simplebundle .
```

Then add it in your game's project.xml : 
```
<haxelib name="simplebundle" />
```

You're now ready to use the basic Components and systems.

##Debug mode
RadEngine use a lot the "#if debug" preprocessor.
In debug build, you should have access to the editor by pressing ctrl + alt + D.
The game is now in edit mode.
In edit mode, you can create scene and entity, or edit an existing scene, and save.

Here is a list of the available command in edit mode :

  - edit bool : if bool is true, enters the edit mode, otherwise, leaves the edit mode
  - save : saves the current scene.
  - load name : loads the scene named "name".
  - createScene name : creates a new scene named "name".
  - create name : creates an entity named "name" and select it.
  - add comp : adds the component of class "comp" to the selected entity.
  - addSystem sys : adds the system of class "sys" to the scene.
  - stop, pause, resume : "stop" will reload the scene. Any unsaved change are lost. "pause" pauses the game for easy editing. "resume" , resumes.
  - select name : selects the entity named "name". If the entity is visible, you can just click it to select it.
  - editComp class field value : edits the "class" comp of the select entity and sets "field" value to "value".
