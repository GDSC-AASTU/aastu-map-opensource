import 'package:flutter/material.dart';
import 'package:aastu_map/core/colors.dart';

class AASTUInfoPage extends StatelessWidget {
  const AASTUInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About AASTU University'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // University Logo
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/AASTULogo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Addis Ababa Science and Technology University',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Excellence through Innovation',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),
          
          // University Overview
          _buildSectionTitle('University Overview'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Addis Ababa Science and Technology University (AASTU) is one of Ethiopia\'s newest and most dynamic public universities, established with a focus on science, technology, engineering, and mathematics (STEM) education. Located in Addis Ababa, the capital city of Ethiopia, AASTU aims to be a center of excellence in technology and innovation.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // History
          _buildSectionTitle('History'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'AASTU was established in 2011 as part of the Ethiopian government\'s initiative to expand higher education with a focus on science and technology. The university was built on a spacious campus in the southern part of Addis Ababa, with modern facilities designed to provide quality education in technical fields.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Academic Programs
          _buildSectionTitle('Academic Programs'),
          _buildInfoItem('Engineering: Civil, Electrical, Mechanical, Software, Chemical and more'),
          _buildInfoItem('Natural and Computational Sciences'),
          _buildInfoItem('Business and Management'),
          _buildInfoItem('Applied Sciences'),
          _buildInfoItem('Graduate programs in various engineering disciplines'),
          
          const SizedBox(height: 16),
          
          // Campus Facilities
          _buildSectionTitle('Campus Facilities'),
          _buildInfoItem('Modern lecture halls and classrooms equipped with technology'),
          _buildInfoItem('Specialized engineering and science laboratories'),
          _buildInfoItem('Expansive library with digital resources'),
          _buildInfoItem('Student dormitories and cafeterias'),
          _buildInfoItem('Sports facilities including football field and gymnasium'),
          _buildInfoItem('Healthcare center'),
          _buildInfoItem('ICT center and computer labs'),
          
          const SizedBox(height: 16),
          
          // Mission and Vision
          _buildSectionTitle('Mission and Vision'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mission',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'To produce competent and innovative professionals, conduct problem-solving research, and provide relevant community services in the fields of science and technology.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 16),
                Text(
                  'Vision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'To be a premier university in science and technology education, research, and innovation in Africa by 2030.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact Information
          _buildSectionTitle('Contact Information'),
          _buildContactItem(Icons.location_on, 'Address', 'Kilinto Area, Addis Ababa, Ethiopia'),
          _buildContactItem(Icons.email, 'Email', 'info@aastu.edu.et'),
          _buildContactItem(Icons.language, 'Website', 'www.aastu.edu.et'),
          _buildContactItem(Icons.phone, 'Phone', '+251 11 896 7000'),
          
          const SizedBox(height: 32),
          
          // Copyright
          Center(
            child: Text(
              '© ${DateTime.now().year} AASTU. All rights reserved.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String info) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_right,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 