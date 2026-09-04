codeunit 77103 "Agent Factory" implements IAgentFactory
{
    Access = Internal;

    procedure GetDefaultInitials(): Text[4]
    begin
        exit(AgentSetup.GetInitials());
    end;

    procedure GetFirstTimeSetupPageId(): Integer
    begin
        exit(AgentSetup.GetSetupPageId());
    end;

    procedure ShowCanCreateAgent(): Boolean
    begin
        exit(true);
    end;

    procedure GetCopilotCapability(): Enum "Copilot Capability"
    begin
        exit(Enum::"Copilot Capability"::"Purchase Order OverDue Agent");
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        AgentSetup.GetDefaultProfile(TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    begin
        AgentSetup.GetDefaultAccessControls(TempAccessControlBuffer);
    end;

    var
        AgentSetup: Codeunit "Custom Agent Setup";
}
