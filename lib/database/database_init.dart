import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initDatabase() async {
  // Configuración específica para Linux
  if (Platform.isLinux) {
    databaseFactory = databaseFactoryFfi;
    sqfliteFfiInit();

    // Especificamos la ruta manualmente si es necesario
    try {
      databaseFactoryFfi.setDatabasesPath('/home/sevenban/Escritorio');
    } catch (e) {
      if (kDebugMode) {
        print('Error setting database path: $e');
      }
    }
  } else {
    // Comportamiento normal para otras plataformas
    databaseFactory = databaseFactory;
  }

  // Configuración adicional para FFI si es necesario
  sqfliteFfiInit();
}