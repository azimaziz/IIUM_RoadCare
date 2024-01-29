import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roadcare/pages/login/auth_page.dart';
import 'package:roadcare/pages//user/report_detail_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  static const LatLng _center = LatLng(3.252161672150421, 101.73425857314945);
  Set<Marker> _markers = {};
  String _selectedStatus = 'All';  // Initial filter value

  @override
  void initState() {
    super.initState();
    _fetchReports(_selectedStatus);
  }

  void _fetchReports(String statusFilter) async {
    QuerySnapshot querySnapshot;
    if (statusFilter == 'All') {
      querySnapshot = await FirebaseFirestore.instance.collection('reports').get();
    } else {
      querySnapshot = await FirebaseFirestore.instance.collection('reports').where('status', isEqualTo: statusFilter).get();
    }

    setState(() {
      _markers = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['status'],
            snippet: 'Severity: ${data['severity']}',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ReportDetailPage(
                  imageUrl: data['imageUrl'],
                  status: data['status'],
                  severity: data['severity'],
                  description: data['description'] ?? '',
                ),
              ));
            },
          ),
          icon: data['status'] == 'Fixed' 
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)  // Use green for "Fixed"
            : BitmapDescriptor.defaultMarker,
        );
      }).toSet();
    });
  }

  void _onFilterChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedStatus = newValue;
      });
      _fetchReports(newValue);
    }
  }

   void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigate to the login screen and remove all routes from the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 70,
          height: 70,
          child: Image.asset('lib/images/IIUMRoadCareLogo.png'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Stack( 
        children: [
          GoogleMap(  
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 16,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 10,  
            right: 10,  
            child: Material(  
              elevation: 8.0,  
              borderRadius: BorderRadius.circular(8), 
              child: Container(  
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,  
                  borderRadius: BorderRadius.circular(8), 
                ),
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  items: <String>['All', 'Pending', 'Fixed'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _onFilterChanged,
                  underline: Container(), 
                  isDense: true,  
                  iconSize: 24, 
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
