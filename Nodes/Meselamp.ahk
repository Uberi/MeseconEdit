#NoEnv

class Meselamp extends Load
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hOffBrush := DllCall("CreateSolidBrush","UInt",0x777777,"UPtr")
            this.base.hOnBrush := DllCall("CreateSolidBrush","UInt",0xFFFFFF,"UPtr")
        }
        this.base.Count ++

        base.__New(IndexX,IndexY)
    }

    __Delete()
    {
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
        hBrush := this.State ? this.base.hOnBrush : this.base.hOffBrush ;select the brush

        VarSetCapacity(Rectangle,16)

        ;draw rectangle
        NumPut(Round(X + (W * 0.1)),Rectangle,0,"Int")
        NumPut(Round(Y + (H * 0.3)),Rectangle,4,"Int")
        NumPut(Round(X + (W * 0.9)),Rectangle,8,"Int")
        NumPut(Round(Y + (H * 0.7)),Rectangle,12,"Int")
        DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
    }
}