class GraphQLMutations {
  static const String login = r'''
    mutation Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        _id
        name
        email
        isDoctor
      }
    }
  ''';

  static const String registerUser = r'''
    mutation RegisterUser($name: String!, $email: String!, $password: String!) {
      registerUser(name: $name, email: $email, password: $password) {
        _id
        name
        email
        isDoctor
      }
    }
  ''';

  static const String registerDoctor = r'''
    mutation RegisterDoctor($name: String!, $email: String!, $password: String!, $licenseNumber: String!) {
      registerDoctor(name: $name, email: $email, password: $password, licenseNumber: $licenseNumber) {
        _id
        name
        email
        isDoctor
      }
    }
  ''';

  static const String addPrescription = r'''
    mutation AddPrescription($patientId: ID!, $doctorId: ID!, $medicines: [PrescriptionMedicineInput!]!){
      addPrescription(patientId: $patientId, doctorId: $doctorId, medicines: $medicines)
    }
  ''';

  static const String updateMedicine = r'''
    mutation UpdateMedicine($medicineId: ID!, $addedQuantity: Int!){
      updateMedicine(id: $medicineId, addedQuantity: $addedQuantity) 
    }
  ''';
}
