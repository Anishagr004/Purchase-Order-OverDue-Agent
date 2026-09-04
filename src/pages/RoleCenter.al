// ============================================================================
// Purchase Order OverDue Agent - Profile
// ============================================================================
// This profile defines the role center and page customizations for the agent.
// Page customizations simplify the UI so the agent sees only essential fields.
// ============================================================================

namespace Demo.Agent.PurchaseOrderOverdue;
using Microsoft.Purchases.RoleCenters;

profile "Purchase Order OverDue Agent"
{
    Caption = 'Purchase Order OverDue Agent (Copilot)';
    Description = 'Agent Initiate to get the list of overdue purchase orders';
    RoleCenter = "Purchasing Manager Role Center";

    // Apply page customizations to simplify the Purchase requisition pages
    //Customizations = "PR Purchase Requisition";
}
