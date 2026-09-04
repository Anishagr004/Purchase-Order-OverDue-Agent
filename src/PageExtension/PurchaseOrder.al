pageextension 77101 "Purchase Order" extends "Purchase Order List"
{
    layout
    {
        // Add changes to page layout here
        addafter("Document Date")
        {
            field("Expected Receipt Date"; Rec."Expected Receipt Date")
            {
                ApplicationArea = All;
                editable = false;
                ToolTip = 'Specifies the date by which the purchase order should be received.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}