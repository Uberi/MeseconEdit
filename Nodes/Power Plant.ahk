#NoEnv

class PowerPlant extends Nodes.Power
{
    static hPen := DllCall("GetStockObject","Int",8,"UPtr") ;NULL_PEN
    static hBrush := DllCall("CreateSolidBrush","UInt",0x00FFFF,"UPtr")

    __New(IndexX,IndexY)
    {
        this.State := 1
        base.__New(IndexX,IndexY)
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC
        hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hPen,"UPtr") ;select the pen
        hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hBrush,"UPtr") ;select the brush

        ;draw the power plant
        DllCall("Ellipse","UPtr",hMemoryDC,"Int",Round(X + (W * 0.1)),"Int",Round(Y + (H * 0.1)),"Int",Round(X + (W * 0.9)),"Int",Round(Y + (H * 0.9)))

        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush
    }
}