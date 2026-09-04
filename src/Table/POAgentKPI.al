// ============================================================================
// Purchase Order Overdue Agent - KPI Table
// ============================================================================
// This table stores KPI metrics for the Purchase Order Overdue Agent.
// It tracks received emails, sent replies, and time saved estimates.
// ============================================================================

namespace Demo.Agent.PurchaseOrderOverdue;

using System.Agents;

table 77102 "PO Overdue KPI"
{
    Caption = 'Purchase Order Overdue Agent KPI';
    DataClassification = CustomerContent;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    Permissions = tabledata "PO Overdue Agent Setup" = r,
                  tabledata "Agent Task" = r,
                  tabledata "Agent Task Message" = r;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            ToolTip = 'Specifies the primary key. This value should be a blank code as the table is a singleton table.';
        }
        field(2; "Received Request"; Integer)
        {
            Caption = 'Received Request';
            ToolTip = 'Specifies the total number of Request that the agent has received.';
        }
        field(3; "Total Request"; Integer)
        {
            Caption = 'Total Request';
            ToolTip = 'Specifies the total number of Request that the agent has received or created.';
        }
        field(4; "Total Replies Sent"; Integer)
        {
            Caption = 'Replies Sent';
            ToolTip = 'Specifies the total number of email replies that the agent has sent.';
        }
        field(5; "Total Tasks Created"; Integer)
        {
            Caption = 'Tasks Created';
            ToolTip = 'Specifies the total number of agent tasks that have been created from emails.';
        }
        field(6; "Pending Tasks"; Integer)
        {
            Caption = 'Pending Tasks';
            ToolTip = 'Specifies the number of agent tasks that are still pending review.';
        }
        field(20; "Last Updated DateTime"; DateTime)
        {
            Caption = 'Updated at';
            ToolTip = 'Specifies the date and time when the KPI was last updated.';
        }
        field(5000; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the security identifier (SID) of the agent for whom the KPIs are tracked.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the KPI record safely, creating it if it doesn't exist
    /// </summary>
    internal procedure GetSafe()
    var
        UserSecurityIDFilter: Text;
    begin
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Rec.Get() then
            Rec.Insert();

        if IsNullGuid(Rec."User Security ID") then begin
            UserSecurityIDFilter := Rec.GetFilter("User Security ID");
            if Evaluate(Rec."User Security ID", UserSecurityIDFilter) then
                Rec.Modify(false);
        end;
    end;

    /// <summary>
    /// Updates all KPI metrics for the agent
    /// </summary>
    internal procedure UpdateKPIs(AgentSecurityID: Guid)
    begin
        UpdateKPIs(AgentSecurityID, true);
    end;

    /// <summary>
    /// Updates all KPI metrics for the agent with optional refresh interval check
    /// </summary>
    internal procedure UpdateKPIs(AgentSecurityID: Guid; UseRefreshInterval: Boolean)
    var
        POOverdueSetup: Record "PO Overdue Agent Setup";
        AgentTask: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        BlankUpdatedDateTime: DateTime;
    begin
        if IsNullGuid(AgentSecurityID) then
            exit;

        POOverdueSetup.SetRange("User Security ID", AgentSecurityID);
        if POOverdueSetup.IsEmpty() then
            exit;

        Clear(BlankUpdatedDateTime);
        Rec.GetSafe();

        // Check refresh interval to avoid unnecessary recalculations
        if UseRefreshInterval then
            if Rec."Last Updated DateTime" <> BlankUpdatedDateTime then
                if CurrentDateTime() - Rec."Last Updated DateTime" < RefreshKPIsInterval() then
                    exit;

        // Count received Request

        // Count sent replies

        // Count agent tasks and messages
        AgentTask.ReadIsolation := IsolationLevel::ReadCommitted;
        AgentTask.SetRange("Agent User Security ID", AgentSecurityID);
        Rec."Total Tasks Created" := AgentTask.Count();

        // Count total Request (input messages from agent tasks)
        Rec."Total Request" := 0;
        Rec."Pending Tasks" := 0;
        AgentTaskMessage.ReadIsolation := IsolationLevel::ReadCommitted;
        if AgentTask.FindSet() then
            repeat
                AgentTaskMessage.SetRange("Task ID", AgentTask.ID);
                AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Input);
                Rec."Total Request" += AgentTaskMessage.Count;

                // Count pending tasks (not completed)
                if AgentTask.Status in [AgentTask.Status::Paused, AgentTask.Status::Ready] then
                    Rec."Pending Tasks" += 1;
            until AgentTask.Next() = 0;

        Rec."Last Updated DateTime" := CurrentDateTime();
        Rec.Modify();
    end;

    local procedure RefreshKPIsInterval(): Integer
    begin
        if not Rec.Get() then
            exit(1000); // 1 second

        if Rec."Total Request" < 78 then
            exit(1000); // 1 second

        if Rec."Total Request" < 100 then
            exit(60000); // 1 minute

        exit(300000); // 5 minutes
    end;
}
