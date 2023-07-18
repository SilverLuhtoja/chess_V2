import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../helper/helper_methods.dart';

Future<String?> getUUID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.remove("client_uuid");
  String? existingUUID = prefs.getString("client_uuid");
  if (existingUUID == null) {
    String uuid = const Uuid().v1();
    prefs.setString("client_uuid", uuid);
    printGreen("UUID CREATED: Prefs_UUID: $uuid");
    // await createUUID();
  }
  printGreen("Device UUID: ${prefs.getString("client_uuid")}");
  return prefs.getString("client_uuid");
}
