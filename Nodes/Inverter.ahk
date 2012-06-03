#NoEnv

class Inverter extends Power
{
    static hPen := DllCall("GetStockObject","Int",8,"UPtr") ;NULL_PEN
    static hBrush := DllCall("CreateSolidBrush","UInt",0x55AAFF,"UPtr")

    __New(IndexX,IndexY)
    {
        global Grid
        this.State := 1
        For Index, Cell In [Grid[IndexX - 2,IndexY]
                           ,Grid[IndexX + 2,IndexY]
                           ,Grid[IndexX,IndexY - 2]
                           ,Grid[IndexX,IndexY + 2]]
        { ;wip: check for blank node between plug and socket/inverter
            If Cell.__Class = "Plug" && Cell.State
            {
                this.State := 0
                Break
            }
        }

        base.__New(IndexX,IndexY)
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC

        hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hPen,"UPtr") ;select the pen
        hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hBrush,"UPtr") ;select the brush

        Vertices := 3
        VarSetCapacity(Points,8 * Vertices)

        ;draw left arrow
        NumPut(Round(X),Points,0,"Int"), NumPut(Round(Y + (H * 0.3)),Points,4,"Int")
        NumPut(Round(X),Points,8,"Int"), NumPut(Round(Y + (H * 0.7)),Points,12,"Int")
        NumPut(Round(X + (W * 0.3)),Points,16,"Int"), NumPut(Round(Y + (H * 0.5)),Points,20,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        ;draw right arrow
        NumPut(Round(X + W),Points,0,"Int")
        NumPut(Round(X + W),Points,8,"Int")
        NumPut(Round(X + (W * 0.7)),Points,16,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        ;draw top arrow
        NumPut(Round(X + (W * 0.3)),Points,0,"Int"), NumPut(Round(Y),Points,4,"Int")
        NumPut(Round(X + (W * 0.7)),Points,8,"Int"), NumPut(Round(Y),Points,12,"Int")
        NumPut(Round(X + (W * 0.5)),Points,16,"Int"), NumPut(Round(Y + (H * 0.3)),Points,20,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        ;draw bottom arrow
        NumPut(Round(Y + H),Points,4,"Int")
        NumPut(Round(Y + H),Points,12,"Int")
        NumPut(Round(Y + (H * 0.7)),Points,20,"Int")
        DllCall("Polygon","UPtr",hMemoryDC,"UPtr",&Points,"Int",Vertices)

        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush
    }
}