
import 'package:flutter/material.dart';
import 'package:mana_mana_app/screens/Profile/ViewModel/owner_profileVM.dart';
class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  final OwnerProfileVM model = OwnerProfileVM();
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = model.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState != ConnectionState.done;
        return Scaffold(
          appBar:  AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/personal_info_back.png'),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        )
      ),
          body:  Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                 children: [
                   _buildRow(icon: 'personal_info_name.png', label: 'Name'),
                   const SizedBox(width: 10),
                   Text('${model.users.first.ownerFullName}'),
                 ],
               ),
               Row(
                  children: [
                    _buildRow(icon: 'personal_info_contact.png', label: 'Contact No.'),
                    const SizedBox(width: 10),
                    Text('${model.users.first.ownerAltContact}'),
                  ],
                ),
                Row(
                  children: [
                    _buildRow(icon: 'personal_info_email.png', label: 'Email'),
                    const SizedBox(width: 10),
                    Text('${model.users.first.email}'), 
                  ],
                ),
                Row(
                  children: [
                    _buildRow(icon: 'personal_info_address.png', label: 'Address'),
                    const SizedBox(width: 10),
                    Text('${model.users.first.ownerAddress}'), 
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow({required String icon, required String label}) {
    return SizedBox(
      width:150,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
      
            Image.asset('assets/images/$icon'),
            const SizedBox(width: 10),
            Text(label),
            
          ],
        ),
      ),
    );
  }
}
