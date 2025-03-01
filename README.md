# Flutter Form Mailer 📩
A Flutter package that allows form submissions via SMTP email.

## Features
✅ Easily create forms with multiple fields  
✅ Send form data via email using SMTP  
✅ Customizable input fields

## Usage

A developer using this package can now add a form with multiple fields like this:

```dart
FormMailer(
  smtpServer: 'smtp.example.com',
  smtpUsername: 'user@example.com',
  smtpPassword: 'yourpassword',
  recipientEmail: 'admin@example.com',
  fields: [
    FormFieldData('Name'),
    FormFieldData('Email'),
    FormFieldData('Message'),
  ],
);


## Installation
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_form_mailer: ^1.0.0
