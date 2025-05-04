// import 'package:flutter/material.dart';
// import 'package:panorama_viewer/panorama_viewer.dart';

// class PanoramaView extends StatelessWidget {
//   final String imageUrl;

//   const PanoramaView({super.key, required this.imageUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Panorama View'),
//         backgroundColor: Colors.white,
//       ),
//       body: PanoramaViewer(
//         child: Image.network(
//           imageUrl,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded / 
//                       loadingProgress.expectedTotalBytes!
//                     : null,
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Failed to load panorama image',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
