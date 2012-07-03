#NoEnv

class Actuate
{
    static Subtool := 1

    Select()
    {
        GuiControl, Main:, Subtools, |Punch|Walk Over
        GuiControl, Main:Choose, Subtools, % this.SubTool
    }

    Activate(Grid)
    {
        global Width, Height
        GetMouseCoordinates(Width,Height,MouseX,MouseY)
        Cell := Grid[MouseX,MouseY]

        GuiControlGet, Action, Main:, Subtools
        If (Action = "Punch")
            Cell.Punch()
        Else If (Action = "Walk Over")
            Cell.WalkOver()
    }
}