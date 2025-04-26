import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// 1. Define field types
enum FieldType { text, file }

// 2. Define Form Field Data
class FormFieldData {
  final String label;
  final FieldType fieldType;

  FormFieldData({
    required this.label,
    required this.fieldType,
  });
}

// 3. Main FormMailer Widget
class FormMailer extends StatefulWidget {
  final String smtpServer;
  final String smtpUsername;
  final String smtpPassword;
  final String recipientEmail;
  final List<FormFieldData> fields;

  const FormMailer({
    Key? key,
    required this.smtpServer,
    required this.smtpUsername,
    required this.smtpPassword,
    required this.recipientEmail,
    required this.fields,
  }) : super(key: key);

  @override
  _FormMailerState createState() => _FormMailerState();
}

class _FormMailerState extends State<FormMailer> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, List<PlatformFile>> _fileControllers = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      if (field.fieldType == FieldType.text) {
        _textControllers[field.label] = TextEditingController();
      } else if (field.fieldType == FieldType.file) {
        _fileControllers[field.label] = [];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};

      widget.fields.forEach((field) {
        if (field.fieldType == FieldType.text) {
          formData[field.label] = _textControllers[field.label]!.text;
        } else if (field.fieldType == FieldType.file) {
          formData[field.label] = _fileControllers[field.label];
        }
      });

      _sendEmail(formData);
    }
  }

  void _sendEmail(Map<String, dynamic> formData) async {
    String emailBody = '''
      <h2>New Form Submission</h2>
      ${formData.entries.where((e) => e.value is String).map((e) => '<p><strong>${e.key}:</strong> ${e.value}</p>').join()}
      <hr>
      <footer><small>Sent from Flutter App</small></footer>
    ''';

    try {
      final smtpServer = SmtpServer(
        widget.smtpServer,
        username: widget.smtpUsername,
        password: widget.smtpPassword,
      );

      final message = Message()
        ..from = Address(widget.smtpUsername, 'Form Mailer')
        ..recipients.add(widget.recipientEmail)
        ..subject = 'New Form Submission'
        ..html = emailBody;

      // Attach files
      for (var entry in formData.entries) {
        if (entry.value is List<PlatformFile>) {
          for (var file in entry.value) {
            if (file.path != null) {
              message.attachments.add(FileAttachment(File(file.path!))
                ..location = Location.inline
                ..fileName = file.name);
            }
          }
        }
      }

      await send(message, smtpServer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending email: $e')),
      );
    }
  }

  Future<void> _pickFiles(String label) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _fileControllers[label] = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...widget.fields.map((field) {
            if (field.fieldType == FieldType.text) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _textControllers[field.label],
                  decoration: InputDecoration(labelText: field.label),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              );
            } else if (field.fieldType == FieldType.file) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () => _pickFiles(field.label),
                    child: const Text('Select Files'),
                  ),
                  if (_fileControllers[field.label]!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _fileControllers[field.label]!
                          .map((file) => Text(file.name))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
