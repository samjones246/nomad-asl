state("Nomad"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Nomad";
    vars.Helper.LoadSceneManager = true;
}