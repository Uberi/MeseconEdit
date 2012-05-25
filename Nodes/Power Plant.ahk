#NoEnv

class PowerPlant extends Power
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hPen := DllCall("CreatePen","Int",5,"Int",0,"UInt",0,"UPtr") ;PS_NULL
            this.base.hBrush := DllCall("CreateSolidBrush","UInt",0x00FFFF,"UPtr")
        }
        this.base.Count ++

        this.State := 1
        base.__New(IndexX,IndexY)
    }

    __Delete()
    {
        base.__Delete()

        this.base.Count --
        If this.base.Count = 0 ;last mesecon instance
        {
            DllCall("DeleteObject","UPtr",this.base.hPen)
            DllCall("DeleteObject","UPtr",this.base.hOnBrush)
            DllCall("DeleteObject","UPtr",this.base.hOffBrush)
        }
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