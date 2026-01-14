// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_db.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'g13_db.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('Creating database tables...');
        await _createTables(db);
        print('Tables created successfully');

        print('Starting seed...');
        await SeedData.seedDatabase(db);
      },
    );

    return db;
  }

  static Future<void> _createTables(Database db) async {
    // 1. SAN_ADDRESSES (pas de dépendances)
    await db.execute('''
      CREATE TABLE SAN_ADDRESSES (
        ADD_ID INTEGER PRIMARY KEY,
        ADD_POSTAL_CODE INTEGER NOT NULL,
        ADD_CITY TEXT NOT NULL,
        ADD_STREET_NAME TEXT NOT NULL,
        ADD_STREET_NUMBER TEXT NOT NULL
      )
    ''');

    // 2. SAN_CATEGORIES (pas de dépendances)
    await db.execute('''
      CREATE TABLE SAN_CATEGORIES (
        CAT_ID INTEGER PRIMARY KEY,
        CAT_LABEL TEXT NOT NULL
      )
    ''');

    // 3. SAN_ROLES (pas de dépendances)
    await db.execute('''
      CREATE TABLE SAN_ROLES (
        ROL_ID INTEGER PRIMARY KEY,
        ROL_NAME TEXT NOT NULL
      )
    ''');

    // 4. SAN_USERS (dépend de ADD_ID, CLU_ID sera ajouté après)
    await db.execute('''
      CREATE TABLE SAN_USERS (
        USE_ID INTEGER PRIMARY KEY,
        ADD_ID INTEGER NOT NULL,
        CLU_ID INTEGER,
        USE_MAIL TEXT NOT NULL,
        USE_PASSWORD TEXT NOT NULL,
        USE_NAME TEXT NOT NULL,
        USE_LAST_NAME TEXT NOT NULL,
        USE_BIRTHDATE TEXT,
        USE_PHONE_NUMBER INTEGER,
        USE_LICENCE_NUMBER INTEGER,
        USE_PPS_FORM TEXT,
        USE_MEMBERSHIP_DATE TEXT
      )
    ''');

    // 5. SAN_CLUBS (dépend de USE_ID et ADD_ID)
    await db.execute('''
      CREATE TABLE SAN_CLUBS (
        CLU_ID INTEGER PRIMARY KEY,
        USE_ID INTEGER NOT NULL,
        ADD_ID INTEGER NOT NULL,
        CLU_NAME TEXT NOT NULL
      )
    ''');

    // 6. SAN_RAIDS (dépend de CLU_ID, ADD_ID, USE_ID)
    await db.execute('''
      CREATE TABLE SAN_RAIDS (
        RAI_ID INTEGER PRIMARY KEY,
        CLU_ID INTEGER NOT NULL,
        ADD_ID INTEGER NOT NULL,
        USE_ID INTEGER NOT NULL,
        RAI_NAME TEXT NOT NULL,
        RAI_MAIL TEXT,
        RAI_PHONE_NUMBER TEXT,
        RAI_WEB_SITE TEXT,
        RAI_IMAGE TEXT,
        RAI_TIME_START TEXT NOT NULL,
        RAI_TIME_END TEXT NOT NULL,
        RAI_REGISTRATION_START TEXT NOT NULL,
        RAI_REGISTRATION_END TEXT NOT NULL
      )
    ''');

    // 7. SAN_RACES (dépend de USE_ID, RAI_ID)
    await db.execute('''
      CREATE TABLE SAN_RACES (
        RAC_ID INTEGER PRIMARY KEY,
        USE_ID INTEGER NOT NULL,
        RAI_ID INTEGER NOT NULL,
        RAC_TIME_START TEXT NOT NULL,
        RAC_TIME_END TEXT NOT NULL,
        RAC_TYPE TEXT NOT NULL,
        RAC_DIFFICULTY TEXT NOT NULL,
        RAC_MIN_PARTICIPANTS INTEGER NOT NULL,
        RAC_MAX_PARTICIPANTS INTEGER NOT NULL,
        RAC_MIN_TEAMS INTEGER NOT NULL,
        RAC_MAX_TEAMS INTEGER NOT NULL,
        RAC_TEAM_MEMBERS INTEGER NOT NULL,
        RAC_AGE_MIN INTEGER NOT NULL,
        RAC_AGE_MIDDLE INTEGER NOT NULL,
        RAC_AGE_MAX INTEGER NOT NULL
      )
    ''');

    // 8. SAN_TEAMS (dépend de USE_ID)
    await db.execute('''
      CREATE TABLE SAN_TEAMS (
        TEA_ID INTEGER PRIMARY KEY,
        USE_ID INTEGER NOT NULL,
        TEA_NAME TEXT NOT NULL,
        TEA_IMAGE TEXT
      )
    ''');

    // 9. Tables de liaison
    await db.execute('''
      CREATE TABLE SAN_USERS_TEAMS (
        USE_ID INTEGER NOT NULL,
        TEA_ID INTEGER NOT NULL,
        PRIMARY KEY (USE_ID, TEA_ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_TEAMS_RACES (
        TEA_ID INTEGER NOT NULL,
        RAC_ID INTEGER NOT NULL,
        TER_TIME TEXT,
        TER_IS_VALID INTEGER,
        TER_RACE_NUMBER INTEGER NOT NULL,
        PRIMARY KEY (TEA_ID, RAC_ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_ROLES_USERS (
        USE_ID INTEGER NOT NULL,
        ROL_ID INTEGER NOT NULL,
        PRIMARY KEY (USE_ID, ROL_ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_CATEGORIES_RACES (
        RAC_ID INTEGER NOT NULL,
        CAT_ID INTEGER NOT NULL,
        CAR_PRICE REAL NOT NULL,
        PRIMARY KEY (RAC_ID, CAT_ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_USERS_RACES (
        USE_ID INTEGER NOT NULL,
        RAC_ID INTEGER NOT NULL,
        USR_CHIP_NUMBER INTEGER,
        USR_TIME REAL,
        PRIMARY KEY (USE_ID, RAC_ID)
      )
    ''');
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'g13_db.db');
    await deleteDatabase(path);
    _database = null;
    print('Database deleted, will be recreated on next access');
    await database;
  }
}
