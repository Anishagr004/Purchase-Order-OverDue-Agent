codeunit 77102 "Agent Metadata" implements IAgentMetadata
{
    Access = Internal;

    procedure GetDisplayName(): Text[80]
    begin
        exit(AgentSetup.GetDisplayName());
    end;

    procedure GetInitials(AgentUserId: Guid): Text[4]
    begin
        exit(AgentSetup.GetInitials());
    end;

    procedure GetSetupPageId(AgentUserId: Guid): Integer
    begin
        exit(AgentSetup.GetSetupPageId());
    end;

    procedure GetSummaryPageId(AgentUserId: Guid): Integer
    begin
        exit(AgentSetup.GetSummaryPageId());
    end;

    procedure GetAgentTaskMessagePageId(AgentUserId: Guid): Integer
    begin
        exit(Page::"Agent Task Message Card");
    end;

    procedure GetAgentAnnotations(AgentUserId: Guid; var Annotations: Record "Agent Annotation")
    begin
        Clear(Annotations);
    end;

    procedure GetAgentTaskMessagePageId(AgentUserId: Guid; MessageId: Guid): Integer
    begin
        exit(Page::"Agent Task Message Card");
    end;

    var
        AgentSetup: Codeunit "Custom Agent Setup";
}
