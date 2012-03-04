#NoEnv

class Mesecon
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        global hMemoryDC, Grid

        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hPen := DllCall("CreatePen","Int",5,"Int",0,"UInt",0,"UPtr") ;PS_NULL
            this.base.hOffBrush := DllCall("CreateSolidBrush","UInt",0x00AAAA,"UPtr")
            this.base.hOnBrush := DllCall("CreateSolidBrush","UInt",0x00FFFF,"UPtr")
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

        If this.State
        {
            OpenList := [], OpenList[IndexX,IndexY] := 1

            If Left.Conductive
                Left.ModifyState(this.State - Left.State,OpenList)
            If Right.Conductive
                Right.ModifyState(this.State - Right.State,OpenList)
            If Top.Conductive
                Top.ModifyState(this.State - Top.State,OpenList)
            If Bottom.Conductive
                Bottom.ModifyState(this.State - Bottom.State,OpenList)
        }
    }

    __Delete()
    {
        ;wip: use directional states

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
        If (OpenList = "")
            OpenList := []
        OpenList[this.IndexX,this.IndexY] := 1

        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        ;update neighbor nodes
        If Left.Conductive && !OpenList[Left.IndexX,Left.IndexY]
            Left.ModifyState(Amount,OpenList)
        If Right.Conductive && !OpenList[Right.IndexX,Right.IndexY]
            Right.ModifyState(Amount,OpenList)
        If Top.Conductive && !OpenList[Top.IndexX,Top.IndexY]
            Top.ModifyState(Amount,OpenList)
        If Bottom.Conductive && !OpenList[Bottom.IndexX,Bottom.IndexY]
            Bottom.ModifyState(Amount,OpenList)
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC, Grid
        hOriginalPen := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.base.hPen,"UPtr") ;select the pen
        hOriginalBrush := DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",this.State ? this.base.hOnBrush : this.base.hOffBrush,"UPtr") ;select the brush

        ;check for neighbors
        Left := Grid[this.IndexX - 1,this.IndexY].Conductive
        Right := Grid[this.IndexX + 1,this.IndexY].Conductive
        Top := Grid[this.IndexX,this.IndexY - 1].Conductive
        Bottom := Grid[this.IndexX,this.IndexY + 1].Conductive

        ;draw the mesecon
        If Left ;left neighbor
        {
            If Right ;left and right neighbor
                DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X),"Int",Round(Y + (H * 0.4)),"Int",Round(X + W),"Int",Round(Y + (H * 0.6)))
            Else ;left but not right neighbor
                DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X),"Int",Round(Y + (H * 0.4)),"Int",Round(X + (W * 0.6)),"Int",Round(Y + (H * 0.6)))
        }
        Else If Right ;right but not left neighbor
            DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X + (W * 0.4)),"Int",Round(Y + (H * 0.4)),"Int",Round(X + W),"Int",Round(Y + (H * 0.6)))
        Else If !(Top || Bottom) ;no neighbors
            DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X),"Int",Round(Y + (H * 0.4)),"Int",Round(X + W),"Int",Round(Y + (H * 0.6)))
        If Top
        {
            If Bottom
                DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X + (W * 0.4)),"Int",Round(Y),"Int",Round(X + (W * 0.6)),"Int",Round(Y + H))
            Else
                DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X + (W * 0.4)),"Int",Round(Y),"Int",Round(X + (W * 0.6)),"Int",Round(Y + (H * 0.6)))
        }
        Else If Bottom
            DllCall("Rectangle","UPtr",hMemoryDC,"Int",Round(X + (W * 0.4)),"Int",Round(Y + (H * 0.4)),"Int",Round(X + (W * 0.6)),"Int",Round(Y + H))

        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalPen,"UPtr") ;deselect the pen
        DllCall("SelectObject","UPtr",hMemoryDC,"UPtr",hOriginalBrush,"UPtr") ;deselect the brush
    }
}