codeunit 77101 "Install Agent"
{
    Subtype = Install;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    // This can be AppPerCompany, but we want to ensure that the agent is installed for all companies in the database, 
    //so we use AppPerDatabase.
    trigger OnInstallAppPerDatabase()
    var

    begin
        RegisterCapability();
        if not CustomAgentSetup.FindSet() then
            exit;
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2281481', Locked = true;
    begin
        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Purchase Order OverDue Agent") then
            CopilotCapability.RegisterCapability(
                Enum::"Copilot Capability"::"Purchase Order OverDue Agent",
                Enum::"Copilot Availability"::"Generally Available",
                "Copilot Billing Type"::"Microsoft Billed",
                LearnMoreUrlTxt);
    end;

    local procedure InstallAgentInstructions(var CustomAgentSetup: Record "PO Overdue Agent Setup")
    var
        Agent: Codeunit Agent;
        AgentSetup: Codeunit "custom Agent Setup";
    begin
        Agent.SetInstructions(CustomAgentSetup."User Security ID", AgentSetup.GetInstructions());
    end;

    procedure CreatePurchaseOrderOverdueAgent()
    var
        Agent: Codeunit Agent;
        AgentSetup: Codeunit "custom Agent Setup";

        TempAgentAccessControl: Record "Agent Access Control" temporary;
        AgentUserSecurityID: Guid;
        UserName: Code[50];
    begin
        UserName := 'Purchase_Order_OverDue_Agent';

        if CustomAgentSetup.FindFirst() then
            if not IsNullGuid(CustomAgentSetup."User Security ID") then begin
                Agent.SetInstructions(CustomAgentSetup."User Security ID", AgentSetup.GetInstructions());
                exit;
            end;

        TempAgentAccessControl.Init();
        TempAgentAccessControl."User Security ID" := UserSecurityId();
        TempAgentAccessControl."Can Configure Agent" := true;
        TempAgentAccessControl."Company Name" := CompanyName();
        //TempAgentAccessControl."Company Name" := 'Agents';
        TempAgentAccessControl.Insert();

        AgentUserSecurityID := Agent.Create(
            Enum::"Agent Metadata Provider"::"Purchase Order OverDue Agent",
            UserName,
            'Purchase Order OverDue Agent',
            TempAgentAccessControl);

        Agent.SetInstructions(AgentUserSecurityID, AgentSetup.GetInstructions());
        AssignAgentProfile(AgentUserSecurityID);

        CustomAgentSetup.DeleteAll();
        CustomAgentSetup.Init();
        CustomAgentSetup."User Security ID" := AgentUserSecurityID;
        CustomAgentSetup.Insert(true);
    end;

    local procedure AssignAgentProfile(AgentUserSecurityID: Guid)
    var
        Agent: Codeunit Agent;
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Profile ID", 'Purchase Order OverDue Agent');
        if not AllProfile.FindFirst() then
            exit;

        Agent.SetProfile(AgentUserSecurityID, AllProfile."Profile ID", AllProfile."App ID");
    end;

    var
        CustomAgentSetup: Record "PO Overdue Agent Setup";


}
