import 'package:bruh_chat/models/chat.dart';
import 'package:bruh_chat/models/chats.dart';
import 'package:bruh_chat/models/contact.dart';
import 'package:bruh_chat/models/group.dart';
import 'package:bruh_chat/models/groups.dart';
import 'package:bruh_chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();
  Firestore _db;
  String _userCollection = "Users";
  String _chatCollection = "Chats";
  String _groupsCollection = "Groups";

  DatabaseService() {
    _db = Firestore.instance;
  }

  Future<void> createUserInDb(String _userId, String _name, String _email,
      String _password, String _imageUrl) async {
    try {
      DateTime now = DateTime.now().toUtc();
      return await _db.collection(_userCollection).document(_userId).setData(
        {
          "email": _email,
          "password": _password,
          "name": _name,
          "lastSeen": now,
          "lastExit": now,
          "image": _imageUrl
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.updateData(
      {
        "lastSeen": Timestamp.now(),
      },
    );
  }

  Future<void> updateUserLastExitTime(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.updateData(
      {
        "lastExit": Timestamp.now(),
      },
    );
  }

  Future<void> updateUserUnseenMessages(String _userID, String _hostID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_chatCollection)
        .document(_hostID);
    return _ref.updateData(
      {
        "unseenCount": 0,
      },
    );
  }

  Future<void> updateUserUnseenMessagesGroup(String _userID, String _groupID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_groupsCollection)
        .document(_groupID);
    return _ref.updateData(
      {
        "unseenCount": 0,
      },
    );
  }

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.get().asStream().map(
          (_snapshot) => Contact.fromFirestore(_snapshot),
        );
  }

  Future<List<String>> getPartecipants(String _groupID) async {
    var _ref = await _db.collection(_groupsCollection).document(_groupID).get();
    var members = _ref.data['members'];
    List<String> usernameList = [];
    for (var userID in members) {
      var user = await _db.collection(_userCollection).document(userID).get();
      usernameList.add(user.data['name']);
    }
    return usernameList;
  }

  Stream<Chats> getUnseenCountOfReceiverChat(String _userID, String _myUserID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_chatCollection)
        .document(_myUserID);
    return _ref.get().asStream().map(
          (_snapshot) => Chats.fromFirestore(_snapshot),
        );
  }

  Stream<List<Chats>> getUserConversation(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_chatCollection);
    return _ref.snapshots().map(
          (_snapshot) => _snapshot.documents.map(
            (_doc) {
              return Chats.fromFirestore(_doc);
            },
          ).toList(),
        );
  }

  Stream<List<Groups>> getUserGroups(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_groupsCollection);
    return _ref.snapshots().map(
          (_snapshot) => _snapshot.documents.map(
            (_doc) {
              return Groups.fromFirestore(_doc);
            },
          ).toList(),
        );
  }

  Stream<Chat> getConversation(String _chatID) {
    var _ref = _db.collection(_chatCollection).document(_chatID);
    return _ref.snapshots().map(
          (_snapshot) => Chat.fromFirestore(_snapshot),
        );
  }

  Stream<Group> getGroup(String _groupID) {
    var _ref = _db.collection(_groupsCollection).document(_groupID);
    return _ref.snapshots().map(
          (_snapshot) => Group.fromFirestore(_snapshot),
        );
  }

  Stream<List<Contact>> getUserInDatabase(String _searchName) {
    var _ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where(
          "name",
          isLessThan: _searchName + 'z',
        );
    return _ref.getDocuments().asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Future<void> createOrGetConversation(String _currentID, String _recepientID,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_chatCollection);
    var _userConversationRef = _db
        .collection(_userCollection)
        .document(_currentID)
        .collection(_chatCollection);
    try {
      var conversation =
          await _userConversationRef.document(_recepientID).get();
      if (conversation.data != null) {
        return _onSuccess(conversation.data["chatID"]);
      } else {
        var _conversationRef = _ref.document();
        await _conversationRef.setData(
          {
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            "messages": [],
          },
        );
        return _onSuccess(_conversationRef.documentID);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createGroup(String _currentID, List _members, String _groupImage,
      String _groupName, Future<void> _onSuccess(String _groupID)) async {
    _members.add(_currentID);
    var _ref = _db.collection(_groupsCollection);

    try {
      var _conversationRef = _ref.document();
      await _conversationRef.setData(
        {
          "members": _members,
          "groupImage": _groupImage,
          "groupName": _groupName,
          "ownerID": _currentID,
          "messages": [],
        },
      );
      return _onSuccess(_conversationRef.documentID);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateGroupImage(
    String _groupID,
    _groupImage,
  ) async {
    var _ref = _db.collection(_groupsCollection).document(_groupID);
    try {
      await _ref.updateData(
        {
          "groupImage": _groupImage,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage(String _chatID, Message _message) {
    var _ref = _db.collection(_chatCollection).document(_chatID);
    return _ref.updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": _message.content,
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "type": _message.type,
            "userCanSeeMessage": _message.userCanSeeMessage,
          },
        ],
      )
    });
  }

  Future<void> sendMessageGroup(String _groupID, Message _message) {
    var _ref = _db.collection(_groupsCollection).document(_groupID);
    return _ref.updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": _message.content,
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "type": _message.type
          },
        ],
      )
    });
  }

  Future<void> removeChatForMe(
      String _chatId, String _userID, String myID) async {
    try {
      await _db
          .collection(_userCollection)
          .document(myID)
          .collection(_chatCollection)
          .document(_userID)
          .updateData({
        "lastMessage": null,
        "senderID": null,
        "timestamp": null,
        "type": null
      });
      Chat _chat = await getConversation(_chatId).first;
      _chat.messages.forEach((Message message) {
        message.userCanSeeMessage[_userID] = false;
      });
      return _db
          .collection(_chatCollection)
          .document(_chatId)
          .updateData({"messages": _chat.messages});
    } catch (e) {
      print(e);
    }
  }
}
