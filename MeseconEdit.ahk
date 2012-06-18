#NoEnv

;wip: add license
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

CurrentFile := ""

Tools := []
Tools.Insert(Object("Name","&Draw",   "Class",ToolActions.Draw))
Tools.Insert(Object("Name","&Remove", "Class",ToolActions.Remove))
Tools.Insert(Object("Name","&Select", "Class",ToolActions.Select))
Tools.Insert(Object("Name","&Actuate","Class",ToolActions.Actuate))

Menu, FileMenu, Add, &New, FileNew
Menu, FileMenu, Add, &Open, FileOpen
Menu, FileMenu, Add, &Save, FileSave
Menu, FileMenu, Add, Save &As, FileSaveAs
Menu, FileMenu, Add, E&xit, MainGuiClose

;Menu, OptionsMenu, Add, &Simulation, ShowSimulationOptions

Menu, HelpMenu, Add, &Manual, ShowHelp
Menu, HelpMenu, Add, &About, ShowAbout

Menu, MenuBar, Add, &File, :FileMenu
;Menu, MenuBar, Add, &Options, :OptionsMenu
Menu, MenuBar, Add, &Help, :HelpMenu
Gui, Main:Menu, MenuBar

Gui, Main:Add, Text, vDisplay gDisplayClick hwndhControl

InitializeViewport(hControl,Width,Height)

For Index, Tool In Tools
    Gui, Main:Add, Radio, w80 h20 vTool%Index% gSelectTool, % Tool.Name
GuiControl, Main:, Tool1, 1

Gui, Main:Add, ListBox, w80 h200 vSubtools

Gui, Main:+Resize +MinSize400x320
Gui, Main:Show, w800 h600 Hide

Gosub, FileNew

CurrentTool := Tools[1]
CurrentTool.Class.Select()

Gosub, Draw
SetTimer, Draw, 50
Return

class ToolActions
{
    #Include Tools\Draw.ahk
    #Include Tools\Remove.ahk
    #Include Tools\Select.ahk
    #Include Tools\Actuate.ahk
}

class Nodes
{
    #Include %A_ScriptDir%\Nodes\Basis.ahk
    #Include %A_ScriptDir%\Nodes\Mesecon.ahk
    #Include %A_ScriptDir%\Nodes\Power Plant.ahk
    #Include %A_ScriptDir%\Nodes\Blinky Plant.ahk
    #Include %A_ScriptDir%\Nodes\Meselamp.ahk
    #Include %A_ScriptDir%\Nodes\Plug.ahk
    #Include %A_ScriptDir%\Nodes\Socket.ahk
    #Include %A_ScriptDir%\Nodes\Inverter.ahk
}

ShowHelp:
;wip: open manual here
Return

ShowAbout:
Gui, Main:+Disabled
Gui, About:+OwnerMain +ToolWindow
Gui, About:Font, s48, Arial
Gui, About:Add, Text, x10 y10 w400 h70, MeseconEdit
Gui, About:Font, s8 Bold
Gui, About:Add, Text, x10 y80 w200 h20, v1.0 Stable
Gui, About:Font, Norm
Gui, About:Add, Text, x210 y80 w200 h20 Right, Copyright Anthony Zhang 2012
Gui, About:Font, s12
Gui, About:Add, Link, x10 y110 w400 h20, Licensed under the <a href="http://www.gnu.org/licenses/">GNU Affero General Public License</a>.
Gui, About:Show, w420 h140
Return

AboutGuiEscape:
AboutGuiClose:
Gui, About:Destroy
Gui, Main:-Disabled
Gui, Main:Show
Return

MainGuiClose:
SetTimer, Draw, Off
UninitializeViewport(hControl)
ExitApp

MainGuiSize:
Critical
If A_EventInfo = 1 ;window minimised
    Return
ResizeWindow(A_GuiWidth,A_GuiHeight)
Sleep, 10
Return

SelectTool:
;store the index of the previously selected subtool
Gui, Main:+LastFound
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
    GuiControlGet, TempPosition, Main:Pos, Display
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

FileNew:
Grid := []
Viewport := Object("X",-14.5,"Y",-14.5,"W",30,"H",30)
Gui, Main:Show,, MeseconEdit - Untitled
Gui, Main:+LastFound
WinGetPos,,, Width, Height ;wip: get client area
ResizeWindow(Width,Height)
Return

FileOpen:
FileSelectFile, FileName, 35,, Open mesecon schematic, Mesecon Schematic (*.mesecon)
If ErrorLevel
    Return
FileRead, Value, %FileName%
If ErrorLevel
{
    MsgBox, 16, Error, Could not read file "%FileName%".
    Return
}
;wip: ask to save current file if modified
Grid := Deserialize(Value)
Return

FileSave:
If (CurrentFile = "")
{
    Gosub, FileSaveAs
    Return
}
FileDelete, %CurrentFile%
FileAppend, % Serialize(Grid), %CurrentFile%
If ErrorLevel
{
    Gui, Main:+OwnDialogs
    MsgBox, 16, Error, Could not save file as "%CurrentFile%".
}
Return

FileSaveAs:
FileSelectFile, FileName, S48,, Save mesecon schematic, Mesecon Schematic (*.mesecon)
If ErrorLevel
    Return
CurrentFile := FileName
Gosub, FileSave
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
Gui, Main:Submit, NoHide
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
    Return, SubStr(Result,1,-1)
}

Deserialize(Value)
{
    global
    local NodeClasses, Grid, Position, IndexX, IndexY, NodeName, Data, NodeClass

    ;create a mapping of node class names to node classes
    NodeClasses := Object()
    For Name, Node In Nodes
    {
        If IsObject(Node)
            NodeClasses[Node.__Class] := Node
    }

    Grid := []
    StringReplace, Value, Value, `r,, All
    Value := Trim(Value,"`n")
    Loop, Parse, Value, `n
    {
        ;wip: serialized data cannot contain newlines
        Data := A_LoopField

        Position := InStr(Data,"`t")
        IndexX := SubStr(Data,1,Position - 1)
        Data := SubStr(Data,Position + 1)

        Position := InStr(Data,"`t")
        IndexY := SubStr(Data,1,Position - 1)
        Data := SubStr(Data,Position + 1)

        Position := InStr(Data,"`t")
        NodeName := SubStr(Data,1,Position - 1)
        Data := SubStr(Data,Position + 1)

        If !NodeClasses.HasKey(NodeName)
            throw Exception("Unknown node class: " . NodeName . ".")
        NodeClass := NodeClasses[NodeName]
        Grid[IndexX,IndexY] := new NodeClass(IndexX,IndexY)
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
    GuiControlGet, Offset, Main:Pos, Display

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

    ResizeViewport(Width,Height)
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

ResizeWindow(Width,Height)
{
    global Viewport, Tools
    ViewportWidth := Width - 110, ViewportHeight := Height - 20
    GuiControl, Main:Move, Display, x10 y10 w%ViewportWidth% h%ViewportHeight%
    ResizeViewport(ViewportWidth,ViewportHeight)
    Viewport.Y += Viewport.H / 2
    Viewport.H := (Height / Width) * Viewport.W
    Viewport.Y -= Viewport.H / 2

    Temp1 := 10
    For Index In Tools
        GuiControl, Main:Move, Tool%Index%, % "x" . (Width - 90) . " y" . Temp1, Temp1 += 20

    Temp1 += 20
    GuiControl, Main:Move, Subtools, % "x" . (Width - 90) . " y" . Temp1
}

ResizeViewport(Width,Height)
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