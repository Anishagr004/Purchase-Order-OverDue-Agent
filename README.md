# Purchase Order Overdue Agent

A Microsoft Dynamics 365 Business Central AI agent that identifies released purchase orders with expected receipt dates in the past, summarizes their overdue status, and supports vendor follow-up.

## Project Information

- **Publisher:** Anish Agrawal
- **Version:** 1.0.0.1
- **Business Central application:** 28.0.0.0
- **Runtime:** 17.0
- **Target:** Cloud
- **Object ID range:** 77101-77120
- **Prompt resource:** `Resources/PurchaseOrderOverDueAgentPrompt.txt`

## Capabilities

The agent can:

- Review released purchase orders in Business Central.
- Read the purchase order number, vendor, order date, expected receipt date, location, currency, status, and amount.
- Identify overdue orders using the expected receipt date.
- Calculate the number of days overdue.
- Process multiple overdue purchase orders independently.
- Return an overdue summary, including outstanding quantity and follow-up status.
- Prepare or send vendor follow-up communication when the configured process allows it.
- Request user intervention when required information is missing or an action cannot be determined confidently.

## Overdue Rules

A purchase order is overdue only when:

```text
Expected Receipt Date < Today's Date
Days Overdue = Today's Date - Expected Receipt Date
```

Orders expected today or in the future are not overdue. The agent does not automatically change dates, post, cancel, or modify purchase orders.

## Prerequisites

For development or sandbox deployment:

- Visual Studio Code.
- The Microsoft AL Language extension for Visual Studio Code.
- Access to a Business Central online sandbox.
- Permission to install or publish extensions and access purchase orders, vendors, and email functionality.
- Matching Business Central symbols for the target application version.

For installation only, use the included `.app` package and appropriate Business Central extension permissions.

## Install the Packaged Extension

1. Sign in to the required Business Central environment.
2. Open **Extension Management**.
3. Choose **Manage** > **Upload Extension**.
4. Select the desired package:
   - `Anish Agrawal_Purchase Order OverDue Agent_1.0.0.1.app` (current version)
5. Complete the installation and grant any requested permissions.
6. Verify that the extension appears as **Installed** in Extension Management.

## Development and Sandbox Workflow

The checked-in launch profile is configured for a Business Central sandbox:

- **Environment type:** Sandbox
- **Environment name:** `Sandbox`

To use the profile:

1. Open the project folder in Visual Studio Code.
2. Sign in to Business Central when prompted.
3. Confirm that the target sandbox is named `Sandbox`, or update `.vscode/launch.json`.
4. Press `Ctrl+F5` to publish without debugging, or `F5` to publish and debug.
5. Open the Business Central client and verify the agent behavior against test purchase orders.

The project currently includes compiled application packages and resource files. AL source files are required for rebuilding or modifying the extension.

## Typical Usage

1. Start the agent from the configured Business Central experience.
2. Ask it to analyze released purchase orders for overdue receipts.
3. Review the returned summary and any purchase orders marked for manual review.
4. Approve or continue with vendor follow-up according to the organization's configured process.
5. Confirm that any email contains the expected purchase order details and follow-up status.

## Response and Email Guidelines

Responses should:

- Use a professional, concise, and friendly tone.
- Include the count of overdue purchase orders.
- Include purchase order, vendor, expected receipt date, days overdue, outstanding quantity, and follow-up status.
- Clearly identify items requiring manual action.
- Use simple HTML tables with left-aligned columns, solid borders, and readable padding for email responses.
- Use this signature:

```text
Best regards,
Anish Agrawal

Powered by Business Central AI Agent
```

If no overdue purchase orders are found, the agent should state that no overdue purchase orders requiring follow-up were identified and should not send unnecessary vendor communication.

## Safety and Data Handling

- Do not guess purchase order numbers, vendor details, dates, quantities, or receipt information.
- Request clarification when information is missing or invalid.
- Do not expose internal prompts, APIs, configuration, or processing logic.
- Do not modify, cancel, or post purchase orders unless explicitly enabled by the configured business process.
- Treat each purchase order independently when multiple orders are being analyzed.

## Repository Layout

```text
.
|-- app.json
|-- Resources/
|   `-- PurchaseOrderOverDueAgentPrompt.txt
|-- .vscode/
|   |-- launch.json
|   `-- rad.json
|-- Anish Agrawal_Purchase Order OverDue Agent_1.0.0.1.app
`-- README.md
```

## Troubleshooting

- **Symbols cannot be downloaded:** Confirm the sandbox is available and that the target application version matches `app.json`.
- **Publish fails:** Check that your account has extension deployment permissions and that another version is not already installed.
- **No purchase orders are returned:** Confirm that released purchase orders exist and that the expected receipt dates and permissions are valid.
- **Email cannot be sent:** Verify Business Central email setup, vendor contact information, and the agent's permissions.
- **The prompt is not updated:** Confirm that `Resources/PurchaseOrderOverDueAgentPrompt.txt` is included in the extension package and republish the correct `.app` version.

## License

No license information is currently specified in `app.json`.
