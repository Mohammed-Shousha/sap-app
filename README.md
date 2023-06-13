# SAP (Smart Automatic Pharmacy) App 💊

The SAP (Smart Automatic Pharmacy) App is a Flutter application designed to facilitate the process of obtaining prescribed medications from an automatic medicines vending machine.

## Features

### Patient

- **Prescription History**: Patients can view their prescription history, which includes details about each prescription they have received. The history provides information such as the prescription details and a QR code associated with each prescription.
- **Prescription QR Code**: The app generates a unique QR code for each prescription. Patients can scan the QR code using the automatic vending machine to retrieve their prescribed medicines.
- **Payment**: Patients have the option to pay for their prescription directly through the app. This feature allows for a seamless and convenient payment process.
- **QR Code Display**: Patients can also view their own QR code within the app. This QR code is used to verify the patient's identity and provide it to the doctor for prescription issuance.

### Doctor

- **Prescription Creation**: Doctors can create new prescriptions for patients by scanning the patient's QR code. They can choose the required medicines, specify quantities, and provide instructions as needed. This functionality streamlines the prescription writing process.
- **Prescription History**: Doctors can view the prescription history of their patients. The history displays essential details of each prescription, excluding the QR code and payment options available to the patient.

### Admin

- **Medicine Management**: Admins have the responsibility of adding medicines to the automatic vending machine. They can scan the barcode of each medicine using the app and then open the machine to add the medicines. Additionally, admins can specify the quantity of each medicine added to update the database.

## Used Packages

- **qr_flutter**: This package is used to generate QR codes for each prescription. It enables patients to scan the QR code at the automatic vending machine to retrieve their prescribed medicines.

- **flutter_barcode_scanner**: The flutter_barcode_scanner package is used to scan QR codes. It allows doctors to scan the patient's QR code, which facilitates the process of creating new prescriptions, also it's used by the admin to scan medcines' barcode.

- **provider**: The provider package is used for state management within the SAP App. It enables efficient data sharing and communication between different screens and components.

- **flutter_stripe**: This package integrates Stripe payment processing into the SAP App. It enables patients to make payments for their prescriptions directly within the app.

- **graphql_flutter**: The graphql_flutter package is used to communicate with a GraphQL API. It facilitates the retrieval and manipulation of data related to prescriptions, patients, and doctors.

- **http**: The http package is used for making HTTP requests to the backend API. It enables communication between the SAP App and the server for various functionalities, such as adding medicines and handling payment process.
