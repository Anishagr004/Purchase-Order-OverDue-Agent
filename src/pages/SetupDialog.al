// ============================================================================
// PO Overdue Agent - Setup Dialog Page
// ============================================================================
// This ConfigurationDialog page allows users to configure the PO Overdue Agent.
// It integrates with the Agent Setup Part for standard agent configuration.
// ============================================================================

namespace Demo.Agent.PurchaseOrderOverdue;

using System.Agents;
using Demo.Agent.PurchaseOrderOverdue;
using System.AI;
using System.Email;

#pragma warning disable AS0007
#pragma warning disable AS0032
page 77101 "PO Overdue Agent Setup Dialog"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    Caption = 'PO Overdue Agent Setup Dialog';
    InstructionalText = 'Configure the PO Overdue Agent to monitor PO Overdue items';
    AdditionalSearchTerms = 'PO Overdue Agent, Copilot agent, Agent, PO';
    SourceTable = "PO Overdue Agent Setup";
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

            group(ReviewSettingsCard)
            {
                Caption = 'Review Settings';
                InstructionalText = 'Configure whether incoming messages require review before processing.';

                field(InputMessageReview; Rec."Input Message Review")
                {
                    Caption = 'Require Review of Incoming Messages';
                    ToolTip = 'Specifies whether incoming messages require review before the agent processes them.';

                    trigger OnValidate()
                    begin
                        Rec."Input Message Review" := InputMessageReview;
                        ConfigUpdated();
                    end;
                }
            }
            group(BillingInformationGroup)
            {
                Visible = FirstConfig;
                InstructionalText = 'By enabling the Purchase Order OverDue Agent, you understand your organization may be billed for its use.';
                Caption = 'Important';

                field(LearnMoreBilling; LearnMoreTxt)
                {
                    ShowCaption = false;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Hyperlink(LearnMoreBillingLinkTxt);
                    end;
                }
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(OK)
            {
                Caption = 'Update';
                Enabled = IsConfigUpdated;
                ToolTip = 'Apply the changes to the agent setup.';
            }
            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discards the changes and closes the setup page.';
            }
        }
    }

    trigger OnOpenPage()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        UserSecurityIDFilter: Text;
        UserSecurityID: Guid;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Purchase Order OverDue Agent") then
            Error('The Purchase Order OverDue Agent capability is not enabled.');

        IsConfigUpdated := false;
        FirstConfig := IsFirstConfig();
        UserSecurityIDFilter := Rec.GetFilter("User Security ID");
        if not Evaluate(UserSecurityID, UserSecurityIDFilter) then
            Clear(UserSecurityID);

        CurrPage.AgentSetupPart.Page.Initialize(
            UserSecurityID,
            Enum::"Agent Metadata Provider"::"Purchase Order OverDue Agent",
            GetPRUsername(),
            GetPRUserDisplayName(),
            GetAgentSummary());

        UpdateAgentSetupBuffer();
        InitialState := AgentSetupBuffer.State;
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateAgentSetupBuffer();
        IsConfigUpdated := IsConfigUpdated or AgentSetup.GetChangesMade(AgentSetupBuffer);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ReadyToActivateLbl: Label 'Ready to activate the Purchase Order OverDue Agent?\\The agent will run now and until you deactivate it.';
        ActivateWithoutMailboxLbl: Label 'There is no mailbox selected for the agent to monitor. Are you sure you want to continue?';
        MessageLimitErr: Label 'The message limit must be greater than zero.';
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        if EnabledAgentFirstConfig() then
            if Confirm(ReadyToActivateLbl) then
                Rec.State := Rec.State::Enabled;

        UpdateAgentSetupBuffer();

        if Rec."Message Limit" <= 0 then
            Error(MessageLimitErr);

        UpdateAgent();
        exit(true);
    end;

    local procedure UpdateAgentSetupBuffer()
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
    end;

    local procedure StateChanged(): Boolean
    begin
        exit((AgentSetupBuffer.State <> InitialState) or IsFirstConfig());
    end;

    local procedure UpdateControls()
    var
        POOverdueSetup: Record "PO Overdue Agent Setup";
    begin
        if Rec.IsEmpty() or (Rec."User Security ID" <> AgentSetupBuffer."User Security ID") then begin
            GetPOOverdueSetup(POOverdueSetup, AgentSetupBuffer."User Security ID");
            Rec.TransferFields(POOverdueSetup);
            if Rec.IsEmpty() then
                Rec.Insert()
            else
                Rec.Modify();
        end;

        DailyEmailLimit := Rec."Message Limit";
        if DailyEmailLimit = 0 then
            DailyEmailLimit := 100;
    end;

    local procedure ConfigUpdated()
    begin
        IsConfigUpdated := true;

        if EnabledAgentFirstConfig() then
            AgentSetupBuffer.State := AgentSetupBuffer.State::Enabled;
    end;

    local procedure EnabledAgentFirstConfig(): Boolean
    begin
        exit((AgentSetupBuffer.State = AgentSetupBuffer.State::Disabled) and IsFirstConfig());
    end;

    local procedure IsFirstConfig(): Boolean
    begin
        exit(IsNullGuid(Rec."User Security ID"));
    end;


    local procedure GetPOOverdueSetup(var POOverdueSetup: Record "PO Overdue Agent Setup"; UserSecurityID: Guid)
    begin
        POOverdueSetup.GetOrCreate(UserSecurityID);
    end;

    local procedure GetPRUsername(): Code[50]
    begin
        exit('Purchase Order OverDue Agent');
    end;

    local procedure GetPRUserDisplayName(): Text[80]
    begin
        exit('Purchase Order OverDue Agent');
    end;

    local procedure GetAgentSummary(): Text
    begin
        exit('The Purchase Order OverDue Agent monitors incoming emails for Purchase Order OverDue inquiries, checks item availability in Business Central, and creates purchase orders when needed.');
    end;

    local procedure UpdateAgent()
    var
        POOverdueSetup: Record "PO Overdue Agent Setup";
        Agent: Codeunit Agent;
        NewUserSecurityID: Guid;
        IsNew: Boolean;
    begin
        // Save agent setup via the Agent Setup codeunit first (may create new agent)
        if IsNullGuid(AgentSetupBuffer."User Security ID") then
            NewUserSecurityID := AgentSetup.SaveChanges(AgentSetupBuffer);

        // Get or create the PR Setup record for this agent
        IsNew := not POOverdueSetup.Get(NewUserSecurityID);
        if IsNew then begin
            POOverdueSetup.Init();
            POOverdueSetup."User Security ID" := NewUserSecurityID;
        end;

        // Update all fields
        POOverdueSetup."Message Limit" := Rec."Message Limit";
        POOverdueSetup."Configured By" := UserSecurityId();

        // Update state
        if AgentSetupBuffer.State = AgentSetupBuffer.State::Enabled then begin
            POOverdueSetup.State := POOverdueSetup.State::Enabled;
            Agent.Activate(POOverdueSetup."User Security ID");
        end else begin
            POOverdueSetup.State := POOverdueSetup.State::Disabled;
            Agent.Deactivate(POOverdueSetup."User Security ID");
        end;

        // Insert or Modify
        if IsNew then
            POOverdueSetup.Insert(true)
        else
            POOverdueSetup.Modify(true);
    end;

    var
        AgentSetupBuffer: Record "Agent Setup Buffer";
        TempEmailAccount: Record "Email Account" temporary;
        AgentSetup: Codeunit "Agent Setup";
        MailboxName: Text;
        MailboxFolderName: Text;
        InputMessageReview: Boolean;
        AnalyseAttachment: Boolean;
        LastSyncText: Text;
        InitialState: Option;
        DailyEmailLimit: Integer;
        ShowLastSync: Boolean;
        FirstConfig: Boolean;
        IsConfigUpdated: Boolean;
        LearnMoreTxt: Label 'Learn more';
        LearnMoreBillingLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2333517', Locked = true;
        OptionalFolderLbl: Label '(optional)';
}
