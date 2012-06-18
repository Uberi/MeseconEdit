#NoEnv

class Remove
{
    static Subtool := 1

    Select()
    {
        GuiControl, Main:, Subtools, |Selection|Connected
        GuiControl, Main:Choose, Subtools, % this.Subtool
    }

    Activate(Grid)
    {
        global Width, Height
        MouseX1 := ~0, MouseY1 := ~0
        While, GetKeyState("LButton","P")
        {
            GetMouseCoordinates(Width,Height,MouseX,MouseY)
            If (MouseX != MouseX1 || MouseY != MouseY1)
            {
                If Grid.HasKey(MouseX) && Grid[MouseX].HasKey(MouseY)
                {
                    Grid[MouseX].Remove(MouseY,"")
                    If Grid[MouseX].MaxIndex() = ""
                        Grid.Remove(MouseX,"")
                }

                MouseX1 := MouseX, MouseY1 := MouseY
            }
            Sleep, 0
        }
    }
}