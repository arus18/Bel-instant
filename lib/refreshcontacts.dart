import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'user.dart';
import 'countrycodes.dart';

Future<void> refreshContacts(User user) async {
  final Iterable<Contact> contacts = await FlutterContacts.getContacts();
  final users = FirebaseFirestore.instance
      .collection('users')
      .doc(user.regionCode)
      .collection('users');
  final dbContacts = await users.doc(user.userID).collection('contacts').get();
  await Future.forEach(contacts, (Contact contact) async {
    final List<Phone>? numbers = contact.phones;
    await Future.forEach(numbers!, (Phone number) {
      updateContacts(user, number.number.replaceAll(RegExp(r"\s+"), ""),
          dbContacts.docs, users);
    });
  });
}

Future<void> updateContacts(User user, String phoneNumber, List contacts,
    CollectionReference users) async {
  final numberLength = regionCodeNationalNumberLength[user.regionCode];
  final countryCode = regionCodeCountryCode[user.regionCode];
  if (phoneNumber.startsWith('+')) {
    final regionCodes =
        await FirebaseFirestore.instance.collection('users').get();
    for (int i = 0; i < regionCodes.docs.length; i++) {
      final id = regionCodes.docs.elementAt(i).id;
      final _users = FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('users');
      bool isContactUpdated = contacts.any((contact) {
        return contact['phoneNumber'] == phoneNumber;
      });
      if (!isContactUpdated) {
        final userSnapshot = await _getUser(
          phoneNumber,
          _users,
        );
        if (userSnapshot != null) {
          if (userSnapshot.id != user.userID) {
            final contacts = users.doc(user.userID).collection('contacts');
            contacts.doc(userSnapshot.id).set({
              'displayPictureUrl': userSnapshot['displayPictureUrl'],
              'contactName': userSnapshot['name'],
              'phoneNumber': userSnapshot['phoneNumber'],
              'regionCode': userSnapshot['regionCode']
            }, SetOptions(merge: true));
            break;
          }
        }
      }
    }
  }
  if (phoneNumber.length >= numberLength!) {
    //if phonenumber not equal to user.phonenumber
    final startIndex = phoneNumber.length - numberLength;
    final nationalNumber = phoneNumber.substring(startIndex);
    final internationalNumber = countryCode! + nationalNumber;
    bool isContactUpdated = contacts.any((contact) {
      return contact['phoneNumber'] == internationalNumber;
    });
    if (!isContactUpdated) {
      final userSnapshot = await _getUser(
        internationalNumber,
        users,
      );
      if (userSnapshot != null) {
        if (userSnapshot.id != user.userID) {
          final contacts = users.doc(user.userID).collection('contacts');
          contacts.doc(userSnapshot.id).set({
            'displayPictureUrl': userSnapshot['displayPictureUrl'],
            'contactName': userSnapshot['name'],
            'phoneNumber': userSnapshot['phoneNumber'],
            'regionCode': userSnapshot['regionCode']
          }, SetOptions(merge: true));
        }
      }
    }
  }
}

Future<QueryDocumentSnapshot?> _getUser(
  String number,
  CollectionReference users,
) async {
  final QuerySnapshot result =
      await users.where('phoneNumber', isEqualTo: number).limit(1).get();
  return result.docs.length == 1 ? result.docs[0] : null;
}
