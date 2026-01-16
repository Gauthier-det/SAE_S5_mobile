import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper class for managing local SQLite database operations.
/// Handles database initialization, table creation, and schema management.
class DatabaseHelper {
  static Database? _database;
  static const _databaseVersion = 7;

  /// Gets the database instance, initializing it if necessary.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'g13_db.db');

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _dropAllTables(db);
        await _createTables(db);
      },
    );

    return db;
  }

  /// Drops all database tables.
  static Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS SAN_USERS_RACES');
    await db.execute('DROP TABLE IF EXISTS SAN_CATEGORIES_RACES');
    await db.execute('DROP TABLE IF EXISTS SAN_ROLES_USERS');
    await db.execute('DROP TABLE IF EXISTS SAN_TEAMS_RACES');
    await db.execute('DROP TABLE IF EXISTS SAN_USERS_TEAMS');
    await db.execute('DROP TABLE IF EXISTS SAN_TEAMS');
    await db.execute('DROP TABLE IF EXISTS SAN_RACES');
    await db.execute('DROP TABLE IF EXISTS SAN_RAIDS');
    await db.execute('DROP TABLE IF EXISTS SAN_CLUBS');
    await db.execute('DROP TABLE IF EXISTS SAN_USERS');
    await db.execute('DROP TABLE IF EXISTS SAN_ROLES');
    await db.execute('DROP TABLE IF EXISTS SAN_CATEGORIES');
    await db.execute('DROP TABLE IF EXISTS SAN_ADDRESSES');
  }

  /// Creates all database tables in the correct dependency order.
  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE SAN_ADDRESSES (
        ADD_ID INTEGER PRIMARY KEY,
        ADD_POSTAL_CODE INTEGER NOT NULL,
        ADD_CITY TEXT NOT NULL,
        ADD_STREET_NAME TEXT NOT NULL,
        ADD_STREET_NUMBER TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_CATEGORIES (
        CAT_ID INTEGER PRIMARY KEY,
        CAT_LABEL TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_ROLES (
        ROL_ID INTEGER PRIMARY KEY,
        ROL_NAME TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_USERS (
        USE_ID INTEGER PRIMARY KEY,
        ADD_ID INTEGER NOT NULL,
        CLU_ID INTEGER,
        USE_MAIL TEXT NOT NULL,
        USE_PASSWORD TEXT,
        USE_NAME TEXT NOT NULL,
        USE_LAST_NAME TEXT NOT NULL,
        USE_BIRTHDATE TEXT,
        USE_PHONE_NUMBER INTEGER,
        USE_LICENCE_NUMBER INTEGER,
        USE_GENDER TEXT,
        USE_MEMBERSHIP_DATE TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_CLUBS (
        CLU_ID INTEGER PRIMARY KEY,
        USE_ID INTEGER NOT NULL,
        ADD_ID INTEGER NOT NULL,
        CLU_NAME TEXT NOT NULL
      )
    ''');

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
        RAI_REGISTRATION_END TEXT NOT NULL,
        RAI_NB_RACES INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_RACES (
        RAC_ID INTEGER PRIMARY KEY,
        RAC_NAME TEXT NOT NULL,
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
        RAC_MIN_TEAM_MEMBERS INTEGER NOT NULL,
        RAC_MAX_TEAM_MEMBERS INTEGER NOT NULL,
        RAC_AGE_MIN INTEGER NOT NULL,
        RAC_AGE_MIDDLE INTEGER NOT NULL,
        RAC_AGE_MAX INTEGER NOT NULL,
        RAC_GENDER TEXT NOT NULL,
        RAC_CHIP_MANDATORY INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_TEAMS (
        TEA_ID INTEGER PRIMARY KEY,
        USE_ID INTEGER NOT NULL,
        TEA_NAME TEXT NOT NULL,
        TEA_IMAGE TEXT
      )
    ''');

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
        CAR_PRICE INTEGER NOT NULL,
        PRIMARY KEY (RAC_ID, CAT_ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE SAN_USERS_RACES (
        USE_ID INTEGER NOT NULL,
        RAC_ID INTEGER NOT NULL,
        USR_CHIP_NUMBER INTEGER,
        USR_TIME REAL,
        USR_PPS_FORM TEXT,
        PRIMARY KEY (USE_ID, RAC_ID)
      )
    ''');
  }

  /// Closes the database connection.
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Resets the database by deleting it and forcing recreation on next access.
  static Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'g13_db.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }
}
