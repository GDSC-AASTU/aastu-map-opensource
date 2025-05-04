import 'package:flutter/material.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //screen size
    final Size screenSize = MediaQuery.of(context).size;
    //team members data
    final List<Map<String, String>> teamMembers = [
      {
        "image": "assets/images/team/mihretA.png",
        "name": "Mihret Agegnehu",
        "role": "Team Lead",
        "linkedin": "https://www.linkedin.com/in/mihret-bekele/",
      },
      {
        "image": "assets/images/team/gemechis.png",
        "name": "Gemechis Elias",
        "role": "Team Lead",
        "linkedin": "https://www.linkedin.com/in/gemechis-elias/",
      },
      {
        "image": "assets/images/team/natnael.png",
        "name": "Natnael Yeshiwas",
        "role": "Mentor",
        "linkedin": "https://www.linkedin.com/in/natnael-yeshiwas-a6243723b/",
      },
      {
        "image": "assets/images/team/dagim.png",
        "name": "Dagim Mesfin",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/dagim-mesfin-40418a267/",
      },
      {
        "image": "assets/images/team/ermias.png",
        "name": "Ermias Sileshi",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/ermias-seleshi/",
      },
      {
        "image": "assets/images/team/ekutatash.png",
        "name": "Enkutatash Eshetu",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/enkutatash-eshetu/",
      },
      {
        "image": "assets/images/team/afrah.png",
        "name": "Afrah Hussien",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/afrah-hussein-innovater/",
      },
      {
        "image": "assets/images/team/nebil.png",
        "name": "Nebiyou Elias",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/nebiyou-elias-mohammed/",
      },
      {
        "image": "assets/images/team/natannan.JPG",
        "name": "Natannan Zeleke",
        "role": "UI/UX Designer",
        "linkedin": "https://www.linkedin.com/in/natannan-zeleke/",
      },
      {
        "image": "assets/images/team/mihretThe.png",
        "name": "Mihret Tekalgn",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/mihretthe/",
      },
      {
        "image": "assets/images/team/fasika.png",
        "name": "Fasika Gebrehana",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/fasika-gebrehana-35a693215/",
      },
      {
        "image": "assets/images/team/samiya.jpg",
        "name": "Samiya Yusuf",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/samiya-yusuf/",
      },
      {
        "image": "assets/images/team/sefina.jpg",
        "name": "Sefina Kamile",
        "role": "Developer",
        "linkedin": "https://www.linkedin.com/in/sefina-kamile/",
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: const Text(
                        'About AASTU Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                      ),
                      child: Image.asset(
                        'assets/images/aastumap.png',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'AASTU Map',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "The AASTU University Map Application aims to provide students, faculty, staff, and visitors with a comprehensive digital map of the university campus. This application will facilitate easy navigation, location finding, and exploration of campus facilities. Whether it's a student seeking their next class location, a faculty member needing to find a meeting room, AASTU University Map Application is designed to cater to diverse navigation needs with efficiency and precision.",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            // Partners Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Partners',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPartnerLogo('assets/images/AASTULogo.png'),
                      _buildPartnerLogo('assets/images/gdsc.png'),
                      _buildPartnerLogo('assets/images/gebeya.png'),
                    ],
                  ),
                ],
              ),
            ),

            // Team Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Meet the Team',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenSize.width < 425 ? 2 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      final member = teamMembers[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Open LinkedIn profile in a web view or browser
                              final url = member["linkedin"]!;
                              // Use url_launcher or any other method to open the URL
                              // For example:
                              launchUrl(Uri.parse(url));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  member["image"]!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              member["name"]!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              member["role"]!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Copyright footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Text(
                '© AASTU May 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerLogo(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        height: 50,
        fit: BoxFit.contain,
      ),
    );
  }
}
