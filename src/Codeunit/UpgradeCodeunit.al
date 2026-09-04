codeunit 77107 "PO Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerDatabase()
    begin
        UpgradeAgentInstructions();
    end;

    local procedure UpgradeAgentInstructions()
    var
        POOverdueAgentSetup: Record "PO Overdue Agent Setup";
        Agent: Codeunit Agent;
        CustomAgentSetup: Codeunit "custom Agent Setup";
    begin
        if not POOverdueAgentSetup.FindSet() then
            exit;

        repeat
            Agent.SetInstructions(POOverdueAgentSetup."User Security ID", customAgentSetup.GetInstructions());
        until POOverdueAgentSetup.Next() = 0;
    end;
}
