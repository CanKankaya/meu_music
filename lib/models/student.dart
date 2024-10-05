import 'package:intl/intl.dart';

class Student {
  int? rowNumber;
  String? name;
  String? tc;
  String? studentNumber;
  String? phoneNumber;
  String? department;
  String? payment;
  String? optionalField;
  DateTime? addedDate;

  Student({
    this.rowNumber,
    this.name,
    this.tc,
    this.studentNumber,
    this.phoneNumber,
    this.department,
    this.payment,
    this.optionalField,
    this.addedDate,
  });

  factory Student.fromList(List<String?> data, {int? index}) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) {
        return null;
      }
      try {
        return DateFormat('dd.MM.yyyy').parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    return Student(
      rowNumber: index,
      name: data[0],
      tc: data[1],
      studentNumber: data[2],
      phoneNumber: data[3],
      department: data[4],
      payment: data[5],
      optionalField: data[6],
      addedDate: parseDate(data[7]),
    );
  }

  @override
  String toString() {
    return 'Student{rowNumber: $rowNumber, name: $name, tc: $tc, studentNumber: $studentNumber, phoneNumber: $phoneNumber, department: $department, iban: $payment, optionalField: $optionalField, addedDate: $addedDate}';
  }
}
