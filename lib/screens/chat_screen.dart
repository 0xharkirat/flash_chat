import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  late final User loggedInUser;
  late String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }



  void getCurrentUser() {

    try{
      final user = _auth.currentUser;

      if (user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }

    }
    catch (e){
      print(e);
    }

  }

  void messageStream () async {
    await for (var snapshot in _firestore.collection('messages').snapshots()){
      for (var message in snapshot.docs){
        print(message.data());
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);

                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });

                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot){

          if (!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          List<MessageBubble> messageBubbles = [];
          final messages = snapshot.data?.docs;

          for (var message in messages!){
            final data = message.data() as Map;
            final messageText = data['text'];
            final messageSender = data['sender'];
            final messageBuble = MessageBubble(sender: messageSender, message: messageText);
            messageBubbles.add(messageBuble);

          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );




        }
    );
  }
}


class MessageBubble extends StatelessWidget {

   MessageBubble({required this.sender, required this.message});

  final String message;
  final String sender;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget> [
          Text(sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54
          ),),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

