class Constants {
  static const String baseUrl = "https://sap-backend-production.up.railway.app";

  static const String piServerUrl = 'http://192.168.2.8:8000';

  static const String graphqlUrl = '$baseUrl/graphql';

  static const String paymentSheetUrl = '$baseUrl/payment-sheet';

  static const String markPrescriptionPaidUrl =
      '$baseUrl/mark-prescription-paid';

  static String shelfActionUrl(action) =>
      '$piServerUrl/shelf-action/${action.toString().split('.').last}';

  static const rowCount = 5;

  static const colCount = 10;

  static const shelfCapacity = 10;

  static const List<Map<String, dynamic>> welcomeData = [
    {
      'message': 'Welcome to SAP app!',
      'subMessage': 'We are happy to have you here!',
      'image': 'assets/images/welcome.svg',
    },
    {
      'message': 'Learn more about us!',
      'subMessage':
          'SAP is designed to make getting your medications easy and convenient.',
      'image': 'assets/images/medicine.svg',
    },
    {
      'message': 'What are you waiting for?',
      'subMessage': '',
      'image': 'assets/images/start.svg',
      'isLastPage': true,
    },
  ];
}

enum ShelfAction {
  open,
  close,
}
