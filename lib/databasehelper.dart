import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:resicareapp/models/resident.dart';
import 'package:intl/intl.dart';
import 'models/family.dart';
import 'models/visitor.dart';
import 'models/hall.dart';
import 'models/reserve.dart';
import 'models/complaint.dart';
import 'models/news.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'resicare.db');
    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create tables here
        await db.execute('''
        CREATE TABLE residents(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phoneNumber TEXT,
          email TEXT,
          password TEXT,
          unitNumber TEXT,
          userType TEXT,
          imageUrl TEXT NULL
        )
      ''');

        await db.execute('''
        CREATE TABLE family(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phoneNumber TEXT,
          category TEXT,
          residentId INTEGER,
          FOREIGN KEY (residentId) REFERENCES residents(id)
        )
      ''');

        await db.execute('''
        CREATE TABLE visitors(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phoneNumber TEXT,
          dateArrive TEXT,
          timeArrive TEXT,
          dateDepart TEXT,
          timeDepart TEXT,
          residentId INTEGER,
          FOREIGN KEY (residentId) REFERENCES residents(id)
        )
      ''');

        await db.execute('''
        CREATE TABLE complaints(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          complaintText TEXT,
          status TEXT,
          category TEXT,
          userId INTEGER,
          FOREIGN KEY (userId) REFERENCES residents(id)
        )
      ''');

        await db.execute('''
        CREATE TABLE halls(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          status TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE reserves(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hallId INTEGER,
          ownerId INTEGER,
          dateReserved TEXT,
          reason TEXT,
          status TEXT,
          FOREIGN KEY (hallId) REFERENCES halls(id),
          FOREIGN KEY (ownerId) REFERENCES residents(id)
        )
      ''');

        await db.execute('''
        CREATE TABLE news(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          newsText TEXT,
          newsDate TEXT,
          newsTime TEXT,
          ownerId INTEGER,
          FOREIGN KEY (ownerId) REFERENCES residents(id)
        )
      ''');

        // Insert resident data
        await db.rawInsert('''
        INSERT INTO residents (name, phoneNumber, email, password, unitNumber, userType, imageUrl)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', ['Admin', '0192400284', 'admin@gmail.com', 'admin123', '1', 'Admin', null]);

        await db.rawInsert('''
        INSERT INTO residents (name, phoneNumber, email, password, unitNumber, userType, imageUrl)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', ['Sumin', '0196699918', 'sumin@gmail.com', 'sumin123', '-', 'Guard', null]);

        await db.rawInsert('''
        INSERT INTO residents (name, phoneNumber, email, password, unitNumber, userType, imageUrl)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', ['Hani', '0192400284', 'hani@gmail.com', 'hani123', '100', 'Resident', null]);

        //Insert Hall Data
        await db.rawInsert('''
        INSERT INTO halls (name, status)
        VALUES (?, ?)
      ''', ['Campbell Hall', 'Available']);

        await db.rawInsert('''
        INSERT INTO halls (name, status)
        VALUES (?, ?)
      ''', ['Resi Pool', 'Unavailable']);
      },

    );
    return database;
  }


  Future<int> insertResident(Resident resident) async {
    Database db = await database;
    return await db.insert('residents', resident.toMap());
  }

  Future<Resident> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'residents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Resident.fromMap(maps.first);
    } else {
      throw Exception('User not found');
    }
  }

  Future<int?> getUserIdByEmail(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'residents',
      columns: ['id'],
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result[0]['id'];
    }
    return null;
  }

  Future<void> updateResidentImageUrl(int userId, String newImageUrl) async {
    final db = await database;
    await db.update(
      'residents',
      {'imageUrl': newImageUrl},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateResidentDetails(int userId, String newName, String newPhoneNumber, String newUnitNumber) async {
    final db = await database;
    await db.update(
      'residents',
      {
        'name': newName,
        'phoneNumber': newPhoneNumber,
        'unitNumber': newUnitNumber,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateResidentPassword(int userId, String newPassword) async {
    final db = await database;
    await db.update(
      'residents',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateFamilyDetails(int id, String name, String phoneNumber, String category) async {
    final db = await database;
    return await db.update(
      'family',
      {
        'name': name,
        'phoneNumber': phoneNumber,
        'category': category,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFamilyMember(int id) async {
    final db = await database;
    return await db.delete(
      'family',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<List<Family>> getFamilyMembersByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'family',
      where: 'residentId = ?', // Change 'userId' to 'residentId'
      whereArgs: [userId],
    );
    List<Family> familyMembers = [];
    for (var map in maps) {
      familyMembers.add(Family.fromMap(map));
    }
    return familyMembers;
  }

  Future<void> insertFamilyMember(Family familyMember) async {
    final db = await database;
    await db.insert('family', familyMember.toMap());
  }


  Future<List<Visitor>> getVisitorHistory(int residentId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'visitors',
      where: 'residentId = ?',
      whereArgs: [residentId],
    );
    List<Visitor> visitors = [];
    for (var map in maps) {
      visitors.add(Visitor.fromMap(map));
    }
    return visitors;
  }

  Future<void> insertVisitor(Visitor visitor) async {
    final db = await database;
    await db.insert('visitors', visitor.toMap());
  }

  Future<void> deleteVisitor(int visitorId) async {
    Database db = await database;
    await db.delete(
      'visitors',
      where: 'id = ?',
      whereArgs: [visitorId],
    );
  }

  Future<void> updateVisitor(Visitor visitor) async {
    Database db = await database;
    await db.update(
      'visitors',
      visitor.toMap(),
      where: 'id = ?',
      whereArgs: [visitor.id],
    );
  }

  Future<List<Hall>> getHalls() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('halls');

    return List.generate(maps.length, (i) {
      return Hall(
        id: maps[i]['id'],
        name: maps[i]['name'],
        status: maps[i]['status'],
      );
    });
  }

  Future<List<Hall>> getAvailableHalls() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'halls',
      where: 'status = ?',
      whereArgs: ['Available'],
    );

    return List.generate(maps.length, (i) {
      return Hall(
        id: maps[i]['id'],
        name: maps[i]['name'],
        status: maps[i]['status'],
      );
    });
  }


  Future<void> insertHall(Hall hall) async {
    final db = await database;
    await db.insert(
      'halls',
      hall.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHall(int hallId) async {
    // Get a reference to the database.
    final Database db = await database;

    // Delete the hall with the specified id.
    await db.delete(
      'halls',
      where: 'id = ?',
      whereArgs: [hallId],
    );
  }

  Future<void> updateHall(Hall hall) async {
    // Get a reference to the database.
    final Database db = await database;

    // Update the hall details in the database.
    await db.update(
      'halls',
      hall.toMap(),
      where: 'id = ?',
      whereArgs: [hall.id],
    );
  }

  Future<List<Complaint>> getComplaintsByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'complaints',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Complaint(
        id: maps[i]['id'],
        complaintText: maps[i]['complaintText'],
        status: maps[i]['status'],
        category: maps[i]['category'],
        userId: maps[i]['userId'],
      );
    });
  }

  Future<void> insertComplaint(Complaint complaint) async {
    final db = await database;
    await db.insert('complaints', complaint.toMap());
  }


  Future<List<Complaint>> getComplaints() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('complaints');
    return List.generate(maps.length, (i) {
      return Complaint(
        id: maps[i]['id'],
        complaintText: maps[i]['complaintText'],
        status: maps[i]['status'],
        category: maps[i]['category'],
        userId: maps[i]['userId'],
      );
    });
  }

  Future<void> updateComplaintStatus(int complaintId, String newStatus) async {
    // Get a reference to the database.
    final Database db = await database;

    // Update the specified complaint with the new status.
    await db.update(
      'complaints',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [complaintId],
    );
  }

  Future<void> deleteComplaint(int complaintId) async {
    final Database db = await database;

    await db.delete(
      'complaints',
      where: 'id = ?',
      whereArgs: [complaintId],
    );
  }

  Future<int> insertNews(News news) async {
    Database db = await database;
    // Automatically set the current date and time
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());

    Map<String, dynamic> newsMap = news.toMap();
    newsMap['newsDate'] = currentDate;
    newsMap['newsTime'] = currentTime;

    return await db.insert('news', newsMap);
  }

  Future<int> updateNews(News news) async {
    Database db = await database;
    return await db.update('news', news.toMap(), where: 'id = ?', whereArgs: [news.id]);
  }


  Future<int> deleteNews(int id) async {
    Database db = await database;
    return await db.delete('news', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<News>> getNews() async {
    if (_database == null) {
      await initDatabase();
    }
    if (_database != null) {
      final List<Map<String, dynamic>> newsMap = await _database!.query('news');
      return List.generate(newsMap.length, (index) {
        return News(
          id: newsMap[index]['id'],
          newsText: newsMap[index]['newsText'],
          newsDate: newsMap[index]['newsDate'],
          newsTime: newsMap[index]['newsTime'],
          ownerId: newsMap[index]['ownerId'],
        );
      });
    } else {
      // Return an empty list if _database is still null
      return [];
    }
  }

  Future<List<Resident>> getResidents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('residents');

    // Convert the List<Map<String, dynamic>> to a List<Resident>
    return List.generate(maps.length, (i) {
      return Resident(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        email: maps[i]['email'],
        password: maps[i]['password'],
        unitNumber: maps[i]['unitNumber'],
        userType: maps[i]['userType'],
        imageUrl: maps[i]['imageUrl'],
      );
    });
  }

  Future<List<Family>> getFamilyMembers(int residentId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'family',
      where: 'residentId = ?',
      whereArgs: [residentId],
    );

    // Convert the List<Map<String, dynamic>> to a List<Family>
    return List.generate(maps.length, (i) {
      return Family(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        category: maps[i]['category'],
        userId: maps[i]['residentId'],
      );
    });
  }

  Future<List<Visitor>> getVisitors() async {
    final Database db = await database;
    final List<Map<String, dynamic>> visitorsMap = await db.query('visitors');
    return List.generate(visitorsMap.length, (index) {
      return Visitor(
        id: visitorsMap[index]['id'],
        name: visitorsMap[index]['name'],
        phoneNumber: visitorsMap[index]['phoneNumber'],
        dateArrive: visitorsMap[index]['dateArrive'],
        timeArrive: visitorsMap[index]['timeArrive'],
        dateDepart: visitorsMap[index]['dateDepart'],
        timeDepart: visitorsMap[index]['timeDepart'],
        residentId: visitorsMap[index]['residentId'],
      );
    });
  }

  Future<int> updateComplaint(Complaint complaint) async {
    final db = await database;
    return await db.update(
      'complaints',
      complaint.toMap(),
      where: 'id = ?',
      whereArgs: [complaint.id],
    );
  }

  Future<void> deleteFromReserves(int residentId) async {
    final Database db = await database;
    await db.delete('reserves', where: 'ownerId = ?', whereArgs: [residentId]);
  }

  Future<void> deleteFromFamily(int residentId) async {
    final Database db = await database;
    await db.delete('family', where: 'residentId = ?', whereArgs: [residentId]);
  }

  Future<void> deleteFromVisitors(int residentId) async {
    final Database db = await database;
    await db.delete('visitors', where: 'residentId = ?', whereArgs: [residentId]);
  }

  Future<void> deleteFromComplaints(int residentId) async {
    final Database db = await database;
    await db.delete('complaints', where: 'userId = ?', whereArgs: [residentId]);
  }

  Future<void> deleteFromNews(int residentId) async {
    final Database db = await database;
    await db.delete('news', where: 'ownerId = ?', whereArgs: [residentId]);
  }

  Future<void> deleteFromResidents(int residentId) async {
    final Database db = await database;
    await db.delete('residents', where: 'id = ?', whereArgs: [residentId]);
  }

  Future<List<Family>> getAllFamilyMembers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('family');

    return List.generate(maps.length, (i) {
      return Family(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        category: maps[i]['category'],
        userId: maps[i]['residentId'],
      );
    });
  }

  Future<List<Resident>> getAllResidents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('residents');

    return List.generate(maps.length, (i) {
      return Resident(
        id: maps[i]['id'],
        name: maps[i]['name'],
        phoneNumber: maps[i]['phoneNumber'],
        email: maps[i]['email'],
        password: maps[i]['password'],
        unitNumber: maps[i]['unitNumber'],
        userType: maps[i]['userType'],
        imageUrl: maps[i]['imageUrl'],
      );
    });
  }

  Future<int> getPendingReservationsCount() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reserves',
      where: 'status = ?',
      whereArgs: ['Pending'],
    );
    return maps.length;
  }

  Future<int> getComplaintsToBeReviewedCount() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'complaints',
        where: 'status = ?',
        whereArgs: ['To Be Reviewed'],
      );
      return maps.length;
    } catch (e) {
      print('Error getting complaints to be reviewed count: $e');
      return 0; // Return 0 in case of error
    }
  }

  Future<List<News>> getLatestNews() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'news',
        orderBy: 'id DESC',
        limit: 3,
      );
      return List.generate(maps.length, (i) {
        return News(
          id: maps[i]['id'],
          newsText: maps[i]['newsText'],
          newsDate: maps[i]['newsDate'],
          newsTime: maps[i]['newsTime'],
          ownerId: maps[i]['ownerId'],
        );
      });
    } catch (e) {
      print('Error getting latest news: $e');
      return []; // Return empty list in case of error
    }
  }

  Future<String> getUserPassword(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      columns: ['password'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return maps.first['password'] as String;
    } else {
      throw Exception('User not found');
    }
  }

  Future<List<Map<String, dynamic>>> getVisitorList() async {
    Database db = await database;
    return await db.rawQuery(
        '''
      SELECT * FROM Visitors
      WHERE timeArrive IS NULL OR dateDepart IS NULL OR timeDepart IS NULL
      '''
    );
  }

  Future<List<Map<String, dynamic>>> getResidentById(int id) async {
    Database db = await database;
    return await db.query('Residents', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getVisitorListNonNullValues() async {
    Database db = await database;
    return await db.rawQuery(
        '''
      SELECT * FROM Visitors
      WHERE timeArrive IS NOT NULL AND dateDepart IS NOT NULL AND timeDepart IS NOT NULL
      '''
    );
  }

  Future<void> insertReservation(Reserve reserve) async {
    final Database db = await database;

    await db.insert(
      'reserves',
      reserve.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isHallAvailable(int hallId, String date) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'reserves',
      where: 'hallId = ? AND dateReserved = ? AND status NOT IN (?, ?)',
      whereArgs: [hallId, date, 'Rejected', 'Reserved'],
    );
    return result.isEmpty;
  }


  Future<List<Map<String, dynamic>>> getReservationsForUser(int userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT reserves.*, halls.name as hallName FROM reserves '
          'INNER JOIN halls ON reserves.hallId = halls.id '
          'WHERE reserves.ownerId = ?',
      [userId],
    );

    return maps;
  }


  Future<void> deleteReservation(int reservationId) async {
    final Database db = await database;
    await db.delete(
      'reserves',
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  Future<List<Map<String, dynamic>>> getReservationsForHall(int hallId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT reserves.*, residents.unitNumber FROM reserves '
          'INNER JOIN residents ON reserves.ownerId = residents.id '
          'WHERE reserves.hallId = ? AND reserves.status = ? '
          'ORDER BY reserves.dateReserved ASC',
      [hallId, 'Pending'],
    );

    return maps;
  }

  Future<void> updateReservationStatus({required int reservationId, required String newStatus}) async {
    final Database db = await database;

    await db.update(
      'reserves',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }


  Future<List<Map<String, dynamic>>> getReservationHistory(int hallId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT reserves.*, residents.unitNumber FROM reserves '
          'INNER JOIN residents ON reserves.ownerId = residents.id '
          'WHERE reserves.hallId = ? AND (reserves.status = ? OR reserves.status = ?) '
          'ORDER BY reserves.dateReserved ASC',
      [hallId, 'Reserved', 'Pending'],
    );

    return maps;
  }

  Future<List<Hall>> getAllHalls() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('halls');
    return List.generate(maps.length, (i) {
      return Hall(
        id: maps[i]['id'],
        name: maps[i]['name'],
        status: maps[i]['status'],
      );
    });
  }

  // Function to fetch all reservations from the database
  Future<List<Reserve>> getAllReservations() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reserves');
    return List.generate(maps.length, (i) {
      return Reserve(
        id: maps[i]['id'],
        hallId: maps[i]['hallId'],
        ownerId: maps[i]['ownerId'],
        dateReserved: maps[i]['dateReserved'],
        reason: maps[i]['reason'],
        status: maps[i]['status'],
        // Add more attributes here based on your Reserve class
      );
    });
  }

  Future<List<Reserve>> getReservationsByHallId(int hallId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reserves',
      where: 'hallId = ?',
      whereArgs: [hallId],
    );

    return List.generate(maps.length, (i) {
      return Reserve(
        id: maps[i]['id'],
        hallId: maps[i]['hallId'],
        ownerId: maps[i]['ownerId'],
        dateReserved: maps[i]['dateReserved'],
        reason: maps[i]['reason'],
        status: maps[i]['status'],
      );
    });
  }

  Future<List<Reserve>> getReservationsByDate(String date) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'reserves',
      where: 'dateReserved = ?',
      whereArgs: [date],
    );

    // Convert the List<Map<String, dynamic>> into a List<Reserve>
    return List.generate(maps.length, (i) {
      return Reserve(
        id: maps[i]['id'],
        hallId: maps[i]['hallId'],
        ownerId: maps[i]['ownerId'],
        dateReserved: maps[i]['dateReserved'],
        reason: maps[i]['reason'],
        status: maps[i]['status'],
      );
    });
  }


}


