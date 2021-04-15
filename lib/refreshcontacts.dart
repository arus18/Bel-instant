import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:interactive_message/user.dart';
import 'countrycodes.dart';

Future<void> refreshContacts(User user) async {
  final Iterable<Contact> contacts = await ContactsService.getContacts();
  final users = FirebaseFirestore.instance
      .collection('users')
      .doc(user.regionCode)
      .collection('users');
  final dbContacts = await users.doc(user.userID).collection('contacts').get();
  await Future.forEach(contacts, (Contact contact) async {
    final Iterable<Item> numbers = contact.phones;
    await Future.forEach(numbers, (Item number) {
      updateContacts(user, number.value.replaceAll(RegExp(r"\s+"), ""),
          dbContacts.docs, users);
    });
  });
}

Future<void> updateContacts(User user, String phoneNumber, List contacts,
    CollectionReference users) async {
  final numberLength = regionCodeNationalNumberLength[user.regionCode];
  final countryCode = regionCodeCountryCode[user.regionCode];
  if (phoneNumber.startsWith('+')) {
    final regionCodes = await FirebaseFirestore.instance.collection('users').get();
    for(int i = 0;i<regionCodes.docs.length;i++){
      final id = regionCodes.docs.elementAt(i).id;
      final _users = FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('users');
      bool isContactUpdated = contacts.any((contact) {
        return contact.data()['phoneNumber'] == phoneNumber;
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
              'displayPictureUrl': userSnapshot.data()['displayPictureUrl'],
              'contactName': userSnapshot.data()['name'],
              'phoneNumber': userSnapshot.data()['phoneNumber'],
              'regionCode': userSnapshot.data()['regionCode']
            }, SetOptions(merge: true));
            break;
          }
        }
      }
    }
  }
  if (phoneNumber.length >= numberLength) {
    //if phonenumber not equal to user.phonenumber
    final startIndex = phoneNumber.length - numberLength;
    final nationalNumber = phoneNumber.substring(startIndex);
    final internationalNumber = countryCode + nationalNumber;
    bool isContactUpdated = contacts.any((contact) {
      return contact.data()['phoneNumber'] == internationalNumber;
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
            'displayPictureUrl': userSnapshot.data()['displayPictureUrl'],
            'contactName': userSnapshot.data()['name'],
            'phoneNumber': userSnapshot.data()['phoneNumber'],
            'regionCode': userSnapshot.data()['regionCode']
          }, SetOptions(merge: true));
        }
      }
    }
  }
}

Future<DocumentSnapshot> _getUser(
  String number,
  CollectionReference users,
) async {
  final QuerySnapshot result =
      await users.where('phoneNumber', isEqualTo: number).limit(1).get();
  return result.docs.length == 1 ? result.docs[0] : null;
}
