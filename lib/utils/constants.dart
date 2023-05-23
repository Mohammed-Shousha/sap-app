class Constants {
  static const String baseUrl = 'http://192.168.1.18:4040';

  static const String piServerUrl = 'http://192.168.1.8:8000';

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
