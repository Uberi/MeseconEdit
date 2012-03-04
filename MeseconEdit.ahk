#NoEnv

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

;wip: use a directional power source count - count the number of power sources for each side of each mesecon, so that removing one on one side simply decrements by that amount on the relevant side
;wip: file saving/loading and new nodes

#Warn All
#Warn LocalSameAsGlobal, Off

Width := 800
Height := 600

Gui, Add, Text, vDisplay gDisplayClick hwndhControl

Grid := []
Viewport := Object("X",-14.5,"Y",-14.5,"W",30,"H",30)
InitializeViewport(hControl,Width,Height)

Gui, Add, Radio, vToolMesecon Checked, &Mesecon
Gui, Add, Radio, vToolEmpty, &Empty
Gui, Add, Radio, vToolPowerPlant, &PowerPlant
Gui, Add, Radio, vToolMeselamp, Mese&lamp

Gui, +Resize +MinSize300x200
Gui, Show, w800 h600, MeseconEdit

Gosub, Draw
SetTimer, Draw, 50
Return

GuiClose:
SetTimer, Draw, Off
UninitializeViewport(hControl)
ExitApp

GuiSize:
Critical
Width := A_GuiWidth - 20, Height := A_GuiHeight - 50
GuiControl, Move, Display, x10 y10 w%Width% h%Height%
SizeWindow(Width,Height)
Viewport.Y += Viewport.H / 2
Viewport.H := (Height / Width) * Viewport.W
Viewport.Y -= Viewport.H / 2

GuiControl, Move, ToolMesecon, % "x10 y" . A_GuiHeight - 30 . " w100 h20"
GuiControl, Move, ToolEmpty, % "x110 y" . A_GuiHeight - 30 . " w100 h20"
GuiControl, Move, ToolPowerPlant, % "x210 y" . A_GuiHeight - 30 . " w100 h20"
GuiControl, Move, ToolMeselamp, % "x310 y" . A_GuiHeight - 30 . " w100 h20"

Sleep, 10
Return

Draw:
Draw(Width,Height,Viewport)
Return

#IfWinActive MeseconEdit ahk_class AutoHotkeyGUI

~RButton::
MouseGetPos, OffsetX, OffsetY
PositionX := Viewport.X, PositionY := Viewport.Y
While, GetKeyState("RButton","P")
{
    MouseGetPos, MouseX, MouseY
    MouseX -= OffsetX, MouseY -= OffsetY
    Viewport.X := PositionX - ((MouseX / Width) * Viewport.W)
    Viewport.Y := PositionY - ((MouseY / Height) * Viewport.H)
    Sleep, 50
}
Return

DisplayClick:
MouseX1 := ~0, MouseY1 := ~0
While, GetKeyState("LButton","P")
{
    GetMouseCoordinates(Width,Height,MouseX,MouseY)
    If (MouseX != MouseX1 || MouseY != MouseY1)
    {
        Gui, Submit, NoHide
        If ToolMesecon
            Grid[MouseX,MouseY] := new Mesecon(MouseX,MouseY)
        Else If ToolEmpty
        {
            Grid[MouseX].Remove(MouseY,"")
            If ObjMaxIndex(Grid[MouseX]) = ""
                Grid.Remove(MouseX,"")
        }
        Else If ToolPowerPlant
            Grid[MouseX,MouseY] := new PowerPlant(MouseX,MouseY)
        Else If ToolMeselamp
            Grid[MouseX,MouseY] := new Meselamp(MouseX,MouseY)
        MouseX1 := MouseX, MouseY1 := MouseY
    }
    Sleep, 50
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

GetMouseCoordinates(Width,Height,ByRef MouseX,ByRef MouseY)
{
    global hControl, Viewport
    CoordMode, Mouse, Relative
    MouseGetPos, MouseX, MouseY
    ControlGetPos, OffsetX, OffsetY,,,, ahk_id %hControl%
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

Draw(Width,Height,Viewport)
{
    global hDC, hMemoryDC, Grid
    static hPen := DllCall("CreatePen","Int",0,"Int",0,"UInt",0x888888,"UPtr") ;PS_SOLID

    ;clear the bitmap
    If !DllCall("BitBlt","UPtr",hMemoryDC,"Int",0,"Int",0,"Int",Width,"Int",Height,"UPtr",hMemoryDC,"Int",0,"Int",0,"UInt",0x42) ;BLACKNESS
        throw Exception("Could not transfer pixel data to window device context.")

    BlockW := Width / Viewport.W, BlockH := Height / Viewport.H
    IndexX := Floor(Viewport.X), IndexY := Floor(Viewport.Y)

    BlockX := Mod(-Viewport.X,1) * BlockW
    If BlockX > 0
        BlockX -= BlockW

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

#Include %A_ScriptDir%\Mesecon.ahk
#Include %A_ScriptDir%\Power Plant.ahk
#Include %A_ScriptDir%\Meselamp.ahk