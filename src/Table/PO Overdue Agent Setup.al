// ============================================================================
// Purchase Order Overdue Agent - Setup Table
// ============================================================================
// This table stores the configuration for the Purchase Order Overdue Agent.
// It contains the email account settings, agent user, and sync settings.
// ============================================================================

namespace Demo.Agent.PurchaseOrderOverdue;

using System.Email;
using System.Security.User;

table 77101 "PO Overdue Agent Setup"
{
    Caption = 'Purchase Order Overdue Agent Setup';
    DataClassification = CustomerContent;
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        // Primary Key - User Security ID of the Agent
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = SystemMetadata;
        }

        // ====================================================================
        // Agent User Settings
        // ====================================================================
        field(10; "State"; Option)
        {
            Caption = 'State';
            OptionMembers = Disabled,Enabled;
            OptionCaption = 'Disabled,Enabled';
            DataClassification = SystemMetadata;


        }
        field(11; "Configured By"; Guid)
        {
            Caption = 'Configured By';
            DataClassification = SystemMetadata;
        }

        // ====================================================================
        // Processing Settings
        // ====================================================================
        field(31; "Message Limit"; Integer)
        {
            Caption = 'Message Limit';
            ToolTip = 'Maximum number of emails to process per run.';
            InitValue = 100;
        }

        // ====================================================================
        // Job Queue Settings
        // ====================================================================
        field(50; "Scheduled Task ID"; Guid)
        {
            Caption = 'Scheduled Task ID';
            DataClassification = SystemMetadata;
        }
        // ====================================================================
        // Input Settings
        // ====================================================================
        field(51; "Input Message Review"; boolean)
        {
            Caption = 'Input Message Review';
            DataClassification = SystemMetadata;
        }
        field(52; "Analyse Attachment"; boolean)
        {
            Caption = 'Analyse Attachment';
            ToolTip = 'Enable analysis of email attachments for message processing.';
            DataClassification = SystemMetadata;
        }

    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }


    /// <summary>
    /// Gets or creates the setup record for a given agent user
    /// </summary>
    internal procedure GetOrCreate(AgentUserSecurityID: Guid)
    begin
        if not Rec.Get(AgentUserSecurityID) then begin
            Rec.Init();
            Rec."User Security ID" := AgentUserSecurityID;
            Rec."Message Limit" := 100;
            Rec.Insert(true);
        end;
    end;
}
