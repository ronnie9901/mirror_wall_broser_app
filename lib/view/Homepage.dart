import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mirror_wall_broser_app/view/radiobotton.dart';


Future<void>? refreshWeb(SearchController controller) {
  return webViewController?.loadUrl(
    urlRequest: URLRequest(
      url: WebUri(controller.setSearch.value),
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

    // Use GetX to get the controller
    final SearchController controller = Get.find<SearchController>();

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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
                controller: txtSearch,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    controller.getSearchEngineUrl(value);
                    refreshWeb(controller);
                  }
                },
                decoration: InputDecoration(
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
                )),
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
                  refreshWeb(controller);
                },
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
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
                                child: Obx(() => ListView.builder(
                                  itemCount: controller.userHistory.length,
                                  itemBuilder: (context, index) {
                                    final data = controller.userHistory[index];
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
                                          controller.deleteFromHistory(index);
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.black),
                                      ),
                                    );
                                  },
                                )),
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
                  title: Text('History'),
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
          Obx(() => controller.isLoading.value
              ? const LinearProgressIndicator(color: Colors.blue)
              : const SizedBox.shrink()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(controller.setSearch.value)),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  this.controller.updateLoading(true);
                },
                onLoadStop: (controller, url) {
                  this.controller.updateLoading(false);
                  String query = txtSearch.text != "" ? txtSearch.text : controller.search.value;
                  this.controller.addToHistory(url.toString(), query);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(controller),
    );
  }

  void showDialogBox(
      BuildContext context,
      double height,
      SearchController controller,
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
                  child: Obx(() => ListView.builder(
                    itemCount: controller.userHistory.length,
                    itemBuilder: (context, index) {
                      final data = controller.userHistory[index];
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

                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
