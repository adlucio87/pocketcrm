const String getManualWorkflowsQuery = """
query GetManualWorkflows(\$objectType: String!) {
  workflows(filter: { triggerType: { eq: "MANUAL" }, isActive: { eq: true } }) {
    edges {
      node {
        id
        name
        description
        inputSchema {
           fieldName
           fieldType
           isRequired
        }
      }
    }
  }
}
""";

const String executeManualWorkflowMutation = """
mutation ExecuteManualWorkflow(\$workflowId: UUID!, \$recordId: UUID!, \$payload: JSON) {
  triggerWorkflow(
    workflowId: \$workflowId,
    recordId: \$recordId,
    payload: \$payload
  ) {
    success
    workflowRunId
    error {
      message
    }
  }
}
""";
