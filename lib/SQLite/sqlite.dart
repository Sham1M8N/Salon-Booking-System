import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "beautypackage.db";

  String usersTable = """Create TABLE users (userid INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      phone TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL)""";

  String beautybookTable = """
    CREATE TABLE beautybook (
      bookid INTEGER PRIMARY KEY AUTOINCREMENT,
      userid INTEGER NOT NULL,
      bookdate TEXT NOT NULL,
      booktime TEXT NOT NULL,
      appointmentdate TEXT NOT NULL,
      appointmenttime TEXT NOT NULL,
      facebeautypackage TEXT NOT NULL,
      numguest INTEGER NOT NULL,
      packageprice REAL NOT NULL,
      FOREIGN KEY (userid) REFERENCES users (userid)
    )
  """;

  // SQL for creating the administrator table
  String adminTable = """
    CREATE TABLE administrator (
      adminid INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL
    )
  """;

  // Initialize the database
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(usersTable);
        await db.execute(beautybookTable);
        await db.execute(adminTable);
      },
    );
  }

  // Login method for administrator (no password hashing)
  Future<bool> adminLogin(String username, String password) async {
    // Hardcoded admin credentials for testing purposes
    if (username == 'admin' && password == '1234') {
      return true;
    }

    final Database db = await initDB();
    var result = await db.rawQuery(
      "SELECT * FROM administrator WHERE username = ? AND password = ?",
      [username, password],
    );
    return result.isNotEmpty;
  }

  // Sign up method for users (no password hashing)
  Future<int> userSignup(Map<String, dynamic> user) async {
    final Database db = await initDB();
    return db.insert('users', user);
  }

  // Create a beautybook entry
  Future<int> createBeautyBook(Map<String, dynamic> booking) async {
    final Database db = await initDB();
    return db.insert('beautybook', booking);
  }

  // Fetch all beautybook entries
  Future<List<Map<String, dynamic>>> getBeautyBooks() async {
    final Database db = await initDB();
    return db.query('beautybook');
  }

  // Delete a beautybook entry
  Future<int> deleteBeautyBook(int bookid) async {
    final Database db = await initDB();
    return db.delete('beautybook', where: 'bookid = ?', whereArgs: [bookid]);
  }
  
  // Update a beautybook entry
  Future<int> updateBeautyBook(Map<String, dynamic> booking, int bookid) async {
    final Database db = await initDB();
    return db.update('beautybook', booking, where: 'bookid = ?', whereArgs: [bookid]);
  }

  // Password check method for users (no password hashing)
  Future<bool> checkPassword(String username, String password) async {
    final Database db = await initDB();

    // Query the database for the user with the provided username and password
    var result = await db.rawQuery(
      "SELECT * FROM users WHERE username = ? AND password = ?",
      [username, password],
    );

    // If the result is not empty, the password is correct
    return result.isNotEmpty;
  }

  // Method to fetch all users (FOR TESTING to see the database working)
  Future<List<Map<String, dynamic>>> getUsers() async {
    final Database db = await initDB();
    return db.query('users');
  }

  // CRUD Operations for Users

  // CREATE: Add a new user
  Future<int> createUser(Map<String, dynamic> user) async {
    final Database db = await initDB();
    return db.insert('users', user);
  }

  // READ: Fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final Database db = await initDB();
    return db.query('users');
  }

  // READ: Fetch a user by ID
  Future<Map<String, dynamic>?> getUserById(int userid) async {
    final Database db = await initDB();
    var result = await db.query(
      'users',
      where: 'userid = ?',
      whereArgs: [userid],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // UPDATE: Update user details
  Future<int> updateUser(Map<String, dynamic> user, int userid) async {
    final Database db = await initDB();
    return db.update(
      'users',
      user,
      where: 'userid = ?',
      whereArgs: [userid],
    );
  }

  // DELETE: Delete a user by ID
  Future<int> deleteUser(int userid) async {
    final Database db = await initDB();
    return db.delete(
      'users',
      where: 'userid = ?',
      whereArgs: [userid],
    );
  }

  // Fetch users with their booking details (join users and beautybook)
  Future<List<Map<String, dynamic>>> getUsersWithBookings() async {
    final Database db = await initDB();
    
    // SQL query to join users and beautybook tables
    var result = await db.rawQuery('''
      SELECT users.userid, users.name, users.email, users.phone, users.username,
             beautybook.bookid, beautybook.bookdate, beautybook.booktime, 
             beautybook.appointmentdate, beautybook.appointmenttime, beautybook.facebeautypackage
      FROM users
      JOIN beautybook ON users.userid = beautybook.userid
    ''');

    return result;
  }

  Future<int?> getUserIdByCredentials(String username, String password) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
      "SELECT userid FROM users WHERE username = ? AND password = ?",
      [username, password],
    );

    if (result.isNotEmpty) {
      // Explicitly cast the 'userid' field to int
      return result.first['userid'] as int?;
    }
    return null;  // Return null if no user is found
  }

  Future<int> updateUserAddress(int userId, String updatedAddress) async {
  final Database db = await initDB();
  return db.update(
    'users',
    {'address': updatedAddress},
    where: 'userid = ?',
    whereArgs: [userId],
  );
}
// UPDATE: Update user password
Future<int> updateUserPassword(int userid, String newPassword) async {
  final Database db = await initDB();
  return db.update(
    'users',
    {'password': newPassword},
    where: 'userid = ?',
    whereArgs: [userid],
  );
}
// Fetch all beautybook entries for a specific user by their user ID
Future<List<Map<String, dynamic>>> getBeautyBooksForUser(int userId) async {
  final Database db = await initDB();
  
  // Query to get all beauty bookings for the given user
  return db.query(
    'beautybook',
    where: 'userid = ?',
    whereArgs: [userId],
  );
}
 Future<List<Map<String, dynamic>>> getAllBookingsWithUserDetails() async {
  final Database db = await initDB();
  var result = await db.rawQuery(''' 
    SELECT beautybook.bookid, beautybook.bookdate, beautybook.booktime,
           beautybook.appointmentdate, beautybook.appointmenttime,
           beautybook.facebeautypackage, beautybook.numguest, beautybook.packageprice,
           users.name, users.email, users.phone
    FROM beautybook
    JOIN users ON beautybook.userid = users.userid
  ''');
  return result;
}


}
