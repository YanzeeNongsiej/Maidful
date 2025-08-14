// import 'package:flutter/material.dart';

// class CompletionRequestWidget extends StatefulWidget {
//   const CompletionRequestWidget({super.key});

//   @override
//   _CompletionRequestWidgetState createState() =>
//       _CompletionRequestWidgetState();
// }

// class _CompletionRequestWidgetState extends State<CompletionRequestWidget> {
//   int punctualityRating = 0;
//   int qualityRating = 0;
//   int professionalismRating = 0;
//   final TextEditingController reviewController = TextEditingController();
//   final TextEditingController reasonController = TextEditingController();
//   final TextEditingController feedbackController = TextEditingController();

//   Widget _buildRatingRow(
//       String title, int rating, ValueChanged<int> onRatingChanged) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ...List.generate(5, (index) {
//           return IconButton(
//             onPressed: () => onRatingChanged(index + 1),
//             icon: Icon(
//               Icons.star,
//               color: rating > index ? Colors.orange : Colors.grey,
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Rating and Review"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Please provide the overall rating for this maid:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             _buildRatingRow("", qualityRating, (rating) {
//               setState(() {
//                 qualityRating = rating;
//               });
//             }),
//             SizedBox(height: 20),
//             Text(
//               "Write a Review:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: reviewController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: "Please enter your review",
//                 border: OutlineInputBorder(),
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text("Reason:"),
//             TextField(
//               controller: reasonController,
//               decoration: InputDecoration(
//                 hintText: "Please enter a reason",
//                 border: OutlineInputBorder(),
//               ),
//               style: TextStyle(fontWeight: FontWeight.w300),
//             ),
//             SizedBox(height: 16),
//             Text("Feedback:"),
//             TextField(
//               controller: feedbackController,
//               decoration: InputDecoration(
//                 hintText: "Please enter feedback for the Service/Maid",
//                 border: OutlineInputBorder(),
//               ),
//               style: TextStyle(fontWeight: FontWeight.w300),
//               minLines: 3,
//               maxLines: 5,
//             ),
//             SizedBox(height: 20),
//             Text(
//               "*By clicking Submit, the Completion Request will be sent to the respective Maid/Employer for further actions.",
//               style: TextStyle(fontSize: 12),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 // Handle submission logic
//                 Navigator.of(context).pop(); // Go back to the previous screen
//               },
//               child: Text("Submit"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // Dispose controllers to free resources
//     reviewController.dispose();
//     reasonController.dispose();
//     feedbackController.dispose();
//     super.dispose();
//   }
// }
