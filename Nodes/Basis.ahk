class Power
{
    __New(IndexX,IndexY)
    {
        global Grid

        this.IndexX := IndexX, this.IndexY := IndexY
        this.Send := 1
        this.Receive := 0

        ;obtain neighbor nodes
        Left := Grid[IndexX - 1,IndexY]
        Right := Grid[IndexX + 1,IndexY]
        Top := Grid[IndexX,IndexY - 1]
        Bottom := Grid[IndexX,IndexY + 1]

        ;propagate current state to neighbors
        If Left.Receive
            Left.ModifyState(this.State,[])
        If Right.Receive
            Right.ModifyState(this.State,[])
        If Top.Receive
            Top.ModifyState(this.State,[])
        If Bottom.Receive
            Bottom.ModifyState(this.State,[])
    }

    __Delete()
    {
        global Grid
        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        ;propagate removal of current state to neighbors
        If Left.Receive
            Left.ModifyState(-this.State,[])
        If Right.Receive
            Right.ModifyState(-this.State,[])
        If Top.Receive
            Top.ModifyState(-this.State,[])
        If Bottom.Receive
            Bottom.ModifyState(-this.State,[])
    }

    ModifyState(Amount,OpenList)
    {
        global Grid
        this.State += Amount
        OpenList[this.IndexX,this.IndexY] := 1

        ;obtain neighbor nodes
        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        ;propagate current state to neighbors
        If Left.Receive && !OpenList[Left.IndexX,Left.IndexY]
            Left.ModifyState(Amount,OpenList)
        If Right.Receive && !OpenList[Right.IndexX,Right.IndexY]
            Right.ModifyState(Amount,OpenList)
        If Top.Receive && !OpenList[Top.IndexX,Top.IndexY]
            Top.ModifyState(Amount,OpenList)
        If Bottom.Receive && !OpenList[Bottom.IndexX,Bottom.IndexY]
            Bottom.ModifyState(Amount,OpenList)
    }

    PowerSourceConnected()
    {
        Return, this.State
    }

    Draw(X,Y,W,H)
    {
        
    }
}

class Load
{
    __New(IndexX,IndexY)
    {
        this.IndexX := IndexX, this.IndexY := IndexY
        this.Send := 0
        this.Receive := 1

        this.Recalculate([])
    }

    Recalculate(OpenList)
    {
        global Grid
        OpenList[this.IndexX,this.IndexY] := 1

        ;obtain neighbor nodes
        Left := Grid[this.IndexX - 1,this.IndexY]
        Right := Grid[this.IndexX + 1,this.IndexY]
        Top := Grid[this.IndexX,this.IndexY - 1]
        Bottom := Grid[this.IndexX,this.IndexY + 1]

        ;obtain total state from neighbors
        this.State := 0
        If Left.Send && Left.State && !OpenList[Left.IndexX,Left.IndexY]
            this.State += Left.State
        If Right.Send && Right.State && !OpenList[Right.IndexX,Right.IndexY]
            this.State += Right.State
        If Top.Send && Top.State && !OpenList[Top.IndexX,Top.IndexY]
            this.State += Top.State
        If Bottom.Send && Bottom.State && !OpenList[Bottom.IndexX,Bottom.IndexY]
            this.State += Bottom.State
    }

    PowerSourceConnected(OpenList)
    {
        Return, 0
    }

    ModifyState(Amount,OpenList)
    {
        this.State += Amount
    }
}