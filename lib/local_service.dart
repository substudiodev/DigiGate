import 'db_helper.dart';
import 'api_service.dart';

Future<void> saveEntry(Map<String, dynamic> data) async {
  final db = await DBHelper.getDB();

  data['is_synced'] = 0;

  await db.insert('entries', data);
}

Future<void> syncPendingData() async {
  final db = await DBHelper.getDB();

  final pending = await db.query(
    'entries',
    where: 'is_synced = ?',
    whereArgs: [0],
  );

  for (var entry in pending) {
    bool success = await sendToServer(entry);

    if (success) {
      await db.update(
        'entries',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [entry['id']],
      );
    }
  }
}