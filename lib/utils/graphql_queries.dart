class GraphQLQueries {
  static const String getMedicine = r'''
    query GetMedicine($medicineId: ID!) {
      medicineById(id: $medicineId) {
        _id
        name
        availableQuantity
        otc
        position {
          row
          col
        }
        price
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

  static const String getPrescriptions = r'''
    query PrescriptionByUser($userId: ID!){
      prescriptionsByUser(userId: $userId) {
        _id
        patientName
        doctorName
        date
        isPaid
        isRecived
        medicines {
          medicineId
          quantity
          doctorInstructions
          price
        }
      }
    }
  ''';

  static const String getPrescription = r'''
    query PrescriptionById($id: ID!){
      prescriptionById(id: $id) {
        _id
        patientName
        doctorName
        date
        isPaid
        isRecived
        medicines {
          medicineName
          quantity
          doctorInstructions
          price
        }
      }
    }
  ''';
}
