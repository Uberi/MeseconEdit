#NoEnv

class PowerPlant
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        global hMemoryDC, Grid

        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hPen := DllCall("CreatePen","Int",5,"Int",0,"UInt",0,"UPtr") ;PS_NULL
            this.base.hBrush := DllCall("CreateSolidBrush","UInt",0x00FFFF,"UPtr")
        }
        this.base.Count ++

        this.IndexX := IndexX, this.IndexY := IndexY
        this.Conductive := 1
        this.State := 1

        Left := Grid[IndexX - 1,IndexY]
        Right := Grid[IndexX + 1,IndexY]
        Top := Grid[IndexX,IndexY - 1]
        Bottom := Grid[IndexX,IndexY + 1]

        OpenList := [], OpenList[IndexX,IndexY] := 1
        If Left.Conductive
            Left.ModifyState(1,OpenList)
        If Right.Conductive
            Right.ModifyState(1,OpenList)
        If Top.Conductive
            Top.ModifyState(1,OpenList)
        If Bottom.Conductive
            Bottom.ModifyState(1,OpenList)
    }

    __Delete()
    {
        global Grid
        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        OpenList := [], OpenList[this.IndexX,this.IndexY] := 1
        If Left.Conductive
            Left.ModifyState(-1,OpenList)
        OpenList := [], OpenList[this.IndexX,this.IndexY] := 1
        If Right.Conductive
            Right.ModifyState(-1,OpenList)
        OpenList := [], OpenList[this.IndexX,this.IndexY] := 1
        If Top.Conductive
            Top.ModifyState(-1,OpenList)
        OpenList := [], OpenList[this.IndexX,this.IndexY] := 1
        If Bottom.Conductive
            Bottom.ModifyState(-1,OpenList)

        this.base.Count --
        If this.base.Count = 0 ;last mesecon instance
        {
            DllCall("DeleteObject","UPtr",this.base.hPen)
            DllCall("DeleteObject","UPtr",this.base.hOnBrush)
            DllCall("DeleteObject","UPtr",this.base.hOffBrush)
        }
    }

    PowerSourceConnected()
    {
        Return, 1
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