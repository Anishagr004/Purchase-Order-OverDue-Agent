// ============================================================================
// Purchase Requisition Agent - Setup Page
// ============================================================================
// This page allows users to configure the Purchase Requisition Agent.
// Users can set up the email account, enable monitoring, and run manual syncs.
// ============================================================================

namespace Demo.Agent.PurchaseOrderOverdue;

using System.Email;

page 77103 "PO OverDue Agent Setup"
{
    Caption = 'Purchase Order OverDue Agent Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PO OverDue Agent Setup";

    layout
    {
        area(Content)
        {
            // ================================================================
            // Agent Configuration
            // ================================================================
            group(AgentConfig)
            {
                Caption = 'Agent Configuration';

                field("User Security ID"; Rec."User Security ID")
                {
                    ToolTip = 'The security ID of the agent user.';
                }
            }

            // ================================================================
            // Processing Settings
            // ================================================================
            group(Processing)
            {
                Caption = 'Processing Settings';

                field("Message Limit"; Rec."Message Limit")
                {
                    ToolTip = 'Maximum emails to process per run.';
                }
                field("Input Message Review"; Rec."Input Message Review")
                {
                    Caption = 'Input Message Review';
                    ToolTip = 'Require review of incoming messages before processing.';
                }
                field("Analyse Attachment"; Rec."Analyse Attachment")
                {
                    Caption = 'Analyse Attachment';
                    ToolTip = 'Enable analysis of email attachments for message processing.';
                }
            }

        }
    }

    actions
    {
        // ====================================================================
        // Navigation Actions
        // ====================================================================

        // ====================================================================
        // Processing Actions
        // ====================================================================
        area(Processing)
        {
            action(CreateAgent)
            {
                Caption = 'Create Agent';
                Image = User;
                ToolTip = 'Create the Purchase Order Overdue Agent user.';

                trigger OnAction()
                var
                    OverDueAgent: Codeunit "Install Agent";
                begin
                    OverDueAgent.CreatePurchaseOrderOverdueAgent();
                    Message('Purchase Order Overdue Agent created successfully.');
                end;
            }
        }

        // ====================================================================
        // Promoted Actions
        // ====================================================================
    }
    trigger OnOpenPage()
    begin
        // Ensure a setup record exists
        if Rec.FindFirst() then;
    end;
}
