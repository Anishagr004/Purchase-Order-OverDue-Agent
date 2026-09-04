codeunit 77106 "Trigger Agent Task"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        UserInput: Text;
        TaskID: biginteger;
    begin
        UserInput := 'Request to get list of OverDue Purchase Orders';
        ProcessRequestToAgentTasks(UserInput, TaskID);
    end;

    local procedure ProcessRequestToAgentTasks(
            var UserInput: Text; var TaskID: BigInteger)
    var
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        InboxID: biginteger;
    begin
        inboxID := Random(1000000);
        // ========================================================
        // Step 1: Create or add to agent task
        // ========================================================
        if not AgentTaskBuilder.TaskExists(
            userSecurityId(), inboxID.ToText())
        then
            CreateNewAgentTask(inboxID, UserInput, TaskID);

        Commit();
    end;
    /// <summary>
    /// Creates a new agent task
    /// </summary>
    local procedure CreateNewAgentTask(
        inboxID: biginteger; UserInput: Text; var TaskID: BigInteger)
    var
        AgentTaskRecord: Record "Agent Task";
        AgentTaskMessage: Record "Agent Task Message";
        AgentTaskBuilder: Codeunit "Agent Task Builder";
        AgentMessageBuilder: Codeunit "Agent Task Message Builder";
        MessageText: Text;
        TaskTitle: Text[150];
        User: record user;
        POOverdueSetup: Record "PO Overdue Agent Setup";
    begin
        User.Get(userSecurityId());
        POOverdueSetup.FindFirst();
        MessageText := StrSubstNo(
            UserInput
        );

        // Create a friendly task title
        TaskTitle := CopyStr(
            StrSubstNo(AgentTaskTitleLbl, User."Full Name"),
            1,
            MaxStrLen(AgentTaskRecord.Title)
        );

        // ====================================================================
        // Build the agent message
        // ====================================================================
        AgentMessageBuilder.Initialize(User."Authentication Email", MessageText)
            .SetMessageExternalID(inboxID.ToText())
            .SetRequiresReview(POOverdueSetup."Input Message Review")
            .SetIgnoreAttachment(POOverdueSetup."Analyse Attachment");

        // ====================================================================
        // Build and create the agent task
        // ====================================================================
        AgentTaskBuilder.Initialize(POOverdueSetup."User Security ID", TaskTitle)
            .SetExternalId(inboxID.ToText())
            .AddTaskMessage(AgentMessageBuilder);

        AgentTaskBuilder.Create();


        // Link the email to the created task
        AgentTaskMessage := AgentTaskBuilder.GetAgentTaskMessageCreated();
        TaskID := AgentTaskMessage."Task ID";
        // Link the email to the created task
        AgentTaskMessage := AgentTaskBuilder.GetAgentTaskMessageCreated();

    end;

    var
        // Label for the agent task title
        AgentTaskTitleLbl: Label 'Purchase Order OverDue Request from %1', Comment = '%1 = Sender Name';
        // Template for formatting the message content
        MessageTemplateLbl: Label '%1', Comment = '%1 = Message Content';

}