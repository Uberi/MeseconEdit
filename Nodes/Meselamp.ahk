#NoEnv

class Meselamp
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

        this.IndexX := IndexX, this.IndexY := IndexY
        this.Conductive := 1

        this.Recalculate()
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

    Recalculate(OpenList = "")
    {
        global Grid

        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

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

    PowerSourceConnected(OpenList = "")
    {
        Return, 0
    }

    ModifyState(Amount,OpenList = "")
    {
        this.State += Amount
    }

    Draw(X,Y,W,H)
    {
        global hMemoryDC, Grid
        hBrush := this.State ? this.base.hOnBrush : this.base.hOffBrush ;select the brush

        VarSetCapacity(Rectangle,16)

        NumPut(Round(X + (W * 0.1)),Rectangle,0,"Int")
        NumPut(Round(Y + (H * 0.3)),Rectangle,4,"Int")
        NumPut(Round(X + (W * 0.9)),Rectangle,8,"Int")
        NumPut(Round(Y + (H * 0.7)),Rectangle,12,"Int")
        DllCall("FillRect","UPtr",hMemoryDC,"UPtr",&Rectangle,"UPtr",hBrush)
    }
}