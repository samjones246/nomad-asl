state("NOMAD"){
    string255 scenePath: "UnityPlayer.dll", 0x1A058E0, 0x48, 0x10, 0x0;
    // God forgive me
    long playButtonClicked: "UnityPlayer.dll", 0x1A058E0, 0x48, 0xB0, 0x10, 0x30, 0x30, 0x48, 0x28, 0x30, 0x10, 0x30, 0x8, 0x70, 0x30, 0x30, 0x30, 0x38, 0x28, 0xE8, 0x28;
}

startup
{
    int[] levelManagerInidices = new int[] {1, 6, 13};
    vars.coreFixAmountWatchers = new MemoryWatcher<int>[3];
    for (int level = 0; level < 3; level++)
    {
        int levelManagerIndex = levelManagerInidices[level];
        int[] sceneHierachyOffsets = new int[levelManagerIndex];
        for (int i=0; i<levelManagerIndex; i++) {
            sceneHierachyOffsets[i] = 0x8;
        }
        int[] offsets = new List<int>() { 0x48, 0xB8 }
            .Concat(sceneHierachyOffsets)
            .Concat(new List<int>(){ 0x10, 0x30, 0x30, 0x18, 0x28, 0x7C })
            .ToArray();
        vars.coreFixAmountWatchers[level] = new MemoryWatcher<int>(
            new DeepPointer("UnityPlayer.dll", 0x1A058E0, offsets)
        );
    }
    vars.cfaWatcher = null;
}

update
{
    string[] pathParts = current.scenePath.Split('/');
    current.sceneName = pathParts[pathParts.Length - 1].Split('.')[0];
    if (current.sceneName != old.sceneName) {
        List<string> levelNames = new List<string>() {"Level1", "Level2", "Level3BackUp"};
        int currentLevel = levelNames.FindIndex((l) => current.sceneName == l);
        if (currentLevel != -1) {
            vars.cfaWatcher = vars.coreFixAmountWatchers[currentLevel];
        }
    }

    current.coreFixAmount = 0;
    if (vars.cfaWatcher != null) {
        vars.cfaWatcher.Update(game);
        current.coreFixAmount = vars.cfaWatcher.Current;
    }
}

start
{
    return current.sceneName == "MainMenuBackUp" && 
        current.playButtonClicked != 0L &&
        old.playButtonClicked == 0L;
}

split
{
    return current.coreFixAmount == 1 && old.coreFixAmount == 0;
}