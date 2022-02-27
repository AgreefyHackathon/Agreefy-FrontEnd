import 'package:at_chat_flutter/services/chat_service.dart' as CS;
import 'package:hi/a_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen(this.title, {Key? key}) : super(key: key);
  final String title;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {

  File? contract;
  late CS.ChatService _chatService;


  void initState(){
    _chatService = CS.ChatService();
  }

  Future<File?> _buildPopupDialog(BuildContext context) async{
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context,setState) {
              return AlertDialog(
                title: Text('Choose a contract'),
                content: ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);
                    if (result != null) {
                      setState(() {
                        contract = File(result.files.single.path!);
                      });
                    }
                  },
                  child: Text("Upload a file"),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close')
                  ),
                  if(contract != null)...{
                    TextButton(
                        onPressed: () {
                          _chatService.sendImageFile(context, contract!);
                        },
                        child: Text('Upload')
                    ),
                  }
                ],
              );
            }
          );
        });
  }

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
            _buildPopupDialog(context);
            //this opens the up the option to choose a file

            // if (result != null) {
            //   File file = File(result.files.single.path!);
            // }
            //this line opens a single file
            // final file = result?.files.first;
            //   openFile(file!);
          },
        )
      ]),
      body: ChatScreen(
        height: MediaQuery.of(context).size.height,
        title: widget.title,
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
