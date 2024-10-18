import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../controller/controller.dart';

Future<void>? refreshWeb(SearchProvider searchProviderTrue) {
  return webViewController?.loadUrl(
    urlRequest: URLRequest(
      url: WebUri(searchProviderTrue.setSearchEngine),
    ),
  );
}

InAppWebViewController? webViewController;
TextEditingController txtSearch = TextEditingController();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    SearchProvider searchProviderFalse =
        Provider.of<SearchProvider>(context, listen: false);
    SearchProvider searchProviderTrue =
        Provider.of<SearchProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white10,
        elevation: 5,
        title: const Text(
          'My Browser',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size(width, 70),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              controller: txtSearch,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  searchProviderFalse.getSearchEngineUrl(value);
                  refreshWeb(searchProviderTrue);
                }
              },
              decoration: buildInputDecoration(),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '   Settings ',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String query = txtSearch.text;
                      return AlertDialog(
                        title: const Text("Select Search Engine",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyRadioTile(title: "Google", query: query),
                            MyRadioTile(title: "Yahoo", query: query),
                            MyRadioTile(title: "Bing", query: query),
                            MyRadioTile(title: "DuckDuckGo", query: query),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.search_off_rounded),
                  title: Text(' Search Engine'),
                ),
              ),
              InkWell(
                onTap: () {
                  refreshWeb(searchProviderTrue);
                },
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('refresh'),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(top: height * 0.07),
                        child: Dialog.fullscreen(
                          backgroundColor: Colors.white,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      searchProviderTrue.userHistory.length,
                                  itemBuilder: (context, index) {
                                    final data =
                                        searchProviderTrue.userHistory[index];
                                    final url = data.split('---').first;
                                    final search = data.split('---').last;
                                    return ListTile(
                                      onTap: () {
                                        txtSearch.text = search;
                                        webViewController?.loadUrl(
                                            urlRequest:
                                                URLRequest(url: WebUri(url)));
                                        Navigator.pop(context);
                                      },
                                      title: Text(search),
                                      subtitle: Text(url,
                                          style: TextStyle(
                                              color: Colors.grey.shade600)),
                                      trailing: IconButton(
                                        onPressed: () {
                                          searchProviderFalse
                                              .deleteFromHistory(index);
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.black),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Hostory'),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Setting'),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          (searchProviderTrue.isLoading)
              ? const LinearProgressIndicator(color: Colors.blue)
              : const SizedBox.shrink(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri(searchProviderTrue.setSearchEngine)),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  searchProviderFalse.updateLoadingStatus(true);
                },
                onLoadStop: (controller, url) {
                  searchProviderFalse.updateLoadingStatus(false);
                  String query = txtSearch.text != ""
                      ? txtSearch.text
                      : searchProviderTrue.selectedSearchEngine;
                  searchProviderFalse.addToHistory(url.toString(), query);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            searchProviderFalse.getSearchEngineUrl("");
            txtSearch.clear();
            refreshWeb(searchProviderTrue);
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
      ),
    );
  }

  void showSearchEngineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String query = txtSearch.text;
        return AlertDialog(
          title: const Text("Select Search Engine",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRadioTile(title: "Google", query: query),
              MyRadioTile(title: "Yahoo", query: query),
              MyRadioTile(title: "Bing", query: query),
              MyRadioTile(title: "DuckDuckGo", query: query),
            ],
          ),
        );
      },
    );
  }

  void showHistoryDialog(
    BuildContext context,
    double height,
    SearchProvider searchProviderTrue,
    SearchProvider searchProviderFalse,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: height * 0.07),
          child: Dialog.fullscreen(
            backgroundColor: Colors.white,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchProviderTrue.userHistory.length,
                    itemBuilder: (context, index) {
                      final data = searchProviderTrue.userHistory[index];
                      final url = data.split('---').first;
                      final search = data.split('---').last;
                      return ListTile(
                        onTap: () {
                          txtSearch.text = search;
                          webViewController?.loadUrl(
                              urlRequest: URLRequest(url: WebUri(url)));
                          Navigator.pop(context);
                        },
                        title: Text(search),
                        subtitle: Text(url,
                            style: TextStyle(color: Colors.grey.shade600)),
                        trailing: IconButton(
                          onPressed: () {
                            searchProviderFalse.deleteFromHistory(index);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

InputDecoration buildInputDecoration() {
  return InputDecoration(
    filled: true,
    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    hintText: "Search here...",
    hintStyle: const TextStyle(color: Colors.grey),
  );
}

class MyRadioTile extends StatelessWidget {
  final String title;
  final String query;

  const MyRadioTile({super.key, required this.title, required this.query});

  @override
  Widget build(BuildContext context) {
    SearchProvider searchProviderFalse =
        Provider.of<SearchProvider>(context, listen: false);
    SearchProvider searchProviderTrue =
        Provider.of<SearchProvider>(context, listen: true);

    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: title,
      groupValue: searchProviderTrue.selectedSearchEngine,
      onChanged: (value) {
        searchProviderFalse.changeSearchEngine(value!);
        searchProviderFalse.getSearchEngineUrl(query);
        refreshWeb(searchProviderTrue);
        Navigator.pop(context);
      },
    );
  }
}
