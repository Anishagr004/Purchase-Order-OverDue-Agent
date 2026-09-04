codeunit 77105 "Custom Agent Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetInitials(): Text[4]
    begin
        exit(AgentInitialsLbl);
    end;

    procedure GetDisplayName(): Text[80]
    begin
        exit(AgentDisplayNameLbl);
    end;

    procedure GetSetupPageId(): Integer
    begin
        exit(Page::"PO Overdue Agent Setup Dialog");
    end;

    procedure GetSummaryPageId(): Integer
    begin
        exit(Page::"PO Overdue KPI");
    end;

    [NonDebuggable]
    procedure GetInstructions(): SecretText
    var
        Instructions: Text;
    begin
        Instructions := NavApp.GetResourceAsText('PurchaseOrderOverDueAgentPrompt.txt', TextEncoding::UTF8);
        exit(Instructions);
    end;

    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Agent.PopulateDefaultProfile(DefaultProfileTok, CurrentModuleInfo.Id, TempAllProfile);
    end;

    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
        i: Integer;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Clear(TempAccessControlBuffer);
        TempAccessControlBuffer."Company Name" := CompanyName();
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := CurrentModuleInfo.Id;
        TempAccessControlBuffer."Role ID" := DefaultPermissionSetTok;
        TempAccessControlBuffer.Insert(true);
    end;

    procedure EnsureSetupExists(UserSecurityID: Guid)
    var
        CustomAgentSetup: Record "PO Overdue Agent Setup";
    begin
        CustomAgentSetup.GetOrCreate(UserSecurityID);
    end;

    var
        Agent: Codeunit Agent;
        DefaultProfileTok: Label 'Purchase Order Overdue Agent', Locked = true;
        DefaultPermissionSetTok: Label 'SUPER', Locked = true;
        AgentInitialsLbl: Label 'PO', MaxLength = 4;
        AgentDisplayNameLbl: Label 'Purchase Order Overdue Agent';
}
