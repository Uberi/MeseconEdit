#NoEnv

;wip: multiple simultaneous viewports with independent views
;wip: undo/redo
;wip: component count in status bar - nodes used in selection, in total
;wip: rectangular selection and selection filling/moving/copying/pasting
;wip: file saving/loading and new nodes

/*
Copyright 2012 Anthony Zhang <azhang9@gmail.com>

This file is part of MeseconEdit. Source code is available at <https://github.com/Uberi/MeseconEdit>.

MeseconEdit is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#Warn All
#Warn LocalSameAsGlobal, Off

Width := 800
Height := 600

Tools := []
Tools.Insert(Object("Name","&Draw",   "Class",ToolActions.Draw))
Tools.Insert(Object("Name","&Remove", "Class",ToolActions.Remove))
Tools.Insert(Object("Name","&Select", "Class",ToolActions.Select))
Tools.Insert(Object("Name","&Actuate","Class",ToolActions.Actuate))

Gui, Add, Text, vDisplay gDisplayClick hwndhControl

Grid := []
Viewport := Object("X",-14.5,"Y",-14.5,"W",30,"H",30)
InitializeViewport(hControl,Width,Height)

For Index, Tool In Tools
    Gui, Add, Radio, vTool%Index% gSelectTool, % Tool.Name
GuiControl,, Tool1, 1

Gui, Add, ListBox, vSubtools
CurrentTool := Tools[1]
CurrentTool.Class.Select()

;wip: add options

Gui, +Resize +MinSize400x320
Gui, Show, w800 h600, MeseconEdit

Gosub, Draw
SetTimer, Draw, 50
Return

class ToolActions
{
    class Draw
    {
        static Subtool := 1
        static Nodes := Object("Mesecon",     Mesecon
                              ,"Blinky Plant",BlinkyPlant
                              ,"Power Plant", PowerPlant
                              ,"Meselamp",    Meselamp
                              ,"Plug",        Plug
                              ,"Socket",      Socket
                              ,"Inverter",    Inverter)

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

    class Remove
    {
        static Subtool := 1

        Select()
        {
            GuiControl,, Subtools, |Selection|Connected
            GuiControl, Choose, Subtools, % this.Subtool
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

    class Select
    {
        static Subtool := 1

        Select()
        {
            GuiControl,, Subtools, |Area|Extend|Connected
            GuiControl, Choose, Subtools, % this.SubTool
        }

        Activate(Grid) ;wip
        {
            global hMemoryDC, Width, Height, Viewport
            static hPen := DllCall("CreatePen","Int",0,"Int",2,"UInt",0x0000FF,"UPtr") ;PS_SOLID
            static hBrush := DllCall("GetStockObject","Int",5,"UPtr") ;NULL_BRUSH
            VarSetCapacity(Rectangle,16)

            IndexX := Floor(Viewport.X), IndexY := Floor(Viewport.Y)
            BlockW := Width / Viewport.W, BlockH := Height / Viewport.H
            BlockX := Mod(-Viewport.X,1) * BlockW
            If BlockX > 0
                BlockX -= BlockW
            BlockY := Mod(-Viewport.Y,1) * BlockH
            If BlockY > 0
                BlockY -= BlockH

            GetMouseCoordinates(Width,Height,StartX,StartY)
            X := BlockX + (BlockW * (StartX - IndexX))
            Y := BlockY + (BlockH * (StartY - IndexY))

            MouseX1 := ~0, MouseY1 := ~0
            While, GetKeyState("LButton","P")
            {
                GetMouseCoordinates(Width,Height,MouseX,MouseY)
                ;If (MouseX != MouseX1 || MouseY != MouseY1) ;wip
                ;{
                    W := BlockW * ((MouseX + 1) - StartX)
                    H := BlockH * ((MouseY + 1) - StartY)

                    hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hPen,"UPtr") ;select the pen
                    hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hBrush,"UPtr") ;select the brush

                    ;draw rectangle
                    DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X),"Int",Round(Y),"Int",Round(X + W),"Int",Round(Y + H))
                    global hDC
                    If !DllCall("BitBlt","UPtr",hDC,"Int",0,"Int",0,"Int",Width,"Int",Height,"UPtr",hMemoryDC,"Int",0,"Int",0,"UInt",0xCC0020) ;SRCCOPY
                        throw Exception("Could not transfer pixel data to window device context.")

                    DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
                    DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush

                    MouseX1 := MouseX, MouseY1 := MouseY
                ;}
                Sleep, 1
            }
        }
    }

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
}

GuiClose:
SetTimer, Draw, Off
UninitializeViewport(hControl)
ExitApp

GuiSize:
Critical
If A_EventInfo = 1 ;window minimised
    Return

Width := A_GuiWidth - 110, Height := A_GuiHeight - 20
GuiControl, Move, Display, x10 y10 w%Width% h%Height%
SizeWindow(Width,Height)
Viewport.Y += Viewport.H / 2
Viewport.H := (Height / Width) * Viewport.W
Viewport.Y -= Viewport.H / 2

Temp1 := 10
For Index In Tools
    GuiControl, Move, Tool%Index%, % "x" . (A_GuiWidth - 90) . " y" . Temp1 . " w80 h20", Temp1 += 20

Temp1 += 20
GuiControl, Move, Subtools, % "x" . (A_GuiWidth - 90) . " y" . Temp1 . " w80 h200"

Sleep, 10
Return

SelectTool:
;store the index of the previously selected subtool
Gui, +LastFound
SendMessage, 0x188, 0, 0, ListBox1 ;LB_GETCURSEL
CurrentTool.Class.Subtool := ErrorLevel + 1

;select the current tool
CurrentTool := Tools[SubStr(A_GuiControl,5)]
CurrentTool.Class.Select()
Return

Draw:
Draw(Grid,Width,Height,Viewport)
Return

#IfWinActive MeseconEdit ahk_class AutoHotkeyGUI

~RButton::
CoordMode, Mouse, Client
MouseGetPos, OffsetX, OffsetY
ViewportX1 := Viewport.X, ViewportY1 := Viewport.Y
While, GetKeyState("RButton","P")
{
    MouseGetPos, MouseX, MouseY
    PositionX := MouseX - OffsetX
    PositionY := MouseY - OffsetY
    Viewport.X := ViewportX1 - ((PositionX / Width) * Viewport.W)
    Viewport.Y := ViewportY1 - ((PositionY / Height) * Viewport.H)

    ;obtain the position of the viewport
    GuiControlGet, TempPosition, Pos, Display
    If (MouseX < TempPositionX) ;mouse past left edge of viewport
    {
        OffsetX += TempPositionW
        MouseMove, TempPositionX + TempPositionW, MouseY, 0
    }
    Else If (MouseX > TempPositionX + TempPositionW) ;mouse past right edge of viewport
    {
        OffsetX -= TempPositionW
        MouseMove, TempPositionX, MouseY, 0
    }
    If (MouseY < TempPositionY) ;mouse past top edge of viewport
    {
        OffsetY += TempPositionH
        MouseMove, MouseX, TempPositionY + TempPositionH, 0
    }
    Else If (MouseY > TempPositionY + TempPositionH) ;mouse past bottom edge of viewport
    {
        OffsetY -= TempPositionH
        MouseMove, MouseX, TempPositionY, 0
    }

    Sleep, 50
}
Return

Space::
While, GetKeyState("Space","P")
{
    GetMouseCoordinates(Width,Height,MouseX,MouseY)
    Node := Grid[MouseX][MouseY]
    If Node
        ToolTip % "Type: " . Node.__Class . "`nState: " . Node.State
    Else
        ToolTip
    Sleep, 100
}
Return

DisplayClick:
Gui, Submit, NoHide
For Index, Tool In Tools
{
    If Tool%Index%
    {
        Tool.Class.Activate(Grid)
        Break
    }
}
Return

~PGUP::
~WheelUp::
If Viewport.W > 2
{
    Viewport.X += Viewport.W * 0.1, Viewport.Y += Viewport.H * 0.1
    Viewport.W *= 0.8, Viewport.H *= 0.8
}
Return

~PGDN::
~WheelDown::
If Viewport.W < 80
{
    Viewport.X -= Viewport.W * 0.1, Viewport.Y -= Viewport.H * 0.1
    Viewport.W *= 1.2, Viewport.H *= 1.2
}
Return

Serialize(Grid)
{
    Result := ""
    For IndexX, Column In Grid
    {
        For IndexY, Node In Column
            Result .= IndexX . "`t" . IndexY . "`t" . Node.__Class . "`t" . Node.Serialize() . "`n"
    }
    Return, Result
}

Deserialize(Value)
{
    local Grid, Field0
    Grid := []
    StringReplace, Value, Value, `r,, All
    Value := Trim(Value,"`n")
    Loop, Parse, Value, `n
    {
        StringSplit, Field, A_LoopField, %A_Tab% ;wip: serialized data cannot contain tabs or newlines
        Grid[Field1,Field2] := new %Field3%(Field1,Field2)
    }
    Return, Grid
}

GetMouseCoordinates(Width,Height,ByRef MouseX,ByRef MouseY)
{
    global Viewport
    ;obtain the mouse position
    CoordMode, Mouse, Client
    MouseGetPos, MouseX, MouseY

    ;obtain the viewport position
    GuiControlGet, Offset, Pos, Display

    ;calculate the cell the mouse in in
    MouseX -= OffsetX, MouseY -= OffsetY
    MouseX := Floor(Viewport.X + ((MouseX / Width) * Viewport.W))
    MouseY := Floor(Viewport.Y + ((MouseY / Height) * Viewport.H))
}

InitializeViewport(hWindow,Width,Height)
{
    global hDC, hMemoryDC, hOriginalBitmap
    hDC := DllCall("GetDC","UPtr",hWindow)
    If !hDC
        throw Exception("Could not obtain window device context.")
    hMemoryDC := DllCall("CreateCompatibleDC","UPtr",hDC)
    If !hMemoryDC
        throw Exception("Could not obtain window device context.")

    hOriginalBitmap := 0

    SizeWindow(Width,Height)
}

UninitializeViewport(hWindow)
{
    global hDC, hMemoryDC, hBitmap
    If hBitmap && !DllCall("DeleteObject","UPtr",hBitmap) ;delete the bitmap
        throw Exception("Could not delete bitmap.")
    If !DllCall("DeleteObject","UPtr",hMemoryDC) ;delete the memory device context
        throw Exception("Could not delete memory device context.")
    If !DllCall("ReleaseDC","UPtr",hWindow,"UPtr",hDC) ;release the window device context
        throw Exception("Could not release window device context.")
}

Draw(Grid,Width,Height,Viewport)
{
    global hDC, hMemoryDC
    static hPen := DllCall("CreatePen","Int",0,"Int",0,"UInt",0x888888,"UPtr") ;PS_SOLID

    ;clear the bitmap
    If !DllCall("BitBlt","UPtr",hMemoryDC,"Int",0,"Int",0,"Int",Width,"Int",Height,"UPtr",hMemoryDC,"Int",0,"Int",0,"UInt",0x42) ;BLACKNESS
        throw Exception("Could not transfer pixel data to window device context.")

    ;determine the dimensions of each cell
    BlockW := Width / Viewport.W, BlockH := Height / Viewport.H
    IndexX := Floor(Viewport.X), IndexY := Floor(Viewport.Y)

    ;determine the horizontal position of the first cell
    BlockX := Mod(-Viewport.X,1) * BlockW
    If BlockX > 0
        BlockX -= BlockW

    ;determine the vertical position of the first cell
    BlockY := Mod(-Viewport.Y,1) * BlockH
    If BlockY > 0
        BlockY -= BlockH

    ;draw grid lines
    IndexX1 := IndexX, BlockX1 := BlockX
    hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hPen,"UPtr") ;select the pen
    Loop, % Ceil(Viewport.W)
    {
        BlockX1 += BlockW
        DllCall("MoveToEx","UPtr",hMemoryDC,"Int",BlockX1,"Int",0,"UPtr",0)
        DllCall("LineTo","UPtr",hMemoryDC,"Int",BlockX1,"Int",Height)
    }
    IndexY1 := IndexY, BlockY1 := BlockY
    Loop, % Ceil(Viewport.H)
    {
        BlockY1 += BlockH
        DllCall("MoveToEx","UPtr",hMemoryDC,"Int",0,"Int",BlockY1,"UPtr",0)
        DllCall("LineTo","UPtr",hMemoryDC,"Int",Width,"Int",BlockY1)
    }
    DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen

    ;draw cells
    Loop, % Ceil(Viewport.W) + 1
    {
        IndexY1 := IndexY, BlockY1 := BlockY
        Loop, % Ceil(Viewport.H) + 1
        {
            If Grid[IndexX,IndexY1]
                Grid[IndexX,IndexY1].Draw(BlockX,BlockY1,BlockW,BlockH)
            IndexY1 ++, BlockY1 += BlockH
        }
        IndexX ++, BlockX += BlockW
    }

    ;transfer pixel data to window device context
    If !DllCall("BitBlt","UPtr",hDC,"Int",0,"Int",0,"Int",Width,"Int",Height,"UPtr",hMemoryDC,"Int",0,"Int",0,"UInt",0xCC0020) ;SRCCOPY
        throw Exception("Could not transfer pixel data to window device context.")
}

SizeWindow(Width,Height)
{
    global hDC, hMemoryDC, hOriginalBitmap, hBitmap
    If hOriginalBitmap
    {
        If !DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBitmap,"UPtr") ;deselect the bitmap
            throw Exception("Could not select original bitmap into memory device context.")
    }
    hBitmap := DllCall("CreateCompatibleBitmap","UPtr",hDC,"Int",Width,"Int",Height,"UPtr") ;create a new bitmap
    If !hBitmap
        throw Exception("Could not create bitmap.")
    hOriginalBitmap := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hBitmap,"UPtr")
    If !hOriginalBitmap
        throw Exception("Could not select bitmap into memory device context.")
}

#Include %A_ScriptDir%\Nodes\Basis.ahk
#Include %A_ScriptDir%\Nodes\Mesecon.ahk
#Include %A_ScriptDir%\Nodes\Power Plant.ahk
#Include %A_ScriptDir%\Nodes\Blinky Plant.ahk
#Include %A_ScriptDir%\Nodes\Meselamp.ahk
#Include %A_ScriptDir%\Nodes\Plug.ahk
#Include %A_ScriptDir%\Nodes\Socket.ahk
#Include %A_ScriptDir%\Nodes\Inverter.ahk