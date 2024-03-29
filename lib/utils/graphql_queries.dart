class GraphQLQueries {
  static const String getMedicine = r'''
    query GetMedicine($medicineId: ID!) {
      medicineById(id: $medicineId) {
        _id
        name
        availableQuantity
        position {
          row
          col
        }
      }
    }
  ''';

  static const String getMedicines = r'''
    query Medicines{
      medicines {
        _id
        name
        price
      }
    }
  ''';

  static const String getUser = r'''
    query User($userId: ID!) {
      user(id: $userId) {
        _id
        name
        email
        isDoctor
      }
    }
  ''';

  static const String getUserPrescriptions = r'''
    query PrescriptionsByUser($userId: ID!){
      prescriptionsByUser(userId: $userId) {
        _id
        date
        patientName
        doctorName
        date
      }
    }
  ''';

  static const String getPrescriptionDetails = r'''
    query PrescriptionById($id: ID!){
      prescriptionById(id: $id) {
        _id
        patientName
        doctorName
        date
        isPaid
        isReceived
        medicines {
          medicineId
          medicineName
          doctorInstructions
          quantity
          price
        }
      }
    }
  ''';
}
