#NoEnv

class Mesecon
{
    static Count := 0

    __New(IndexX,IndexY)
    {
        global hMemoryDC, Grid

        If this.base.Count = 0 ;first mesecon instance
        {
            this.base.hOffBrush := DllCall("CreateSolidBrush","UInt",0x008888,"UPtr")
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
        this.Recalculate()

        this.base.Count --
        If this.base.Count = 0 ;last mesecon instance
        {
            DllCall("DeleteObject","UPtr",this.base.hPen)
            DllCall("DeleteObject","UPtr",this.base.hOnBrush)
            DllCall("DeleteObject","UPtr",this.base.hOffBrush)
        }
    }

    Recalculate(OpenList = "")
    {
        global Grid
        If (OpenList = "")
            OpenList := []
        OpenList[this.IndexX,this.IndexY] := 1

        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        this.State := this.PowerSourceConnected()

        ;update neighbor nodes
        If Left.Conductive && !OpenList[Left.IndexX,Left.IndexY]
            Left.Recalculate(OpenList)
        If Right.Conductive && !OpenList[Right.IndexX,Right.IndexY]
            Right.Recalculate(OpenList)
        If Top.Conductive && !OpenList[Top.IndexX,Top.IndexY]
            Top.Recalculate(OpenList)
        If Bottom.Conductive && !OpenList[Bottom.IndexX,Bottom.IndexY]
            Bottom.Recalculate(OpenList)
    }

    PowerSourceConnected(OpenList = "")
    {
        global Grid
        If (OpenList = "")
            OpenList := []
        OpenList[this.IndexX,this.IndexY] := 1

        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        Result := 0
        If Left.Conductive && !OpenList[Left.IndexX,Left.IndexY]
            Result += Left.PowerSourceConnected(OpenList)
        If Right.Conductive && !OpenList[Right.IndexX,Right.IndexY]
            Result += Right.PowerSourceConnected(OpenList)
        If Top.Conductive && !OpenList[Top.IndexX,Top.IndexY]
            Result += Top.PowerSourceConnected(OpenList)
        If Bottom.Conductive && !OpenList[Bottom.IndexX,Bottom.IndexY]
            Result += Bottom.PowerSourceConnected(OpenList)
        Return, Result
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

        ;check for neighbors
        Left := Grid[this.IndexX - 1,this.IndexY].Conductive
        Right := Grid[this.IndexX + 1,this.IndexY].Conductive
        Top := Grid[this.IndexX,this.IndexY - 1].Conductive
        Bottom := Grid[this.IndexX,this.IndexY + 1].Conductive

        hBrush := this.State ? this.base.hOnBrush : this.base.hOffBrush

        VarSetCapacity(Rectangle,16)

        ;draw horizontal bar
        NumPut(Round(Y + (H * 0.4)),Rectangle,4,"Int")
        NumPut(Round(Y + (H * 0.6)),Rectangle,12,"Int")
        If Left ;left neighbor
        {
            NumPut(Round(X),Rectangle,0,"Int")
            If Right
                NumPut(Round(X + W),Rectangle,8,"Int")
            Else
                NumPut(Round(X + (W * 0.6)),Rectangle,8,"Int")
            DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
        }
        Else If Right ;right but not left neighbor
        {
            NumPut(Round(X + (W * 0.4)),Rectangle,0,"Int")
            NumPut(Round(X + W),Rectangle,8,"Int")
            DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
        }
        Else If !(Top || Bottom) ;no neighbors
        {
            NumPut(Round(X + (W * 0.4)),Rectangle,0,"Int")
            NumPut(Round(X + (W * 0.6)),Rectangle,8,"Int")
            DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
        }

        ;draw vertical bar
        NumPut(Round(X + (W * 0.4)),Rectangle,0,"Int")
        NumPut(Round(X + (W * 0.6)),Rectangle,8,"Int")
        If Top
        {
            NumPut(Round(Y),Rectangle,4,"Int")
            If Bottom
                NumPut(Round(Y + H),Rectangle,12,"Int")
            Else
                NumPut(Round(Y + (H * 0.6)),Rectangle,12,"Int")
            DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
        }
        Else If Bottom
        {
            NumPut(Round(Y + (H * 0.4)),Rectangle,12,"Int")
            NumPut(Round(Y + H),Rectangle,12,"Int")
            DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
        }
    }
}