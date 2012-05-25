#NoEnv

class Socket extends Power
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        global Grid

        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hPen := DllCall("CreatePen","Int",5,"Int",0,"UInt",0,"UPtr") ;PS_NULL
            this.base.hBrush := DllCall("CreateSolidBrush","UInt",0xAAAAAA,"UPtr")
        }
        this.base.Count ++

        this.State := 0
        For Index, Cell In [Grid[IndexX - 2,IndexY]
                           ,Grid[IndexX + 2,IndexY]
                           ,Grid[IndexX,IndexY - 2]
                           ,Grid[IndexX,IndexY + 2]]
        { ;wip: check for blank node between plug and socket/inverter
            If Cell.__Class = "Plug" && Cell.State
            {
                this.State := 1
                Break
            }
        }

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

    ModifyState(Amount,OpenList)
    {
        global Grid
        this.State += Amount
        OpenList[this.IndexX,this.IndexY] := 1

        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        ;update neighbor nodes
        If Left.Receive && !OpenList[Left.IndexX,Left.IndexY]
            Left.ModifyState(Amount,OpenList)
        If Right.Receive && !OpenList[Right.IndexX,Right.IndexY]
            Right.ModifyState(Amount,OpenList)
        If Top.Receive && !OpenList[Top.IndexX,Top.IndexY]
            Top.ModifyState(Amount,OpenList)
        If Bottom.Receive && !OpenList[Bottom.IndexX,Bottom.IndexY]
            Bottom.ModifyState(Amount,OpenList)
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