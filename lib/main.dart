import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/app/data/connection/websocket.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

Stream<String> readLine() =>
    stdin.transform(utf8.decoder).transform(const LineSplitter());
IOWebSocketChannel? channel;
void processLine(String line) {
  if (line.startsWith('u:')) {
    username = line.substring('u:'.length);
    print('ok $username');
  }
  if (line.startsWith('p:')) {
    password = line.substring('p:'.length);
    print('ok $password');
  }

  if (line.startsWith('printString')) {
    print('$username, $password');
  }
  if (line.startsWith('login')) {
    print('login with username $username and password $password');
    connect(username!, password!);
  }
  if (line.startsWith('send:')) {
    print("\x1B[1F\x1B[2K\x1B[1F");
    String message = line.substring('send:'.length);
    if (message.contains('|')) {
      send(message.split('|')[0], message.split('|')[1]);
    } else {
      send(message);
    }
  }
}

String? username;
String? password;
main() {
  readLine().listen(processLine);
}

connect(String username, String password) {
  channel = IOWebSocketChannel.connect('ws://localhost:3000/user', headers: {
    'username': username,
    'password': password,
    'ref': 0,
    'command': 'lgin',
  });

  channel!.stream.listen((message) {
    try {
      Map<String, dynamic> json = jsonDecode(message.toString());
      if (json['command'] == 'lgin') {
        print('''
░██╗░░░░░░░██╗███████╗██╗░░░░░░█████╗░░█████╗░███╗░░░███╗███████╗
░██║░░██╗░░██║██╔════╝██║░░░░░██╔══██╗██╔══██╗████╗░████║██╔════╝
░╚██╗████╗██╔╝█████╗░░██║░░░░░██║░░╚═╝██║░░██║██╔████╔██║█████╗░░
░░████╔═████║░██╔══╝░░██║░░░░░██║░░██╗██║░░██║██║╚██╔╝██║██╔══╝░░
░░╚██╔╝░╚██╔╝░███████╗███████╗╚█████╔╝╚█████╔╝██║░╚═╝░██║███████╗
░░░╚═╝░░░╚═╝░░╚══════╝╚══════╝░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚══════╝
''');
      }
    } catch (e) {
      print("[${DateFormat('HH:mm').format(DateTime.now())}]" +
          message.toString());
    }
  });
}

send(String message, [String? nama]) {
  channel!.sink.add(jsonEncode({
    if (nama != null) 'username': nama,
    'pesan': message,
  }));
}
