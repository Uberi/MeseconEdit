#NoEnv

class Draw
{
    static Subtool := 1
    static Nodes := Object("Mesecon",     Nodes.Mesecon
                          ,"Blinky Plant",Nodes.BlinkyPlant
                          ,"Power Plant", Nodes.PowerPlant
                          ,"Meselamp",    Nodes.Meselamp
                          ,"Plug",        Nodes.Plug
                          ,"Socket",      Nodes.Socket
                          ,"Inverter",    Nodes.Inverter)

    Select()
    {
        Subtools := ""
        For ToolName In this.Nodes
            SubTools .= "|" . ToolName
        GuiControl,, Subtools, %SubTools%
        GuiControl, Choose, Subtools, % this.SubTool
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
                GuiControlGet, NodeName,, Subtools

                Grid[MouseX,MouseY] := ""
                NodeClass := this.Nodes[NodeName]
                Grid[MouseX,MouseY] := new NodeClass(MouseX,MouseY)

                MouseX1 := MouseX, MouseY1 := MouseY
            }
            Sleep, 0
        }
    }
}