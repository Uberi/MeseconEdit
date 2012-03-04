#NoEnv

class Meselamp
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        global hMemoryDC, Grid

        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hPen := DllCall("CreatePen","Int",5,"Int",0,"UInt",0,"UPtr") ;PS_NULL
            this.base.hOffBrush := DllCall("CreateSolidBrush","UInt",0x227777,"UPtr")
            this.base.hOnBrush := DllCall("CreateSolidBrush","UInt",0xFFFFFF,"UPtr")
        }
        this.base.Count ++

        this.IndexX := IndexX, this.IndexY := IndexY
        this.Updated := 0
        this.Conductive := 1

        Left := Grid[IndexX - 1,IndexY]
        Right := Grid[IndexX + 1,IndexY]
        Top := Grid[IndexX,IndexY - 1]
        Bottom := Grid[IndexX,IndexY + 1]

        this.State := 0
        If Left.Conductive && Left.State
            this.State += Left.State
        If Right.Conductive && Right.State
            this.State += Right.State
        If Top.Conductive && Top.State
            this.State += Top.State
        If Bottom.Conductive && Bottom.State
            this.State += Bottom.State
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

    ModifyState(Amount,OpenList = "")
    {
        global Grid
        this.State += Amount
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC, Grid
        hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hPen,"UPtr") ;select the pen
        hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.State ? this.base.hOnBrush : this.base.hOffBrush,"UPtr") ;select the brush

        DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X + (W * 0.1)),"Int",Round(Y + (H * 0.3)),"Int",Round(X + (W * 0.9)),"Int",Round(Y + (H * 0.7)))

        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush
    }
}