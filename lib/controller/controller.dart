import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchController extends GetxController {
  var search = "".obs;
  var Search = "Google".obs;
  var setSearch = "https://www.google.com/search?q".obs;
  var isLoading = true.obs;
  var userHistory = <String>[].obs;

  void changeCategory(String newSearch) {
    search.value = newSearch;
  }

  void updateLoading(bool status) {
    isLoading.value = status;
  }

  void changeSearch(String newSearchEngine) {
    Search.value = newSearchEngine;
  }

  void getSearcheUrl(String query) {
    switch (Search.value) {
      case "Yahoo":
        setSearch.value = "https://search.yahoo.com/search?p=$query";
        break;
      case "bing":
        setSearch.value = "https://www.bing.com/search?q=$query";
        break;
      case "Duck Duck Go":
        setSearch.value = "https://duckduckgo.com/?q=$query";
        break;
      default:
        setSearch.value = "https://www.google.com/search?q=$query";
        break;
    }
  }

  Future<void> addToHistory(String url, String query) async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      bool check = false;
      for (var item in userHistory) {
        if (url == item.split('---').first) {
          check = true;
          break;
        }
      }
      if (!check) {
        userHistory.add("$url---$query");
        sharedPreferences.setStringList("history", userHistory);
      }
    } catch (e) {
      print("Error into store history -> $e");
    }
  }


  Future<void> getHistory() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userHistory.value = sharedPreferences.getStringList("history") ?? [];
    print(userHistory);
  }



}
