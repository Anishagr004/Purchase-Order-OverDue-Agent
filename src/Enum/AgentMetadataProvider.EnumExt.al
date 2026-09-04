enumextension 77102 "Agent Metadata Provider" extends "Agent Metadata Provider"
{
    value(77101; "Purchase Order OverDue Agent")
    {
        Caption = 'Purchase Order OverDue Agent';
        Implementation = IAgentMetadata = "Agent Metadata", IAgentFactory = "Agent Factory", IAgentTaskExecution = "Task Execution";
    }
}
