import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Homepage.dart';

// RadioListTile updated to use GetX controller
Widget MyRadioTile( BuildContext context,
    {required String title, required String query}) {
  SearchController controller = Get.put(SearchController());
  return Obx(() => RadioListTile<String>(
    title: Text(title, style: const TextStyle(fontSize: 16)),
    value: title,
    groupValue: controller.Search.value;
    onChanged: (value) {
      controller.changeSearchEngine(value!);
      controller.getSearchEngineUrl(query);
      refreshWeb(controller); // Update the web view
      Navigator.pop(context);
    },
  ));
}

// BottomNavigationBar updated to use GetX controller
BottomNavigationBar buildBottomNavigationBar(SearchController controller) {

  return BottomNavigationBar(
    backgroundColor: Colors.grey.shade100,
    selectedItemColor: Colors.blue.shade700,
    unselectedItemColor: Colors.grey.shade600,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_add_outlined), label: 'Bookmarks'),
      BottomNavigationBarItem(
          icon: Icon(Icons.arrow_back_ios), label: 'Back'),
      BottomNavigationBarItem(
          icon: Icon(Icons.arrow_forward_ios), label: 'Forward'),
    ],
    onTap: (index) async {
      if (index == 0) {
        controller.getSearchEngineUrl("");
        txtSearch.clear();
        refreshWeb(controller); // Update the web view
      } else if (index == 2) {
        if (await webViewController?.canGoBack() ?? false) {
          webViewController?.goBack();
        }
      } else if (index == 3) {
        if (await webViewController?.canGoForward() ?? false) {
          webViewController?.goForward();
        }
      }
    },
  );
}
