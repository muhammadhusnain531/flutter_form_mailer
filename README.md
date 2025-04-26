# Flutter Form Mailer 📩

A Flutter package that allows you to easily send form submissions via SMTP email.

## Features
- ✅ Easily create forms with multiple fields.
- ✅ Send form data via email using SMTP.
- ✅ Support for both text fields and file uploads.
- ✅ Customizable input fields.

## Usage

### Basic Example

To create a simple form with text fields and file uploads, you can use the `FormMailer` widget like this:

```dart
import 'package:flutter_form_mailer/flutter_form_mailer.dart';

FormMailer(
  smtpServer: 'smtp.example.com', // SMTP server for sending emails
  smtpUsername: 'user@example.com', // SMTP username
  smtpPassword: 'yourpassword', // SMTP password
  recipientEmail: 'admin@example.com', // Recipient email
  fields: [
    FormFieldData('Name', FieldType.text),  // Text field for Name
    FormFieldData('Email', FieldType.text),  // Text field for Email
    FormFieldData('Message', FieldType.text),  // Text field for Message
    FormFieldData('Attachment', FieldType.file),  // File upload field
  ],
);
