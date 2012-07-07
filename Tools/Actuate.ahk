#NoEnv

class Actuate
{
    Select()
    {
        Return, ["Punch","Walk Over"]
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