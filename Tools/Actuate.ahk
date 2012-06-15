#NoEnv

class Actuate
{
    static Subtool := 1

    Select()
    {
        GuiControl,, Subtools, |Hit|Walk Over
        GuiControl, Choose, Subtools, % this.SubTool
    }

    Activate(Grid)
    {
        global Width, Height
        GetMouseCoordinates(Width,Height,MouseX,MouseY)
        Cell := Grid[MouseX,MouseY]

        GuiControlGet, Action,, Subtools
        If (Action = "Hit")
            Cell.Punch()
        Else If (Action = "Walk Over")
            Cell.WalkOver()
    }
}