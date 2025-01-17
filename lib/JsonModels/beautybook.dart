class BeautyBook {
  final int? bookId;
  final int userId;
  final String bookDate;
  final String bookTime;
  final String appointmentDate;
  final String appointmentTime;
  final String faceBeautyPackage;
  final int numGuest;
  final double packagePrice;

  BeautyBook({
    this.bookId,
    required this.userId,
    required this.bookDate,
    required this.bookTime,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.faceBeautyPackage,
    required this.numGuest,
    required this.packagePrice,
  });

  // Factory constructor to create a BeautyBook object from a Map
  factory BeautyBook.fromMap(Map<String, dynamic> map) {
    return BeautyBook(
      bookId: map['bookId'],
      userId: map['userId'],
      bookDate: map['bookDate'],
      bookTime: map['bookTime'],
      appointmentDate: map['appointmentDate'],
      appointmentTime: map['appointmentTime'],
      faceBeautyPackage: map['faceBeautyPackage'],
      numGuest: map['numGuest'],
      packagePrice: map['packagePrice'],
    );
  }

  // Method to convert a BeautyBook object to a Map
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'bookDate': bookDate,
      'bookTime': bookTime,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'faceBeautyPackage': faceBeautyPackage,
      'numGuest': numGuest,
      'packagePrice': packagePrice,
    };
  }
}
