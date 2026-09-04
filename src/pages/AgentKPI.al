// ============================================================================
// Purchase Order Overdue Agent - KPI Page
// ============================================================================
// This page displays KPI metrics for the Purchase Order Overdue Agent.
// It shows received emails, sent replies, time saved, and other stats.
// ============================================================================

namespace Demo.Agent.PurchaseOrderOverdue;

using System.Agents;

page 77102 "PO Overdue KPI"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "PO Overdue KPI";
    Caption = 'Purchase Order Overdue Agent';
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            cuegroup(Summary)
            {
                ShowCaption = false;

                field(ReceivedEmails; Rec."Received Request")
                {
                    ApplicationArea = All;
                    Caption = 'Received emails';
                    ToolTip = 'Specifies the total number of emails that the agent has received.';

                    trigger OnDrillDown()
                    begin
                        // 
                    end;
                }
                field(RepliesSent; Rec."Total Replies Sent")
                {
                    ApplicationArea = All;
                    Caption = 'Replies sent';
                    ToolTip = 'Specifies the total number of email replies that the agent has sent.';

                    trigger OnDrillDown()
                    begin
                        //
                    end;
                }
                field(TasksCreated; Rec."Total Tasks Created")
                {
                    ApplicationArea = All;
                    Caption = 'Tasks created';
                    ToolTip = 'Specifies the total number of agent tasks that have been created from emails.';
                }
                field(PendingTasks; Rec."Pending Tasks")
                {
                    ApplicationArea = All;
                    Caption = 'Pending tasks';
                    ToolTip = 'Specifies the number of agent tasks that are still pending review.';
                }
                field(TimeSavedEmailsHour; TimeSavedEmails)
                {
                    ApplicationArea = All;
                    Caption = 'Time saved on emails';
                    AutoFormatType = 11;
                    AutoFormatExpression = EmailTimeAutoFormatExpression;
                    ToolTip = 'Specifies the total time saved by the agent on emails. The time saved is calculated based on the assumption that the agent saves 3 minutes per email.';
                }
                field(TimeSavedRepliesMin; TimeSavedReplies)
                {
                    ApplicationArea = All;
                    Caption = 'Time saved on replies';
                    AutoFormatType = 11;
                    AutoFormatExpression = ReplyTimeAutoFormatExpression;
                    ToolTip = 'Specifies the total time saved by the agent on replies. The time saved is calculated based on the assumption that the agent saves 5 minutes per reply.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSafe();
        VerifyUserHasAccessToAgent();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateTotals();
    end;

    local procedure CalculateTotals()
    begin
        VerifyUserHasAccessToAgent();
        Rec.UpdateKPIs(Rec."User Security ID");
        TimeSavedEmails := GetTimeSavedEmails(EmailTimeAutoFormatExpression);
        TimeSavedReplies := GetTimeSavedReplies(ReplyTimeAutoFormatExpression);
    end;

    local procedure VerifyUserHasAccessToAgent()
    var
        POOverdueSetup: Record "PO Overdue Agent Setup";
    begin
        // Verify user has access to the agent via setup
        if not IsNullGuid(Rec."User Security ID") then begin
            POOverdueSetup.SetRange("User Security ID", Rec."User Security ID");
            if POOverdueSetup.IsEmpty() then
                exit;
        end;
    end;

    local procedure GetTimeSavedEmails(var ControlAutoFormatExpression: Text): Decimal
    begin
        // Estimate: 3 minutes saved per email processed
        exit(ConvertDurationToText(Rec."Received Request" * 3, ControlAutoFormatExpression));
    end;

    local procedure GetTimeSavedReplies(var ControlAutoFormatExpression: Text): Decimal
    begin
        // Estimate: 5 minutes saved per reply sent
        exit(ConvertDurationToText(Rec."Total Replies Sent" * 5, ControlAutoFormatExpression));
    end;

    local procedure ConvertDurationToText(MinutesSaved: Integer; var ControlAutoFormatExpression: Text): Decimal
    var
        HoursSaved: Decimal;
        DaysSaved: Decimal;
        YearsSaved: Decimal;
    begin
        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, MinutesUnitLbl);

        if MinutesSaved < 60 then
            exit(MinutesSaved);

        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, HoursUnitLbl);

        // Under 100 hours we track with 0.1 increment, over 100 hours we track with 0.5 increment.
        if MinutesSaved < 6000 then
            HoursSaved := Round(MinutesSaved / 60, 0.1)
        else
            HoursSaved := Round(MinutesSaved / 60, 0.5);

        if HoursSaved < 1000 then
            exit(HoursSaved);

        // Under 100 days we track with 0.1 increment, over 100 days we report full days.
        DaysSaved := Round(HoursSaved / 24, 0.1);
        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, DaysUnitLbl);

        if DaysSaved < 100 then
            exit(DaysSaved)
        else
            DaysSaved := Round(DaysSaved, 1);

        if DaysSaved < 1000 then
            exit(DaysSaved);

        // Years are always reported with 0.01 increment.
        YearsSaved := Round(DaysSaved / 365, 0.01);
        ControlAutoFormatExpression := StrSubstNo(AutoFormatExpressionLbl, YearsUnitLbl);
        exit(YearsSaved);
    end;

    var
        TimeSavedEmails: Decimal;
        TimeSavedReplies: Decimal;
        EmailTimeAutoFormatExpression: Text;
        ReplyTimeAutoFormatExpression: Text;
        AutoFormatExpressionLbl: Label '<Precision,0:1><Standard Format,0> %1', Locked = true, Comment = '%1 - is the unit hr or min';
        HoursUnitLbl: Label 'h', Comment = 'h represents hours, it will be shown like 23.7 h', MaxLength = 3;
        DaysUnitLbl: Label 'd', Comment = 'd represents days, it will be shown like 23.6 d', MaxLength = 3;
        YearsUnitLbl: Label 'yr', Comment = 'yr represents years, it will be shown like 3.6 yr', MaxLength = 3;
        MinutesUnitLbl: Label 'min', Comment = 'min represents minutes, it will be shown like 23 min', MaxLength = 3;
}
