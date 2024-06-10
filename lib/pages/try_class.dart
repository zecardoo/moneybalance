// StreamBuilder(
//           stream: FirebaseFirestore.instance
//               .collection('record')
//               .doc(recordID['id'])
//               .collection('balance') // Assuming you have a subcollection
//               .snapshots(),
//           builder: (context, snapshot) {
          

//             if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             }

          
//             final subDocs = snapshot.data!.docs;

//             forhim = 0;
//             onhim = 0;

//             // Iterate through each document in subSnapshot.data!.docs
//             for (int i = 0; i < subDocs.length; i++) {
//               final DocumentSnapshot? doc = snapshot.data?.docs[i];
//               final Map<String, dynamic>? subData = doc?.data() as Map<String, dynamic>?;
//               if (subData != null) {
           
//                 forhim += subData['forhim'];
//                 onhim += subData['onhim'];
//               }
//             }
//             totalamount = forhim - onhim;
//             logger.i(totalamount);
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 recordID['state'] ? Text(' دائن :  ${recordID['amount']}', style: GoogleFonts.readexPro(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,)))
//                 : Text('مدين: ${recordID['amount']}', style: GoogleFonts.readexPro(textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white,))),
            
//               ],
//             ),