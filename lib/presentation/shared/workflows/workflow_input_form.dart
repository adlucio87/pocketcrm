import 'package:flutter/material.dart';
import 'package:pocketcrm/domain/models/workflow/workflow.dart';

class WorkflowInputForm extends StatefulWidget {
  final List<WorkflowInputSchema> schema;
  final Function(Map<String, dynamic>, bool) onChanged;

  const WorkflowInputForm({
    Key? key,
    required this.schema,
    required this.onChanged,
  }) : super(key: key);

  @override
  _WorkflowInputFormState createState() => _WorkflowInputFormState();
}

class _WorkflowInputFormState extends State<WorkflowInputForm> {
  final Map<String, dynamic> _values = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _validateForm();
  }

  void _validateForm() {
    bool isValid = true;
    for (var field in widget.schema) {
      if (field.isRequired && (_values[field.fieldName] == null || _values[field.fieldName].toString().isEmpty)) {
        isValid = false;
        break;
      }
    }
    widget.onChanged(_values, isValid);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schema.isEmpty) {
      return const SizedBox.shrink();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.schema.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildField(field),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildField(WorkflowInputSchema field) {
    if (field.fieldType == 'Number') {
      return TextFormField(
        decoration: InputDecoration(
          labelText: field.fieldName + (field.isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          _values[field.fieldName] = num.tryParse(val);
          _validateForm();
        },
      );
    } else if (field.fieldType == 'Text' || field.fieldType == 'String') {
      return TextFormField(
        decoration: InputDecoration(
          labelText: field.fieldName + (field.isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _values[field.fieldName] = val;
          _validateForm();
        },
      );
    } else {
      return TextFormField(
        decoration: InputDecoration(
          labelText: field.fieldName + (field.isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _values[field.fieldName] = val;
          _validateForm();
        },
      );
    }
  }
}
