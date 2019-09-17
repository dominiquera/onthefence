import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {

  static Future<bool> getPostReadStatus(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> readPostsIds = prefs.getStringList("readPostsIds") ?? [];
    if (readPostsIds.contains(id.toString())) {
      return true;
    } else {
      return false;
    }
  }

  static setPostReadStatus(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> readPostsIds = prefs.getStringList("readPostsIds") ?? [];
    readPostsIds.add(id.toString());
    prefs.setStringList("readPostsIds", readPostsIds);
  }
}