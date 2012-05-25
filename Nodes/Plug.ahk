#NoEnv

class Plug extends Load
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        global Grid

        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hPen := DllCall("CreatePen","Int",5,"Int",0,"UInt",0,"UPtr") ;PS_NULL
            this.base.hBrush := DllCall("CreateSolidBrush","UInt",0x3333AA,"UPtr")
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

    ModifyState(Amount,OpenList = "")
    {
        global Grid
        base.ModifyState(Amount,OpenList)
        If this.State ;plug on
        {
            For Index, Cell In [Grid[this.IndexX - 2,this.IndexY]
                               ,Grid[this.IndexX + 2,this.IndexY]
                               ,Grid[this.IndexX,this.IndexY - 2]
                               ,Grid[this.IndexX,this.IndexY + 2]]
            {
                If Cell.__Class = "Socket" && !Cell.State
                    Cell.ModifyState(1,OpenList)
                If Cell.__Class = "Inverter" && Cell.State
                    Cell.ModifyState(-1,OpenList)
            }
        }
        Else ;plug off
        {
            For Index, Cell In [Grid[this.IndexX - 2,this.IndexY]
                               ,Grid[this.IndexX + 2,this.IndexY]
                               ,Grid[this.IndexX,this.IndexY - 2]
                               ,Grid[this.IndexX,this.IndexY + 2]]
            {
                If Cell.__Class = "Socket" && Cell.State
                    Cell.ModifyState(-1,OpenList)
                If Cell.__Class = "Inverter" && !Cell.State
                    Cell.ModifyState(1,OpenList)
            }
        }
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC, Grid
        hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hPen,"UPtr") ;select the pen
        hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hBrush,"UPtr") ;select the brush

        Vertices := 3
        VarSetCapacity(Points,8 * Vertices)

        ;draw left arrow
        NumPut(Round(X),Points,0,"Int"), NumPut(Round(Y + (H * 0.5)),Points,4,"Int")
        NumPut(Round(X + (W * 0.3)),Points,8,"Int"), NumPut(Round(Y + (H * 0.3)),Points,12,"Int")
        NumPut(Round(X + (W * 0.3)),Points,16,"Int"), NumPut(Round(Y + (H * 0.7)),Points,20,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        ;draw right arrow
        NumPut(Round(X + W),Points,0,"Int")
        NumPut(Round(X + (W * 0.7)),Points,8,"Int")
        NumPut(Round(X + (W * 0.7)),Points,16,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        ;draw top arrow
        NumPut(Round(X + (W * 0.5)),Points,0,"Int"), NumPut(Round(Y),Points,4,"Int")
        NumPut(Round(X + (W * 0.3)),Points,8,"Int"), NumPut(Round(Y + (H * 0.3)),Points,12,"Int")
        NumPut(Round(X + (W * 0.7)),Points,16,"Int"), NumPut(Round(Y + (H * 0.3)),Points,20,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        ;draw bottom arrow
        NumPut(Round(Y + H),Points,4,"Int")
        NumPut(Round(Y + (H * 0.7)),Points,12,"Int")
        NumPut(Round(Y + (H * 0.7)),Points,20,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush
    }
}