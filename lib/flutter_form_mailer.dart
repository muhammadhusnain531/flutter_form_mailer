import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


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
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _controllers[field.label] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> formData = {};
      widget.fields.forEach((field) {
        formData[field.label] = _controllers[field.label]!.text;
      });

      _sendEmail(formData);
    }
  }

  void _sendEmail(Map<String, String> formData) async {
    String emailBody = '''
      <h2>New Form Submission</h2>
      ${formData.entries.map((e) => '<p><strong>${e.key}:</strong> ${e.value}</p>').join()}
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...widget.fields.map((field) => TextFormField(
            controller: _controllers[field.label],
            decoration: InputDecoration(labelText: field.label),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          )),
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

class FormFieldData {
  final String label;
  FormFieldData(this.label);
}
