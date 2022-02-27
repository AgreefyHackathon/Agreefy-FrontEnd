import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen(this.title, {Key? key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat'), actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.handshake,
            color: Colors.lightBlueAccent,
          ),
          onPressed: () async {
            //this opens the up the option to choose a file
            final result =
                await FilePicker.platform.pickFiles(allowMultiple: true);

            //this line opens a single file
            final file = result?.files.first;
            openFile(file!);
          },
        )
      ]),
      body: ChatScreen(
        height: MediaQuery.of(context).size.height,
        title: title,
        isScreen: true,
        incomingMessageColor: Colors.green[200]!,
        outgoingMessageColor: Colors.blue[200]!,
      ),
    );
  }
}

void openFile(PlatformFile file) {
  OpenFile.open(file.path);
}
