#NoEnv

#Include %A_ScriptDir%\Basis.ahk

class BlinkyPlant extends Power
{
    static hOffBrush := DllCall("CreateSolidBrush","UInt",0x0000BB,"UPtr")
    static hOnBrush := DllCall("CreateSolidBrush","UInt",0x0088FF,"UPtr")
    static BlinkyPlantArray := BlinkyPlant.SetBlinkyPlantTimer()

    SetBlinkyPlantTimer()
    {
        SetTimer, BlinkyPlantUpdate, 1000
        Return, []

        BlinkyPlantUpdate:
        Critical
        For pNode In BlinkyPlant.BlinkyPlantArray
        {
            Node := Object(pNode)
            Node.ModifyState(Node.State ? -1 : 1,[])
        }
        Return
    }

    __New(IndexX,IndexY)
    {
        global Grid
        this.State := 1
        base.__New(IndexX,IndexY)
        this.base.BlinkyPlantArray[&this] := ""
    }

    __Delete()
    {
        this.base.BlinkyPlantArray.Remove(&this,"")
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC
        hBrush := this.State ? this.base.hOnBrush : this.base.hOffBrush

        hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hPen,"UPtr") ;select the pen
        hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hBrush,"UPtr") ;select the brush

        ;draw the power plant
        DllCall("Ellipse","UPtr",hMemoryDC,"Int",Round(X + (W * 0.1)),"Int",Round(Y + (H * 0.1)),"Int",Round(X + (W * 0.9)),"Int",Round(Y + (H * 0.9)))

        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush
    }
}