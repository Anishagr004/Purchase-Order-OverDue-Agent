codeunit 77104 "Task Execution" implements IAgentTaskExecution
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Analyzes the content of an agent task message and its attachments.
    /// Error annotations stop task execution; warning annotations enforce review.
    /// </summary>
    procedure AnalyzeAgentTaskMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        if AgentTaskMessage.Type = AgentTaskMessage.Type::Output then
            PostProcessOutputMessage(AgentTaskMessage, Annotations)
        else
            ValidateInputMessage(AgentTaskMessage, Annotations);
    end;

    /// <summary>
    /// Returns user intervention suggestions for the specified agent task context.
    /// </summary>
    procedure GetAgentTaskUserInterventionSuggestions(AgentTaskUserInterventionRequestDetails: Record "Agent User Int Request Details"; var Suggestions: Record "Agent Task User Int Suggestion")
    begin
        // No custom intervention suggestions for this agent
    end;

    /// <summary>
    /// Gets the current page context for the specified agent task and page.
    /// </summary>
    procedure GetAgentTaskPageContext(AgentTaskPageContextRequest: Record "Agent Task Page Context Req."; var AgentTaskPageContext: Record "Agent Task Page Context")
    begin
        // No custom page context for this agent

    end;

    local procedure ValidateInputMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        // Add input validation logic as needed
        // Example: check for required fields, format validation, or content filtering
    end;

    local procedure PostProcessOutputMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        // Add output post-processing logic as needed
        // Example: add email signature, format output, or inject disclaimers
        //CopyAttachments(AgentTaskMessage."Task ID", AgentTaskMessage."External ID", '');

    end;
}
