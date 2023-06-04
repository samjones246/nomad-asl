# nomad-asl
LiveSplit autosplitter for [Nomad](https://store.steampowered.com/app/2382600/Nomad/).

## Features
 - Auto start on Play clicked.
 - Auto split on core repair.

## Technical Information
For auto split functionality, the target property is `LevelSwitch.coreFixAmount`. This is initialized to 0 at the start of a level and increases to 1 the moment the player finishes repairing the core, which is the moment when the split should be triggered. An instance of `LevelSwitch` is attached to a `GameObject` named `LevelManager` in each of the three level scenes. Sadly, this object is in a different position in the hierachy for each scene, so three seperate pointer paths were needed. To save on some code repetition and to avoid wasting resources reading nonsense values when the relevant scene for a given path is not loaded, the ASL constructs memory watchers for these paths in the `init` block, and switches the active watcher based on the current scene name. Here are the rough semantics of the path used:
```
    SceneManager
    0x48 | .ActiveScene
    0xB8 | .FirstRootGameObject
    0x8  | .Next (Repeated x times where, x is the index of LevelManager GO in the scene)
    0x10 | .transform
    0x30 | .gameObject
    0x30 | .Components
    0x18 | [1] : *LevelSwitch
    0x28 | .cppInstance : LevelSwitch
    0x7C | .coreFixAmount
```

Time starts on pressing the Play button on the main menu. This button click invokes a method which launches a couple of coroutines, and ultimately doesn't make any convenient state changes. So, rather than some value used by the game which indicates that a new game has been started, I opted to leverage the properties of the `Button` class itself to detect that the button has been clicked. The `Button` class has a property named `OnClick`, of type `ButtonClickedEvent`. This in turn has a property named `m_InvokedArray`, of type `object[]`. Before the button has ever been clicked, this value is null (`0x00`), but updates to a valid pointer the moment the button is clicked. So, I detect a click when this value changes from 0 to any other value. Once again, here are the path semantics:
```
    SceneManager
    0x48 | .ActiveScene
    0xB0 | .LastRootGameObject
    0x10 | .transform
    0x30 | .gameObject (MainCanvas)
    0x30 | .Components
    0x48 | [4] : *MainMenuManager
    0x28 | .cppInstance
    0x30 | .controlPanel : *GameObject
    0x10 | .cppInstance : GameObject
    0x30 | .Components
    0x8  | [0] : Transform
    0x70 | .Children
    0x30 | [6] : Transform (PlayButton)
    0x30 | .gameObject
    0x30 | .Components
    0x38 | [3] : *Button
    0x28 | .cppInstance : Button3
    0xE8 | .OnClick : ButtonClickedEvent
    0x28 | .m_InvokeArray : object[]
```