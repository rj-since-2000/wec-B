# Chatbot [wec-B]

A new project based on Google Dialogflow.
Dialogflow is a Google-owned developer of human-computer interaction technologies based on natural language conversations. The company is best known for creating the Assistant, a virtual buddy for Android, iOS, and Windows Phone smartphones that perform tasks and answers users’ question in a natural language.

## Chatbot Definition
A chatbot is a program that can conduct an intelligent conversation. It should be able to convincingly simulate human behavior.

## Screenshot

<img src = https://user-images.githubusercontent.com/68644104/95351554-f7516280-08de-11eb-82cf-1d3e7adc7b8e.png>

## Setup

1. To use services provided by Google Cloud, you must create a project.
2. Create a service account and download the private key file as a JSON file that contains your key downloads to your computer.
3. In your project open a folder named “assets”. Replace the existing JSON file with the file which you downloaded from Google Cloud Platform (GCP) into the assets folder.
4. Open “pubspec.yaml” and save the file as [name of your downloaded JSON file], we should use the same name in our pubspec.yaml file as in assets folder.

[NOTE/Warning] The file already existing as JSON file in assets folder is only for the develpoment purpose and should not be used by anyone without the permission of the author.

## Getting Started

This project is a starting point for a Dialogflow and Flutter application.

A few resources to get you started if this is your first chatbot project:

Dialogflow Documentation: https://cloud.google.com/dialogflow/es/docs/basics
Adding Fulfillment: https://cloud.google.com/dialogflow/es/docs/fulfillment-overview
Sample guilde on building chatbot: https://marutitech.com/build-a-chatbot-using-dialogflow/
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
