import 'package:flutter_test/flutter_test.dart';
import 'package:pocketcrm/domain/models/workflow/workflow.dart';

void main() {
  test('Workflow model parsing', () {
    final json = {
      "id": "123",
      "name": "Test Workflow",
      "description": "A test workflow",
      "inputSchema": [
        {
          "fieldName": "notes",
          "fieldType": "Text",
          "isRequired": true
        }
      ]
    };

    final workflow = Workflow.fromTwenty(json);
    expect(workflow.id, "123");
    expect(workflow.name, "Test Workflow");
    expect(workflow.inputSchema.length, 1);
    expect(workflow.inputSchema.first.fieldName, "notes");
  });
}
